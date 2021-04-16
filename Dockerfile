FROM fedora:33

RUN dnf install -y \
    bzip2 \
    gcc \
    git \
    gnu-efi-devel \
    make \
    patch \
    wget

# pnardini: We need to build shim 15.4 from a tarball.  Download and extract it.
RUN mkdir -p /build/shim
WORKDIR /build/shim
RUN wget https://github.com/rhboot/shim/releases/download/15.4/shim-15.4.tar.bz2
RUN tar -jxvpf shim-15.4.tar.bz2 && rm shim-15.4.tar.bz2
WORKDIR /build/shim/shim-15.4

# pnardini: The below section has been commented out for shim 15.4.  Not sure if
# this is a one-off or if tarballs will be how we build shim going forward, so
# leaving this section here for now.

# Clone shim, check out tag 15.4, and init submodules
# RUN git clone --branch 15.4 https://github.com/rhboot/shim.git /build/shim
# WORKDIR /build/shim
# RUN git submodule update --init

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
