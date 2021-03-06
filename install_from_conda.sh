#!/usr/bin/env bash

#credit to Colas, Giacomo, and possibly others

set -e

# Set the conda environment name
export ENVIRONMENT_NAME=fvh_threeML

# Set the directory where we will install AERIE and the HAWC externals
export THREEML_TEST_DIR=~/threeML_tests

# Set the number of threads
export N_THREADS=4

# Create our conda environment installing the Fermi ST as well as threeML and the
# externals needed
conda create -y --name $ENVIRONMENT_NAME -c threeml -c conda-forge/label/cf201901 -c fermi fermitools threeml boost=1.63 cmake zeromq cppzmq healpix_cxx=3.31 pytest==3.9.3  matplotlib numba pyyaml==3.13 yaml==0.1.7 fermipy 

# Activate the conda environment
source activate $ENVIRONMENT_NAME

#This version of numpy may not be available via conda.
pip install numpy==1.15.3

# Install root_numpy making sure it is built against the installed version of ROOT
pip uninstall root_numpy
export MACOSX_DEPLOYMENT_TARGET=10.10
pip install --no-binary :all: root_numpy

#another package needed for HAL
pip install reproject

# Install HAL
pip uninstall hawc_hal -y ; pip install git+https://github.com/threeML/hawc_hal.git
 
# Write setup file
# NOTE: variables will be expanded
cat > $HOME/init_conda_fvh.sh <<- EOM

# Empty potentially harmful variables
unset LD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH
unset PYTHONPATH

# Activate environment
source activate $ENVIRONMENT_NAME

export FERMI_DIR=${CONDA_PREFIX}/share/fermitools/

export THREEML_TEST_DIR=${THREEML_TEST_DIR}

export PATH=$PATH

export PYTHONPATH=${PYTHONPATH}

if [ "$(uname)" == "Darwin" ]; then

    export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}
else

    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
fi

# Set this here so that following builds of AERIE or any other software will find their
# libraries
# flags for C++ needed for C++11 support (-Wno-narrowing is needed for clang)
export CXXFLAGS="-std=c++11 -I${CONDA_PREFIX}/include -Wno-narrowing"
export LDFLAGS="-Wl,-rpath,${CONDA_PREFIX}/lib,-rpath,${CONDA_PREFIX}/lib/root -L${CONDA_PREFIX}/lib -L${CONDA_PREFIX}/lib/root"

# These settings enhance a little performances in 3ML
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

EOM
