FROM debian:bookworm-slim

RUN apt-get update -y && apt-get install g++ -y
RUN apt-get update -y && apt-get install git -y
RUN apt-get update -y && apt-get install cmake -y

# Install zlib
RUN apt-get update -y && apt-get install zlib1g-dev -y
# Install bzip2
RUN apt-get update -y && apt-get install libbz2-dev -y
# Install zstd
RUN apt-get update -y && apt-get install libzstd-dev -y
# Install gflags
RUN apt-get update -y && apt-get install libgflags-dev -y
# Install liblz4-dev
RUN apt-get update -y && apt-get install liblz4-dev -y
# Install jemalloc
RUN apt-get update -y && apt-get install libjemalloc-dev -y
# Install snappy
RUN apt-get update -y && apt-get install libsnappy-dev -y

# Set workdir for repositories
WORKDIR /repos

# Add a build argument
ARG CACHEBUST=2

# Clone repo
RUN git clone https://github.com/taco-paco/rocksdb.git
RUN git clone https://github.com/gflags/gflags.git
RUN git clone https://github.com/google/snappy.git
RUN git clone git clone https://github.com/facebook/zstd.git

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

