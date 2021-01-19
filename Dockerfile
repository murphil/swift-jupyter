FROM nnurphy/ub

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    libatomic1 \
    libbsd0 \
    libcurl4 \
    libxml2 \
    tzdata \
    clang \
    libpython3-dev \
    libblocksruntime-dev \
    libdispatch-dev \
    libsqlite3-dev \
    python3 python3-pip python3-setuptools \
    && python3 -m pip install --upgrade pip \
    && rm -r /var/lib/apt/lists/*

# Allow the caller to specify the toolchain to use
###### https://github.com/tensorflow/swift/blob/master/Installation.md#pre-built-packages
ARG swift_tf_url=https://storage.googleapis.com/swift-tensorflow-artifacts/releases/v0.12/rc2/swift-tensorflow-RELEASE-0.12-ubuntu20.04.tar.gz

# Install some python libraries that are useful to call from swift
WORKDIR /swift-jupyter
COPY requirements*.txt ./
RUN python3 -m pip install --no-cache-dir -r requirements.txt \
    && python3 -m pip install --no-cache-dir -r requirements_py_graphics.txt

# Download and extract S4TF
WORKDIR /swift-tensorflow-toolchain
RUN mkdir usr \
    && curl -sSL $swift_tf_url \
        | tar -xzf - --directory=usr --strip-components=1

# Copy the kernel into the container
COPY . .

# Register the kernel with jupyter
RUN python3 register.py --user --swift-toolchain /swift-tensorflow-toolchain

# Add Swift to the PATH
ENV PATH="$PATH:/swift-tensorflow-toolchain/usr/bin/"

#
WORKDIR /root
RUN git clone --depth=1 https://github.com/apple/sourcekit-lsp.git \
 && cd sourcekit-lsp \
 && swift build \
 && cd /root && rm -rf sourcekit-lsp \
 && cfg_home=/etc/skel \
 && nvim_home=$cfg_home/.config/nvim \
 && nvim -u $nvim_home/init.vim --headless +"CocInstall -sync coc-$x" +qa \
 && ehco '...'

# Create the notebooks dir for mounting
RUN mkdir /notebooks
WORKDIR /notebooks

# Run Jupyter on container start
EXPOSE 8888
