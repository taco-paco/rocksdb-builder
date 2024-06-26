FROM debian:bookworm-slim as rocksdb-base

# Install neccesities
RUN apt-get update -y &&  \
    apt-get install -y g++ git cmake

RUN apt-get update -y &&  \
    apt-get install -y zlib1g-dev libbz2-dev \
    liblz4-dev autoconf

FROM rocksdb-base as gflags-builder

# Clone gflags
WORKDIR /repos
RUN git clone https://github.com/gflags/gflags.git

# Compile and install gflags artifacts
WORKDIR /repos/gflags/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local/gflags" -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
RUN make
RUN make install

FROM rocksdb-base as snappy-builder

# Clone snappy
WORKDIR /repos
RUN git clone https://github.com/google/snappy.git

# Compile and install gflags artifacts
WORKDIR /repos/snappy/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local/snappy" -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
RUN make -j4
RUN make install

FROM rocksdb-base as zstd-builder

# Clone zstd
WORKDIR /repos
RUN git clone https://github.com/facebook/zstd.git

# Compilation magic
WORKDIR /repos/zstd/build/cmake/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr/local/zstd" -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON
RUN make -j4
RUN make install

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

FROM rocksdb-base as rocksdb-builder

# Clone repo
WORKDIR /repos
ARG CACHEBUST=0
RUN git clone https://github.com/taco-paco/rocksdb.git

# Copu artifacts from previous stages
COPY --from=gflags-builder /usr/local/gflags /usr/local
COPY --from=snappy-builder /usr/local/snappy /usr/local
COPY --from=zstd-builder /usr/local/zstd /usr/local
COPY --from=jemalloc-builder /usr/local/jemalloc /usr

WORKDIR /repos/rocksdb/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/tmp/rocksdb" \
    -DWITH_GFLAGS=ON -DWITH_LZ4=ON -DWITH_ZLIB=ON \
    -DWITH_SNAPPY=ON -DWITH_ZSTD=ON -DWITH_BZ2=ON \
    -DWITH_JEMALLOC=ON -DGFLAGS_SHARED=FALSE -DGFLAGS_NOTHREADS=FALSE  \
    -Dgflags_DIR="/usr/local/lib/cmake/gflags" \
    -DSnappy_DIR="/usr/local/lib/cmake/Snappy" \
    -Dzstd_DIR="/usr/local/lib/cmake/zstd"

RUN make -j4
RUN make install

VOLUME ["/output"]

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

