FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH="${PATH}:/cmake/bin"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-c"]
RUN apt-get update -y && apt-get install -y build-essential gcc g++ binutils wget curl git python3 xz-utils unzip gawk autoconf texinfo flex bison

COPY binutils-2.43.zip /tmp
RUN unzip /tmp/binutils-2.43.zip && cd binutils-2.43 && ./configure --target=mips-elf && make -j`nproc` && make install
RUN  cd binutils-2.43 && make distclean && ./configure --program-prefix="nodelay-" --target=mips-elf && make -j`nproc` && make install
RUN git clone --depth 1 --branch releases/gcc-14.2.0 https://github.com/gcc-mirror/gcc.git

COPY gcc.patch /tmp
RUN cd gcc && git apply /tmp/gcc.patch && ./contrib/download_prerequisites
RUN mkdir build && cd build && \
../gcc/configure --program-prefix="nodelay-" --target=mips-elf --disable-libstdcxx --without-headers --disable-threads --disable-mutlilib --disable-libquadmath --disable-libquadmath-support --with-newlib --disable-libssp  --enable-languages=c --disable-libsanitizer --disable-fixed-point --disable-lto --disable-bootstrap --disable-target-libbacktrace && \
make -j`nproc` && make install
