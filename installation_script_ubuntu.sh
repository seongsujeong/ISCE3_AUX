#Originated from Dockerfile (Working version at 10/22/2021)
# For ubuntu 20.04
#
#Installing CUDA driver and toolkit
#NOTE: Follow the link below when in need of choosing different version of the packages:
#      https://developer.nvidia.com/cuda-downloads
#sudo apt install kernel-devel-$(uname -r) kernel-headers-$(uname -r)

sudo apt -y update
sudo apt -y install make gcc g++ gnupg2 curl ca-certificates bzip2 zip git 


#Install CUDA
wget https://developer.download.nvidia.com/compute/cuda/11.5.0/local_installers/cuda_11.5.0_495.29.05_linux.run
sudo sh cuda_11.5.0_495.29.05_linux.run
export PATH=$PATH:/usr/local/cuda-11.5/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.5/lib64
export ISCEHOME=$HOME


echo "Creating directories for ISCE3 build and installation"
mkdir $ISCEHOME/python
mkdir -p $ISCEHOME/tools/isce/src
mkdir -p $ISCEHOME/tools/isce/build
mkdir -p $ISCEHOME/tools/isce/install
cd $ISCEHOME

echo "Installing (mini)conda"
curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh &&\
 bash miniconda.sh -b -p ${ISCEHOME}/python/miniconda3 &&\
 touch ${ISCEHOME}/python/miniconda3/conda-meta/pinned
export PATH=${ISCEHOME}/python/miniconda3/bin:$PATH
export LD_LIBRARY_PATH=${ISCEHOME}/python/miniconda3/lib:$LD_LIBRARY_PATH

echo "Installing dependency using conda"
conda config --add channels conda-forge
conda config --set channel_priority strict
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
pybind11=2.6.2\n\
pyre=1.9.9\n\
pkg-config\n\
pytest\n\
python\n\
ruamel.yaml\n\
scipy\n\
shapely\n\
yamale\n"\
 > ${ISCEHOME}/python/requirements.txt
conda install --file ${ISCEHOME}/python/requirements.txt
#TODO: add pkgconfig

echo "Downloading ISCE3 source code from github"
cd ${ISCEHOME}/tools/isce/src
git clone https://github.com/isce-framework/isce3.git
cd isce3
git checkout develop
cd ${ISCEHOME}/tools/isce
export CUDACXX=`which nvcc`
export CC=`which gcc`
export CXX=`which g++`
#NOTE: Had to put a workarounds to the build commands below to keep docker build running.
cd ${ISCEHOME}/tools/isce/build #to make sure
cmake -DCMAKE_INSTALL_PREFIX=${ISCEHOME}/tools/isce/install ${ISCEHOME}/tools/isce/src/isce3
make -j8 VERBOSE=ON
make install 


export PATH=$PATH:${ISCEHOME}/tools/isce/install/bin
export PYTHONPATH=$PYTHONPATH:${ISCEHOME}/tools/isce/install/packages
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${ISCEHOME}/tools/isce/install/lib


#add few lines into .bashrc
printf "export ISCEHOME=$HOME \n\
export PATH=$PATH:/usr/local/cuda-11.5/bin \n\
export PATH=${ISCEHOME}/python/miniconda3/bin:$PATH \n\
export PATH=$PATH:${ISCEHOME}/tools/isce/install/bin \n\
export LD_LIBRARY_PATH=${ISCEHOME}/python/miniconda3/lib:$LD_LIBRARY_PATH \n\
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.5/lib64 \n\
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${ISCEHOME}/tools/isce/install/lib \n\
export PYTHONPATH=$PYTHONPATH:${ISCEHOME}/tools/isce/install/packages\n" >>$HOME/.bashrc

#MEMO: using eigen=3.3.9
#MEMO: using hdf5=1.12.0
