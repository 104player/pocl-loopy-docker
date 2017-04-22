FROM ubuntu:16.10
MAINTAINER Fred Burton <fredlburton AT gmail.com>
VOLUME /data
#RUN echo nameserver 8.8.8.8 > /etc/resolv.conf ; cat /etc/resolv.conf
# Specifies the number of jobs
ENV THREADS 2
RUN set -x && \
        echo nameserver 8.8.8.8 > /etc/resolv.conf && \
        apt-get update && apt-get install -y --no-install-recommends wget build-essential python cmake && \
        cd /tmp && wget -q 'http://llvm.org/releases/3.9.0/llvm-3.9.0.src.tar.xz' && wget -q 'http://llvm.org/releases/3.9.0/cfe-3.9.0.src.tar.xz' && \
        tar xaf llvm-3.9.0.src.tar.xz && mv llvm-3.9.0.src llvm && \
        tar xaf cfe-3.9.0.src.tar.xz && mv cfe-3.9.0.src llvm/tools/clang && \
        mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release ../llvm && make -j$THREADS && make install && mv /tmp/llvm /opt/ && \
        apt-get clean && apt-get purge -y --auto-remove wget && rm -rf /tmp/build

# now that's out of the way, let's get Python 3, and various other deps
RUN echo nameserver 8.8.8.8 > /etc/resolv.conf && apt-get install -y python3 python3-pip python3-dev python3-mako python3-requests python3-requests python3-pillow git pkg-config python3-setuptools python3-coverage libhwloc-dev libffi-dev python3-nose python3-numpy python3-pytest python3-pytools && apt-get clean

# Checkout source for loopy, pyopencl, pocl, cosmic-ray
RUN echo nameserver 8.8.8.8 > /etc/resolv.conf && cd /opt && git clone http://git.tiker.net/trees/pyopencl.git pyopencl && git clone https://gitlab.tiker.net/inducer/loopy && git clone https://github.com/pocl/pocl.git && git clone https://github.com/sixty-north/cosmic-ray.git && cd /opt/pyopencl && git submodule update --init

# build pocl
RUN echo nameserver 8.8.8.8 > /etc/resolv.conf && cd /opt/pocl && mkdir build && cd build && cmake .. && make && make install && ldconfig

ENV PYOPENCL_CTX 0

# build, install pyopencl * configured for opencl 1.1 support
RUN echo nameserver 8.8.8.8 > /etc/resolv.conf && cd /opt/pyopencl && python3 ./configure.py --cl-pretend-version=1.1 && python3 setup.py build && python3 setup.py install

# build, install loopy
RUN echo nameserver 8.8.8.8 > /etc/resolv.conf && cd /opt/loopy && python3 setup.py build && python3 setup.py install
