# Tensorflow-gpu rebased on ubi8

ARG CUDA=11.2
# Cuda images are multi-arch; building on ARM builder will pull arm64
FROM nvidia/cuda:${CUDA}.1-base-ubi8 as base
ARG CUDA
ARG CUDNN=8.1.0.77-1
ARG LIBNVINFER=8.0.0-1

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies
# see https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#redhat8-installation
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    yum install -y \
    cuda-command-line-tools-${CUDA/./-} \
    libcublas-${CUDA/./-} \
    cuda-nvprune-${CUDA/./-} \
    cuda-nvrtc-${CUDA/./-} \
    libcufft-${CUDA/./-} \
    libcurand-${CUDA/./-} \
    libcusolver-${CUDA/./-} \
    libcusparse-${CUDA/./-} \
    libcudnn8-${CUDNN}.cuda${CUDA} \
    libnvinfer8-${LIBNVINFER}.cuda11.0 \
    libnvinfer-plugin8-${LIBNVINFER}.cuda11.0 \
    python38-devel \
    freetype-devel \
    hdf5-devel \
    zeromq-devel \
    zlib-devel \
    git \
    curl \
    wget \
    unzip

ENV LD_LIBRARY_PATH /usr/local/cuda-${CUDA}/targets/x86_64-linux/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
# ENV LANG C.UTF-8

# nvidia-docker runtime places libcuda.so.1 at /usr/lib64/libcuda.so.1 at container start. Skipping below...
# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure dynamic linker run-time bindings
#RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
#    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
#    && ldconfig

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

# Options:
#   tensorflow
#   tensorflow-gpu
#   tf-nightly
#   tf-nightly-gpu
# Set --build-arg TF_PACKAGE_VERSION=1.11.0rc0 to install a specific version.
# Installs the latest version by default.
ARG TF_PACKAGE=tensorflow-gpu
ARG TF_PACKAGE_VERSION=2.10.0
# workaround for install tensorboard~=2.6 resulting in 2.9.1 being installed....
RUN python3 -m pip install --no-cache-dir ${TF_PACKAGE}${TF_PACKAGE_VERSION:+==${TF_PACKAGE_VERSION}}

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc