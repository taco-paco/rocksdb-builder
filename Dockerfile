FROM debian:12.7-slim as rocksdb-base

# Install neccesities
RUN apt-get update -y &&  \
    apt-get install -y g++ git cmake

RUN apt-get update -y &&  \
    apt-get install -y liblz4-dev autoconf

# Build zlib
WORKDIR /repos
RUN git clone https://github.com/madler/zlib.git

WORKDIR /repos/zlib
ENV CFLAGS="-fPIC"
RUN ./configure --static
RUN make
RUN make install prefix=/usr/local
RUN unset CFLAGS

FROM rocksdb-base as bz2-builder

# Clone bz2
WORKDIR /repos
RUN git clone https://gitlab.com/bzip2/bzip2.git

WORKDIR /repos/bzip2/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local/bzip2" -DENABLE_LIB_ONLY=ON \
    -DENABLE_STATIC_LIB=ON -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB_IS_PIC=ON -DENABLE_TESTS=OFF
RUN cmake --build .
RUN cmake --install .

FROM rocksdb-base as gflags-builder

# Clone gflags
WORKDIR /repos
RUN git clone https://github.com/gflags/gflags.git

# Compile and install gflags artifacts
WORKDIR /repos/gflags/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local/gflags" -DBUILD_STATIC_LIBS=ON \
    -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
RUN cmake --build .
RUN cmake --install .

FROM rocksdb-base as snappy-builder

# Clone snappy
WORKDIR /repos
RUN git clone https://github.com/google/snappy.git

# Compile and install gflags artifacts
WORKDIR /repos/snappy/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local/snappy" -DSNAPPY_BUILD_TESTS=OFF \
     -DSNAPPY_BUILD_BENCHMARKS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
RUN cmake --build . -j4
RUN cmake --install .

FROM rocksdb-base as zstd-builder

# Clone zstd
WORKDIR /repos
RUN git clone --depth 1 --branch v1.5.6 https://github.com/facebook/zstd.git

# Compilation magic
WORKDIR /repos/zstd/build/cmake/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local/zstd" \
    -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON
RUN cmake --build . -j4
RUN cmake --install .

FROM rocksdb-base as jemalloc-builder

# Clone jemalloc
WORKDIR /repos
RUN git clone https://github.com/jemalloc/jemalloc.git

# Compile jemalloc
WORKDIR /repos/jemalloc
# Pass fPIC and setup artifacts location
RUN ./autogen.sh && CFLAGS="-fPIC" ./configure --prefix=/usr/local/jemalloc

# Build & install static lib
RUN make build_lib_static
RUN make install_lib_static
RUN make install_include

FROM rocksdb-base as mimalloc-builder

# Clone mimalloc
WORKDIR /repos
RUN git clone https://github.com/microsoft/mimalloc.git

# Compile mimalloc
WORKDIR /repos/mimalloc/build
RUN cmake -DMI_BUILD_STATIC=ON -DMI_BUILD_SHARED=OFF -DMI_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release -DMI_OVERRIDE=ON -DCMAKE_INSTALL_PREFIX="/usr/local/mimalloc" ..

RUN cmake --build .
RUN cmake --install .

FROM rocksdb-base as rocksdb-builder

# Clone repo
WORKDIR /repos
ARG CACHEBUST=2
ARG ALLOCATOR=mimalloc

RUN git config --global http.version HTTP/1.1
RUN git config --global http.postBuffer 157286400
RUN git clone https://github.com/taco-paco/rocksdb.git
RUN git config --global --unset http.postBuffer
RUN git config --global --unset http.version

# Copy artifacts from previous stages
COPY --from=jemalloc-builder /usr/local/jemalloc /usr/local/jemalloc
COPY --from=mimalloc-builder /usr/local/mimalloc /usr/local/mimalloc
COPY --from=gflags-builder /usr/local/gflags /usr/local
COPY --from=snappy-builder /usr/local/snappy /usr/local
COPY --from=zstd-builder /usr/local/zstd /usr/local
COPY --from=bz2-builder /usr/local/bzip2/lib /usr/local/lib
COPY --from=bz2-builder /usr/local/bzip2/include /usr/local/include

# Volume to pick up artifacts from
VOLUME ["/output"]

WORKDIR /repos/rocksdb/build
ENV LDFLAGS="-L/usr/local/lib"
RUN if [ "$ALLOCATOR" = "jemalloc" ]; then \
      export EXTRA_CMAKE_FLAGS="-DWITH_JEMALLOC=ON -DJEMALLOC_ROOT_DIR=\"/usr/local/jemalloc/\" "; \
    elif [ "$ALLOCATOR" = "mimalloc" ]; then \
      export EXTRA_CMAKE_FLAGS="-DWITH_MIMALLOC=ON -Dmimalloc_DIR=\"/usr/local/mimalloc/lib/cmake/mimalloc-1.8\" "; \
      echo $EXTRA_CMAKE_FLAGS; \
    else \
      echo "Error: Invalid allocator specified: $ALLOCATOR" >&2; \
      exit 1; \
    fi && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/tmp/rocksdb" \
        $EXTRA_CMAKE_FLAGS -DWITH_GFLAGS=ON -DWITH_LZ4=ON \
        -DWITH_ZLIB=ON -DWITH_SNAPPY=ON -DWITH_ZSTD=ON -DWITH_BZ2=ON  \
        # enable RTTI for allocator implementation
        -DUSE_RTTI=ON \
        -DGFLAGS_SHARED=FALSE -DGFLAGS_NOTHREADS=FALSE  \
        -Dgflags_DIR="/usr/local/lib/cmake/gflags" \
        -DSnappy_DIR="/usr/local/lib/cmake/Snappy" \
        -Dzstd_DIR="/usr/local/lib/cmake/zstd" \
        -DZLIB_LIBRARY=/usr/local/lib/libz.a \
        -DZLIB_INCLUDE_DIR=/usr/local/include \
        -DBZIP2_LIBRARIES="/usr/local/lib/libbz2_static.a" \
        -DBZIP2_INCLUDE_DIR="/usr/local/include"

RUN cmake --build . -j4
RUN cmake --install .

COPY prepare_artifacts.sh /prepare_artifacts.sh
RUN chmod +x /prepare_artifacts.sh
ENTRYPOINT ["/prepare_artifacts.sh"]

