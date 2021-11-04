# Once you've cloned DeNTminiapp.git, run this install file from inside the DeNTminiapp directory
# Install instructions from mfem documentation https://github.com/mfem/mfem/blob/master/INSTALL
# Builds mfem 4.2 and related third party libraries; results not reproduced using mfem 4.3


# Temporary directory for third party libraries
mkdir ../tpls; cd ../tpls

# Download third party libraries and rename tar with correct extensions as needed
wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/OLD/metis-4.0.3.tar.gz
wget https://github.com/hypre-space/hypre/archive/v2.20.0.tar.gz
wget https://bit.ly/mfem-4-2; mv mfem-4-2 mfem-4-2.tar.gz
wget https://bit.ly/glvis-3-4; mv glvis-3-4 glvis-3-4.tar.gz

# Untar all files (note: tar -zxvf * will not work)
tar -zxvf metis-4.0.3.tar.gz
tar -zxvf v2.20.0.tar.gz
tar -zxvf mfem-4-2.tar.gz
tar -zxvf glvis-3-4.tar.gz

# Build hypre and make symbolic link
cd hypre-2.20.0/src/
./configure --disable-fortran
make -j 1
cd ../..
ln -s hypre-2.20.0 hypre

# Build metis and make symbolic link
cd metis-4.0.3
make
cd ..
ln -s metis-4.0.3 metis-4.0

# Build serial mfem for glvis build
cd mfem-4.2
make serial -j 1
cd ../glvis-3.4
make MFEM_DIR=../mfem-4.2 -j 1

# Rebuild mfem with NVIDIA AmgX library
cd ../mfem-4.2
make clean 

# Create AmgX user file
cat >> config/user.mk << eof
MFEM_USE_AMGX = YES
# AmgX library configuration
AMGX_DIR = $(OLCF_AMGX_ROOT)
AMGX_OPT = -I$(AMGX_DIR)/include
AMGX_LIB = -lcusparse -lcusolver -lcublas -lnvToolsExt -L$(AMGX_DIR)/lib -lagmx
eof

# Load AmgX and CUDA modules
module load amgx 
module load cuda

# Remake the parallel cuda version of mfem
make pcuda CUDA_ARCH=sm_70 -j 1

# Finished!
cd ../DeNTminiapp

# All mfem build options from https://github.com/mfem/mfem/blob/master/INSTALL
#   make serial    -> Builds serial optimized version of the library
#   make parallel  -> Builds parallel optimized version of the library
#   make debug     -> Builds serial debug version of the library
#   make pdebug    -> Builds parallel debug version of the library
#   make cuda      -> Builds serial cuda optimized version of the library
#   make pcuda     -> Builds parallel cuda optimized version of the library
#   make cudebug   -> Builds serial cuda debug version of the library
#   make pcudebug  -> Builds parallel cuda debug version of the library
#   make hip       -> Builds serial hip optimized version of the library
#   make phip      -> Builds parallel hip optimized version of the library
#   make hipdebug  -> Builds serial hip debug version of the library
#   make phipdebug -> Builds parallel hip debug version of the library





