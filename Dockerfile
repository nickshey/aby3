FROM debian:testing

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install \
    -y --no-install-recommends --no-install-suggests vim git \ 
    cmake build-essential libssl-dev ca-certificates

RUN apt-get install -y wget
RUN apt-get install -y python3

RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.tar.gz
RUN tar -xvf boost_1_78_0.tar.gz && cd boost_1_78_0 && ./bootstrap.sh && ./b2 install

COPY aby3 aby3

RUN cd aby3 && python3 build.py --setup
RUN sed -i '56s/.*/option(ENABLE_CIRCUITS  "compile the circuit module" ON)/' /aby3/thirdparty/libOTe/cryptoTools/CMakeLists.txt
RUN cd aby3/thirdparty/libOTe && cmake -S . -B out/build/linux -DCMAKE_INSTALL_PREFIX=/aby3/thirdparty/unix \
    -DENABLE_CIRCUITS=ON -DCMAKE_PREFIX_PATH=/aby3/thirdparty/unix -DSUDO_FETCH=OFF -DFETCH_AUTO=ON \
    -DPARALLEL_FETCH=20 -DCMAKE_BUILD_TYPE=Release \ 
    && cmake --build out/build/linux \
    && cmake --install out/build/linux  

RUN sed -i '11s/.*/#include <thread>/' /aby3/aby3/sh3/Sh3BinaryEvaluator.h
RUN cd aby3 && python3 build.py