# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages /some optional
RUN apt update && apt install -y \
    curl \
    wget \
    ca-certificates \
    xz-utils \
    libncurses5 \
    cmake \
    ninja-build \
    git \
    python3 \
    python3-pip \
    build-essential \
    device-tree-compiler \
    unzip \
&& rm -rf /var/lib/apt/lists/*

# ===========================================================================================================
# Notes on flags used:
# (-LO) follows http redirects and saves the downloaded file with same name as in URL
# (-k)  ignores SSL certificate verification. This was needed due to Zscaler blocking the curl action. 
#          -This action was only done to interact with known arm server. Contact IT to whitelist arm servers.
# ============================================================================================================       

RUN curl -LO -k https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    tar xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    rm arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz

# Install additional Python packages
RUN pip3 install --upgrade west imgtool requests

# Set the workspace directory
WORKDIR /workspace

# Clone the mcuxsdk-manifests repository
RUN git clone https://github.com/nxp-mcuxpresso/mcuxsdk-manifests.git

# Set the MCUXpresso SDK path environment variable
ENV MCUX_SDK_PATH=/workspace/mcuxsdk-manifests

# Initialize and update the west workspace
RUN cd $MCUX_SDK_PATH && \
    west init -l . && \
    west update

# ARMGCC ENV variable
ENV ARMGCC_DIR=/arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi

# Default command: Start a shell
CMD ["/bin/bash"]