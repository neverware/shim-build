FROM fedora:28

RUN dnf install -y \
    gcc \
    git \
    gnu-efi-devel \
    make \
    patch

# Clone shim, check out tag shim-15.1
RUN git clone --branch shim-15.1 https://github.com/rhboot/shim.git /build/shim
WORKDIR /build/shim

# Apply a patch to fix compilation
ADD build-fix.patch .
RUN patch -p1 -i build-fix.patch

# Add our public certificate
ADD neverware.cer .

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
