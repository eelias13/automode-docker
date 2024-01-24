FROM ubuntu:20.04 AS build

# FROM rust:1.75-bullseye

ARG DEBIAN_FRONTEND=noninteractive
ARG MAKE_JOBS=6

WORKDIR /app

RUN apt update
RUN apt upgrade -y

RUN apt install git g++ cmake make curl -y
RUN apt install libfreeimage-dev libfreeimageplus-dev -y
RUN apt install  qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools -y 
RUN apt install freeglut3-dev libxi-dev libxmu-dev libgraphviz-dev -y
RUN apt install liblua5.2-dev lua5.2 -y
RUN apt install doxygen graphviz graphviz-dev asciidoc -y
RUN apt install python3-pip sqlite3 -y

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y


ARG INSTALL_PATH=/app
ARG PKG_CONFIG_PATH=$INSTALL_PATH/argos3-dist/lib/pkgconfig
ARG ARGOS_PLUGIN_PATH=$INSTALL_PATH/argos3-dist/lib/argos3
ARG LD_LIBRARY_PATH=$ARGOS_PLUGIN_PATH:$LD_LIBRARY_PATH
ARG PATH=$INSTALL_PATH/argos3-dist/bin/:$PATH

RUN cd $INSTALL_PATH && git clone --depth 1 --branch 3.0.0-beta48 https://github.com/ilpincy/argos3.git argos3
RUN mkdir -p $INSTALL_PATH/argos3/build 
RUN cd $INSTALL_PATH/argos3/build && cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH/argos3-dist -DCMAKE_BUILD_TYPE=Release -DARGOS_INSTALL_LDSOCONF=OFF -DARGOS_DOCUMENTATION=OFF ../src
RUN cd $INSTALL_PATH/argos3/build && make -j $MAKE_JOBS
RUN cd $INSTALL_PATH/argos3/build && make install

RUN rm -rf $INSTALL_PATH/argos3-dist/include/argos3/plugins/robots/e-puck
RUN rm -rf $INSTALL_PATH/argos3-dist/lib/argos3/lib*epuck*.so

RUN cd $INSTALL_PATH && git clone --depth 1 --branch v48 https://github.com/demiurge-project/argos3-epuck.git argos3-epuck
RUN mkdir -p $INSTALL_PATH/argos3-epuck/build
RUN cd $INSTALL_PATH/argos3-epuck/build && cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH/argos3-dist -DCMAKE_BUILD_TYPE=Release ../src
RUN cd $INSTALL_PATH/argos3-epuck/build && make -j $MAKE_JOBS
RUN cd $INSTALL_PATH/argos3-epuck/build && make install

RUN cd $INSTALL_PATH && git clone --depth 1 --branch dev https://github.com/demiurge-project/experiments-loop-functions.git AutoMoDe-loopfunctions
RUN mkdir -p $INSTALL_PATH/AutoMoDe-loopfunctions/build
RUN cd $INSTALL_PATH/AutoMoDe-loopfunctions/build && cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH/argos3-dist -DCMAKE_BUILD_TYPE=Release ..
RUN cd $INSTALL_PATH/AutoMoDe-loopfunctions/build && make
RUN cd $INSTALL_PATH/AutoMoDe-loopfunctions/build && make install

RUN cd $INSTALL_PATH && git clone --depth 1 https://github.com/demiurge-project/demiurge-epuck-dao.git AutoMoDe-DAO
RUN mkdir -p $INSTALL_PATH/AutoMoDe-DAO/build
RUN cd $INSTALL_PATH/AutoMoDe-DAO/build && cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH/argos3-dist -DCMAKE_BUILD_TYPE=Release ..
RUN cd $INSTALL_PATH/AutoMoDe-DAO/build && make -j $MAKE_JOBS
RUN cd $INSTALL_PATH/AutoMoDe-DAO/build && make install 

RUN cd $INSTALL_PATH && git clone --depth 1 https://github.com/eelias13/MissionGeneratorMG1 AutoMoDe-MissionGenerator
RUN mkdir -p $INSTALL_PATH/AutoMoDe-MissionGenerator/build  
RUN cd $INSTALL_PATH/AutoMoDe-MissionGenerator/build && cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH/argos3-dist ../src/
RUN cd $INSTALL_PATH/AutoMoDe-MissionGenerator/build && make -j $MAKE_JOBS
RUN cd $INSTALL_PATH/AutoMoDe-MissionGenerator/build && make install

RUN cd $INSTALL_PATH && git clone --depth 1 --branch GenericLoopFunc https://github.com/demiurge-project/ARGoS3-AutoMoDe.git AutoMoDe
RUN mkdir -p $INSTALL_PATH/AutoMoDe/build  
RUN cd $INSTALL_PATH/AutoMoDe/build && cmake ..
RUN cd $INSTALL_PATH/AutoMoDe/build && make -j $MAKE_JOBS

ENV INSTALL_PATH=/app
ENV PKG_CONFIG_PATH=$INSTALL_PATH/argos3-dist/lib/pkgconfig
ENV ARGOS_PLUGIN_PATH=$INSTALL_PATH/argos3-dist/lib/argos3
ENV LD_LIBRARY_PATH=$ARGOS_PLUGIN_PATH:$LD_LIBRARY_PATH
ENV PATH=$INSTALL_PATH/argos3-dist/bin/:$PATH

COPY data/mission_fsm.argos /app/mission.argos

RUN cd $INSTALL_PATH && git clone --depth 1 https://github.com/eelias13/automode-eval automode-eval
COPY data/chocolate-bag-epuck-positions/all_bot_pos.csv $INSTALL_PATH/automode-eval/src/all_bot_pos.csv
COPY data/metrics/metics_normalization.csv $INSTALL_PATH/automode-eval/src/metics_normalization.csv
COPY config.toml $INSTALL_PATH/automode-eval/.cargo/config.toml
RUN cd $INSTALL_PATH/automode-eval && ~/.cargo/bin/cargo build --release

RUN cd $INSTALL_PATH && git clone --depth 1 https://github.com/eelias13/PonyGE2 PonyGE2
RUN cd $INSTALL_PATH/PonyGE2 && pip3 install -r requirements.txt
COPY data/parameters.txt $INSTALL_PATH/PonyGE2/parameters/automode.txt

WORKDIR /app/PonyGE2/src

CMD [ "python3", "ponyge.py", "--parameters", "/app/PonyGE2/parameters/automode.txt" ]

# CMD [ "/app/automode-eval/target/release/automode-eval", "--eval-controller", "--nstates", "1", "--s0", "0", "--rwm0", "1"]
# CMD [ "/app/automde-eval/target/release/automde-eval", "--nstates", "1", "--s0", "0", "--rwm0", "1" ]