# RocksDB builder
The purpose of this is to provide scripts to build RocksDB dll
with custom allocator statically linked in: jemalloc, mimalloc,
as well as other third-party dependencies.

## How to build
Provided Dockerfile can build artifacts in Debug/Release and with either jemalloc or mimalloc.

To build in _release_ with _mimalloc_, simply run:
```bash
docker build -t some-name .
```

To build in _debug_ with _jemalloc_, pass arguments:
```bash
docker build --build-arg BUILD_TYPE=Debug --build-arg ALLOCATOR=jemalloc -t some-name 
```

Notice that _release_ version with _mimalloc_ compiled by default.
## Export artifacts
To export artifacts simply mount a volume and run resulting _some-name_ image. 
Example can be seen in _example/build_and_run.sh_

## Run example
To run example within docker run:
```bash
docker build -t some-name-example -f ./example/Dockerfile.test .
```

or from _example_ folder run _build_and_run.sh_ assuming you on Linux.
