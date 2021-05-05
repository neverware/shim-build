FROM fedora:33

RUN dnf install -y \
    bzip2 \
    gcc \
    git \
    gnu-efi-devel \
    make \
    patch \
    wget

# pnardini: We need to build shim 15.4 from a tarball now.
# Download and extract it.
RUN mkdir -p /build/shim
WORKDIR /build/shim
RUN wget https://github.com/rhboot/shim/releases/download/15.4/shim-15.4.tar.bz2
RUN tar -jxvpf shim-15.4.tar.bz2 && rm shim-15.4.tar.bz2
WORKDIR /build/shim/shim-15.4

# Add patches for critical shim 15.4 regressions.
# See https://github.com/rhboot/shim-review/issues/165
#
# Note:  We are not pulling in https://github.com/rhboot/shim/pull/366.
# We do not need to support ARM at this time.

# https://github.com/rhboot/shim/pull/364
ADD shim_15.4_8b59591_364.patch .
RUN patch -p1 -i shim_15.4_8b59591_364.patch

# https://github.com/rhboot/shim/pull/362
ADD shim_15.4_975c2fe_362.patch .
RUN patch -p1 -i shim_15.4_975c2fe_362.patch

# https://github.com/rhboot/shim/pull/357
ADD shim_15.4_1bea91b_357.patch .
RUN patch -p1 -i shim_15.4_1bea91b_357.patch

# https://github.com/rhboot/shim/pull/361
ADD shim_15.4_33ca950_361.patch .
RUN patch -p1 -i shim_15.4_33ca950_361.patch

# Add our public certificate
ADD neverware.cer .

# Add our SBAT data
ADD sbat.csv data/sbat.csv

# Create build directories
RUN mkdir build-x64 build-ia32

# Build 64-bit
RUN make -C build-x64 ARCH=x86_64 VENDOR_CERT_FILE=../neverware.cer \
    TOPDIR=.. -f ../Makefile

# Build 32-bit
RUN make -C build-ia32 ARCH=ia32 VENDOR_CERT_FILE=../neverware.cer \
    TOPDIR=.. -f ../Makefile

# Copy the shims to a convenient location
RUN mkdir /build/install
RUN cp build-x64/shimx64.efi /build/install
RUN cp build-ia32/shimia32.efi /build/install
