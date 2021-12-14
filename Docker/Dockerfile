#command: sth like below:
#docker build -f $HOME/Documents/dev/ISCE3_AUX/Docker/Dockerfile -t seongsu/isce3:latest .
#Change log:
# 10/22/2021: Working version
FROM nvidia/cuda:latest

SHELL ["/bin/bash","-c"]

LABEL author="Seongsu Jeong (seongsuj@uci.edu)" \
      description="Dockerized ISCE3" \
      version="0.4.0"

#ENV ISCEHOME /root
ENV ISCEHOME $HOME

RUN apt update &&\
 apt -y install gnupg2 curl ca-certificates bzip2 zip git
 
RUN mkdir $ISCEHOME/python &&\
 mkdir -p $ISCEHOME/tools/isce/src &&\
 mkdir -p $ISCEHOME/tools/isce/build &&\
 mkdir -p $ISCEHOME/tools/isce/install &&\
 cd $ISCEHOME

RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh &&\
 bash miniconda.sh -b -p ${ISCEHOME}/python/miniconda3 &&\
 touch ${ISCEHOME}/python/miniconda3/conda-meta/pinned

ENV PATH $PATH:${ISCEHOME}/python/miniconda3/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:${ISCEHOME}/python/miniconda3/lib

RUN conda config --add channels conda-forge &&\
 conda config --set channel_priority strict &&\
 printf "cmake\n\
 eigen=3.3.9\n\
 fftw\n\
 gdal\n\
 gmock\n\
 gtest\n\
 gcc_linux-64\n\
 gxx_linux-64\n\
 hdf5=1.10.6\n\
 h5py\n\
 libgcc-ng\n\
 libstdcxx-ng\n\
 numpy\n\
 pybind11\n\
 pyre=1.9.9\n\
 pkg-config\n\
 pytest\n\
 python\n\
 ruamel.yaml\n\
 scipy\n\
 shapely\n\
 yamale\n"\
 > ${ISCEHOME}/python/requirements.txt &&\
 conda install --file ${ISCEHOME}/python/requirements.txt

RUN cd ${ISCEHOME}/tools/isce/src &&\
 git clone https://github.com/isce-framework/isce3.git &&\
 cd isce3 &&\
 git checkout develop &&\
 cd ${ISCEHOME}/tools/isce &&\
 export CUDACXX=`which nvcc` &&\
 export CC=gcc &&\
 export CXX=g++ &&\
 cd ${ISCEHOME}/tools/isce/build

#NOTE: Had to put a workarounds to the build commands below to keep docker build running.
RUN cmake -DCMAKE_INSTALL_PREFIX=${ISCEHOME}/tools/isce/install ${ISCEHOME}/tools/isce/src/isce3; exit 0
RUN make -j8 VERBOSE=ON; exit 0
RUN make install 

ENV PATH $PATH:${ISCEHOME}/tools/isce/install/bin
ENV PYTHONPATH $PYTHONPATH:${ISCEHOME}/tools/isce/install/packages
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:${ISCEHOME}/tools/isce/install/lib

#MEMO using eigen=3.3.9
#MEMO using hdf5=1.12.0


#skip the environemnt creation and activation
#RUN source $HOME/.bashrc
#RUN conda init
#RUN conda create -y --name isce3_040
#RUN conda activate root
#ENV CONDA_DEFAULT_ENV isce3_040

