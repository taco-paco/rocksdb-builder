#FROM debian:12.7-slim as rocksdb-base
FROM ubuntu:20.04 as rocksdb-base

# Install essentials
RUN apt-get update -y && \
   DEBIAN_FRONTEND=noninteractive apt-get install -y g++ make git wget

# Install cmake
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
      CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
      CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-aarch64.tar.gz"; \
    else \
      echo "Unsupported platform. Create an issue if supposed to be supported."; \
      exit 1; \
    fi && \
    wget $CMAKE_URL && \
        tar -zxvf cmake-3.22.1-linux-$ARCH.tar.gz -C /opt && \
        ln -s /opt/cmake-3.22.1-linux-$ARCH/bin/cmake /usr/local/bin/cmake && \
        rm cmake-3.22.1-linux-$ARCH.tar.gz

# Install third-party
RUN apt-get update -y &&  \
    apt-get install -y liblz4-dev autoconf

ARG BUILD_TYPE=Release
ENV BUILD_TYPE=${BUILD_TYPE}

# Debuging container outside
RUN if [ "$BUILD_TYPE" = "Debug" ]; then \
      apt-get update -y && apt-get -y install gdb gdbserver; \
    fi

# Build zlib
WORKDIR /repos
RUN git clone https://github.com/madler/zlib.git

WORKDIR /repos/zlib
ENV CFLAGS="-fPIC"
RUN if [ "$BUILD_TYPE" = "Release" ]; then \
      ./configure --static; \
    elif [ "$BUILD_TYPE" = "Debug" ]; then \
      ./configure --static --debug; \
    else \
      echo "Error: Invalid BUILD_TYPE specified: $BUILD_TYPE" >&2; \
      exit 1; \
    fi

RUN make
RUN make install prefix=/usr/local
RUN unset CFLAGS

FROM rocksdb-base as bz2-builder

# Clone bz2
WORKDIR /repos
RUN git clone https://gitlab.com/bzip2/bzip2.git

WORKDIR /repos/bzip2/build
RUN cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="/usr/local/bzip2" -DENABLE_LIB_ONLY=ON \
    -DENABLE_STATIC_LIB=ON -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB_IS_PIC=ON -DENABLE_TESTS=OFF
RUN cmake --build .
RUN cmake --install .

FROM rocksdb-base as gflags-builder

# Clone gflags
WORKDIR /repos
RUN git clone https://github.com/gflags/gflags.git

# Compile and install gflags artifacts
WORKDIR /repos/gflags/build
RUN cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="/usr/local/gflags" -DBUILD_STATIC_LIBS=ON \
    -DBUILD_SHARED_LIBS=OFF -DBUILD_gflags_nothreads_LIB=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
RUN cmake --build .
RUN cmake --install .

FROM rocksdb-base as snappy-builder

# Clone snappy
WORKDIR /repos
RUN git clone https://github.com/google/snappy.git

# Compile and install gflags artifacts
WORKDIR /repos/snappy/build
RUN cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="/usr/local/snappy" -DSNAPPY_BUILD_TESTS=OFF \
     -DSNAPPY_BUILD_BENCHMARKS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
RUN cmake --build . -j4
RUN cmake --install .

FROM rocksdb-base as zstd-builder

# Clone zstd
WORKDIR /repos
RUN git clone --depth 1 --branch v1.5.6 https://github.com/facebook/zstd.git

# Compilation magic
WORKDIR /repos/zstd/build/cmake/build
RUN cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="/usr/local/zstd" \
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
RUN if ["$BUILD_TYPE" = "Release"]; then  \
    ./autogen.sh && CFLAGS="-fPIC" ./configure --prefix=/usr/local/jemalloc; \
    else \
    ./autogen.sh && CFLAGS="-fPIC" ./configure --enable-debug --prefix=/usr/local/jemalloc; \
    fi

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
RUN cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE  -DMI_BUILD_STATIC=ON -DMI_BUILD_SHARED=OFF \
     -DMI_BUILD_TESTS=OFF -DMI_OVERRIDE=ON -DCMAKE_INSTALL_PREFIX="/usr/local/mimalloc" ..

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
    if [ "$BUILD_TYPE" = "Debug" ]; then \
      EXTRA_CMAKE_FLAGS="$EXTRA_CMAKE_FLAGS -DWITH_TESTS=OFF"; \
    fi && \
    cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="/tmp/rocksdb" \
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

