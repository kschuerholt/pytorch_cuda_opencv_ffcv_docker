FROM nvcr.io/nvidia/pytorch:23.03-py3
LABEL maintainer="Konstantin Schürholt <konstantin.schuerholt@unisg.ch>"
# based on https://github.com/JulianAssmann/opencv-cuda-docker

USER root

RUN apt-get update 

# FFCV requires opencv, which is not available in the pytorch docker image.
# Installing via apt messes up cuda/mpi, so we need to build opencv from source.
# -> build opencv from source, with cuda (DWITH_CUDA=ON)
# -> pkg_config needs to be generated for ffcv to find opencv (DOPENCV_GENERATE_PKGCONFIG=YES) #note, can be "ON" depending on opencv version

ARG DEBIAN_FRONTEND=noninteractive
ARG OPENCV_VERSION=4.7.0

RUN apt-get update && apt-get upgrade -y &&\
    # Install build tools, build dependencies and python
    apt-get install -y \
    python3-pip \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libavformat-dev \
        libpq-dev \
        libxine2-dev \
        libglew-dev \
        libtiff5-dev \
        zlib1g-dev \
        libjpeg-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libpostproc-dev \
        libswscale-dev \
        libeigen3-dev \
        libtbb-dev \
        libgtk2.0-dev \
        pkg-config \
        ## Python
        python3-dev \
        python3-numpy \
    && rm -rf /var/lib/apt/lists/*

RUN cd /opt/ &&\
    # Download and unzip OpenCV and opencv_contrib and delte zip files
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip &&\
    unzip $OPENCV_VERSION.zip &&\
    rm $OPENCV_VERSION.zip &&\
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip &&\
    unzip ${OPENCV_VERSION}.zip &&\
    rm ${OPENCV_VERSION}.zip &&\
    # Create build folder and switch to it
    mkdir /opt/opencv-${OPENCV_VERSION}/build && cd /opt/opencv-${OPENCV_VERSION}/build &&\
    # Cmake configure
    cmake \
        -DOPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${OPENCV_VERSION}/modules \
        -DWITH_CUDA=ON \
        -DCUDA_ARCH_BIN=7.5,8.0,8.6 \
        -DCMAKE_BUILD_TYPE=RELEASE \
	-DOPENCV_GENERATE_PKGCONFIG=YES \
        # Install path will be /usr/local/lib (lib is implicit)
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        .. &&\
    # Make
    make -j"$(nproc)" && \
    # Install to /usr/local/lib
    make install && \
    ldconfig &&\
    # Remove OpenCV sources and build folder
    rm -rf /opt/opencv-${OPENCV_VERSION} && rm -rf /opt/opencv_contrib-${OPENCV_VERSION}

# install othere ffcv dependencies
RUN pip3 install cupy-cuda113 numba

RUN apt-get update -y
RUN apt-get install -y libturbojpeg0-dev 

# install ffcv
RUN pip3 install ffcv

# add further packages below.

