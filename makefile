
# Copy local.config.template local.config
# Edit local.config for your local configuration

include local.config

######################################################################
######################################################################
######################################################################
#
# Shouldn't need changes below here
#
BOOST_TOOLSET = $(TOOLSET)
export PATH := $(PATH):$(EXTERNALS_BUILD_TARGET_DIR)/release/bin:$(EXTERNALS_BUILD_TARGET_DIR)/common/bin

BJAM = $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/bin/bjam

TOP = `pwd`

CLASP_REQUIRES_RTTI=1
CLASP_APP_RESOURCES_DIR = $(EXTERNALS_BUILD_TARGET_DIR)
CLASP_APP_RESOURCES_EXTERNALS_DIR = $(CLASP_APP_RESOURCES_DIR)
CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/debug
CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/release
CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/common
#
# Needed by gmp fixlibgmpxx.sh scrip
#
export CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR)/lib
CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR)/lib
CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/lib


all:
	make gitllvm36_1
	make gitboehm
	make allnoget

allnoget:
	make setup
	make subAll
	make subBundle

ifeq ($(GCC_EXECUTABLE),)
export GCC_EXECUTABLE = $(GCC_TOOLCHAIN)/bin/gcc
endif
ifeq ($(GXX_EXECUTABLE),)
export GXX_EXECUTABLE = $(GCC_TOOLCHAIN)/bin/g++
endif


ifeq ($(TARGET_OS),linux)
CLASP_CXXFLAGS="-std=c++11"
else
CLASP_CXXFLAGS="-std=c++11 -stdlib=libc++"
endif

export REQUIRES_RTTI=$(CLASP_REQUIRES_RTTI)
BOEHM_VERSION=7.2
CC = $(CLASP_CC)

ifneq ($(CXXFLAGS),)
	BOOST_CXXFLAGS="cxxflags=$(CXXFLAGS)"
endif
ifneq ($(LDFLAGS),)
	BOOST_LDFLAGS="linkflags=$(LDFLAGS) -lc++"
endif

READLINE_VERSION=6.2
OPENMPI_SOURCE_DIR = openmpi-1.6.5
MPS_SOURCE_DIR = mps-temporary
ECL_SOURCE_DIR = ecl
#export LLVM_REVISION = 212390
#export LLVM_SOURCE_DIR = llvm3.4svn

BOEHM_SOURCE_DIR = boehm-7.2
EXPAT_SOURCE_DIR = expat-2.0.1
ZLIB_SOURCE_DIR = zlib-1.2.8
GMP_SOURCE_DIR = gmp-6.0.0
BOOST_SOURCE_DIR = boost
#export BOOST_BUILD_SOURCE_DIR = boost-build-system
BOOST_BUILD_SOURCE_DIR = $(BOOST_SOURCE_DIR)/tools/build/v2
LLDB_SOURCE_DIR = lldb

export LLVM_REVISION = 218184
getllvm:
	svn co -r $(LLVM_REVISION) http://llvm.org/svn/llvm-project/llvm/trunk $(LLVM_SOURCE_DIR)
	(cd $(LLVM_SOURCE_DIR)/tools; svn co -r $(LLVM_REVISION)  http://llvm.org/svn/llvm-project/cfe/trunk clang)
	(cd $(LLVM_SOURCE_DIR)/tools/clang/tools; svn co -r $(LLVM_REVISION) http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra)


export LLVM_SOURCE_DIR = llvm36
gitllvm36_0:
	-git clone --depth 1 -b llvm_36_clasp_01 https://github.com/drmeister/llvm36_0.git $(LLVM_SOURCE_DIR)
	-(cd $(LLVM_SOURCE_DIR)/tools; git clone --depth 1 -b clang_36_clasp_01 https://github.com/drmeister/clang36_0.git clang)
	-(cd $(LLVM_SOURCE_DIR)/tools/clang/tools; git clone --depth 1 -b clang-tools-extra_36_clasp_01 https://github.com/drmeister/clang-tools-extra36_0.git extras)


gitllvm36_1:
	-git clone --depth 1 -b master https://github.com/drmeister/llvm36_1.git $(LLVM_SOURCE_DIR)
	-(cd $(LLVM_SOURCE_DIR)/tools; git clone --depth 1 -b master https://github.com/drmeister/clang36_1.git clang)
	-(cd $(LLVM_SOURCE_DIR)/tools/clang/tools; git clone --depth 1 -b master https://github.com/drmeister/clang-tools-extra36_1.git extras)


gitboehm:
	-git clone --depth 1 https://github.com/drmeister/bdwgc.git $(BOEHM_SOURCE_DIR)
	-(cd $(BOEHM_SOURCE_DIR); git clone git://github.com/ivmai/libatomic_ops.git;)
	-(cd $(BOEHM_SOURCE_DIR); autoreconf -vif; )
	-(cd $(BOEHM_SOURCE_DIR); automake --add-missing )


git_make_submodules:
	-git submodule add http://llvm.org/git/llvm.git llvm
	-git submodule add http://llvm.org/git/clang.git $(LLVM_SOURCE_DIR)/tools/clang
	-git submodule add http://llvm.org/git/clang-tools-extra.git $(LLVM_SOURCE_DIR)/tools/clang/tools/extras


resetllvm:
	rm -rf llvm3.4svn

all-dependencies:
	make subClean
	make setup
	make subAll


printenv:
	printenv
	echo EXTERNALS_DIR=$(EXTERNALS_DIR)
	echo CLASP_APP_INSTALL_ROOT=$(CLASP_APP_INSTALL_ROOT)
	echo BJAM=$(BJAM)

bjamversion:
	@echo BJAM path = $(BJAM)
	$(BJAM) -v



setup:
	install -d $(EXTERNALS_BUILD_TARGET_DIR)
	install -d $(CLASP_APP_RESOURCES_DIR)
	install -d $(CLASP_APP_RESOURCES_EXTERNALS_DIR)
	install -d $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR)
	install -d $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)
	make subClean
	make boostbuild2-build
	make boehm-setup
	make llvm-setup
	make boost-setup
#	make ecl-setup
	make gmp-setup
	make expat-setup
	make zlib-setup
	make readline-setup
#	make openmpi-setup
#	make clang-setup This is redundant, it gets configured with llvm
#	make lldb-setup

build subAll sa:
	make boehm-build
	make llvm-release
	make boost-build
	make gmp-build
#	make ecl-build
	make expat-build
	make zlib-build
	make readline-build
	make subBundle
#	make openmpi-build
#	-make ez_setup
#	-make pyOpenGl-cleanBuild

subClean:
#	make openmpi-clean
	make boehm-clean
	make readline-clean
	make expat-clean
#	make ecl-clean
	make zlib-clean
	make gmp-clean
	make boost-clean
#	make clang-clean Redundant.
	make llvm-clean


shell:
	bash

clean:
	make subClean
ifneq ($(EXTERNALS_BUILD_TARGET_DIR),)
	-(find $(EXTERNALS_BUILD_TARGET_DIR)/release -type f -print0 | xargs -0 rm -f)
	-(find $(EXTERNALS_BUILD_TARGET_DIR)/debug -type f -print0 | xargs -0 rm -f)
	-(find $(EXTERNALS_BUILD_TARGET_DIR)/common -type f -print0 | xargs -0 rm -f)
endif


#
# This removes the llvm source
#
really-clean:
	make clean
ifneq ($(LLVM_SOURCE_DIR),)
	rm -rf ./$(LLVM_SOURCE_DIR)
endif
ifneq ($(BOEHM_SOURCE_DIR),)
	rm -rf ./$(BOEHM_SOURCE_DIR)
endif


rpath-fix:
	make boost-rpath-fix
	make llvm-rpath-fix
	make gmp-rpath-fix
	make zlib-rpath-fix
	make readline-rpath-fix
	make expat-rpath-fix


openmpi-clean:
	-(cd $(OPENMPI_SOURCE_DIR); make clean)

openmpi-setup:
	-(cd $(OPENMPI_SOURCE_DIR); ./configure --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR))

#
# There is a problem in openmpi where they have "(default: "DEFAULT_OUTFILE")    "
# it is tripping the warning -Wreserved-user-defined-literal
openmpi-build:
	-(cd $(OPENMPI_SOURCE_DIR); CXXFLAGS="-Wno-reserved-user-defined-literal"; make all install)

mps-setup:
	-(cd $(MPS_SOURCE_DIR); ./configure --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR))


mps-build:
	-(cd $(MPS_SOURCE_DIR); make -j$(PJOBS) install)


lldb-get:
	svn co http://llvm.org/svn/llvm-project/lldb/trunk lldb

lldb-setup:
	-mkdir -p $(LLVM_SOURCE_DIR)/tools/lldb/build
	(cd $(LLVM_SOURCE_DIR)/tools/lldb/build; \
		CC=clang; CXX=clang++; CXXFLAGS="-I$(HOME)/Development/cando/externals/src/libcxx/include -std=c++11 -stdlib=libc++"\
		../../../configure \
		--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR);)

lldb-build:
	(cd $(LLDB_SOURCE_DIR); xcodebuild -jobs 4 -project lldb.xcodeproj)


llvm-rpath-fix:
	make llvm-rpath-fix-debug
	make llvm-rpath-fix-release


ecl-setup:
	make ecl-clean
	(cd $(ECL_SOURCE_DIR); ./configure --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR))

ecl-build:
	(cd $(ECL_SOURCE_DIR); make; make install)

ecl-clean:
	-(rm -rf $(ECL_SOURCE_DIR)/build)





llvm-clean:
	make llvm-clean-release
	make llvm-clean-debug

llvm-clean-release:
	-(rm -rf $(LLVM_SOURCE_DIR)/build-release;)

llvm-clean-debug:
	-(rm -rf $(LLVM_SOURCE_DIR)/build-debug;)


llvm-setup-rtti-test:
	echo REQUIRES_RTTI=$(REQUIRES_RTTI)

llvm-setup:
	echo REQUIRES_RTTI=$(REQUIRES_RTTI)
#	-ln -s ./clang llvm/tools/clang
#-ln -s libcxx llvm/projects
	make llvm-setup-debug
	make llvm-setup-release



llvm-build:
	make llvm-debug
	make llvm-release

# build llvm with VERBOSE=1 to see commands as they execute  - also set -j1 so multiple builds output aren't interleaved
#	(cd $(LLVM_SOURCE_DIR)/build-debug; export VERBOSE=1;  make VERBOSE=1 -j$(COMPILE_PROCESSORS) ; make install) 2>&1 | tee ../_llvm-debug.log

llvm-debug:
	(cd $(LLVM_SOURCE_DIR)/build-debug; make -j$(PJOBS) ; make install)

llvm-release:
	(cd $(LLVM_SOURCE_DIR)/build-release; make -j$(PJOBS) ; make install)




boost-build:
	make boost-build-debug
	make boost-build-release


boost-build-debug:
	echo LDFLAGS=$(LDFLAGS)    processed = $(BOOST_LDFLAGS)
	(cd $(BOOST_SOURCE_DIR); \
				$(BJAM) toolset=$(BOOST_TOOLSET)  \
				$(BOOST_CXXFLAGS) $(BOOST_LDFLAGS) \
				--with-filesystem --with-date_time	\
				--with-serialization --with-iostreams	\
				--with-program_options --with-regex	\
				--with-system --with-mpi\
				include=../$(ZLIB_SOURCE_DIR) linkflags=-L../$(ZLIB_SOURCE_DIR)\
				--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR) \
				debug link=static \
				-j$(PJOBS) install --ignore-site-config )


boost-build-release:
	(cd $(BOOST_SOURCE_DIR); $(BJAM) toolset=$(BOOST_TOOLSET)   \
				$(BOOST_CXXFLAGS) $(BOOST_LDFLAGS) \
				--with-filesystem --with-date_time	\
				--with-serialization --with-iostreams	\
				--with-program_options --with-regex	\
				--with-system --with-mpi \
				include=../$(ZLIB_SOURCE_DIR) linkflags=-L../$(ZLIB_SOURCE_DIR)\
				--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR) \
				link=static \
				release \
				-j$(PJOBS) \
				install --ignore-site-config )

#				include=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR) \


llvm-doxygen:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-doxygen
	(cd $(LLVM_SOURCE_DIR)/build-doxygen; export REQUIRES_RTTI=1; \
		../configure --enable-doxygen \
		--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR);)
	(cd $(LLVM_SOURCE_DIR)/build-dbg; export REQUIRES_RTTI=1; make -j$(PJOBS) REQUIRES_RTTI=1; make install) 2>&1 | tee ../logs/_llvm-doxygen.log




clang-setup:
	make clang-setup-release


gmp-clean:
	(cd $(GMP_SOURCE_DIR); make clean ; rm -f gen-fib)

gmp-setup:
	(cd $(GMP_SOURCE_DIR); \
		CXXFLAGS=$(CLASP_CXXFLAGS); \
		./configure --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR) --enable-cxx)
	echo "If this failed - use make gmp-clean first to clear out old configuration"
	echo "gmpXXX/gen-fib sticks around even after gmp-clean - maybe delete it???"


gmp-build-n:
	(cd $(GMP_SOURCE_DIR); make install -n)





boost-setup:
#	cp project-config.jam $(BOOST_SOURCE_DIR)/project-config.jam
#	cp user-config.jam $(BOOST_SOURCE_DIR)/tools/build/v2/user-config.jam
	echo do nothing

boost-build-a-n:
	(cd $(BOOST_SOURCE_DIR); $(BJAM) toolset=$(BOOST_TOOLSET) -a -n  \
				cxxflags="$(CXXFLAGS)" linkflags="$(LDFLAGS)" \
				--with-filesystem --with-date_time	\
				--with-serialization --with-iostreams	\
				--with-program_options --with-regex	\
				--with-python --with-system  --with-thread \
				--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR) \
				debug  \
				-j$(PJOBS) \
				--ignore-site-config \
				install ) | tee logs/_boost.log


boost-clean:
	-(cd $(BOOST_SOURCE_DIR); $(BJAM) --toolset=$(BOOST_TOOLSET) --clean debug --ignore-site-config)
	-(cd $(BOOST_SOURCE_DIR); $(BJAM) --toolset=$(BOOST_TOOLSET) --clean release --ignore-site-config)



expat-setup:
	(cd $(EXPAT_SOURCE_DIR); ./configure --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR); )

expat-build:
	(cd $(EXPAT_SOURCE_DIR);  make -j$(PJOBS) install)


expat-clean:
	-(cd $(EXPAT_SOURCE_DIR); make clean )




zlib-setup:
	(cd $(ZLIB_SOURCE_DIR); ./configure -shared --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR);)

zlib-build:
	(cd $(ZLIB_SOURCE_DIR); make -j$(PJOBS) install)


zlib-clean:
	-(cd $(ZLIB_SOURCE_DIR); make clean )








boehm-setup:
	(cd $(BOEHM_SOURCE_DIR); \
		export ALL_INTERIOR_PTRS=1; \
		CFLAGS="-DUSE_MMAP" \
		./configure --enable-shared=no --enable-static=yes --enable-handle-fork --enable-cplusplus --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR);)
boehm-build:
	make boehm-compile
	make boehm-install

boehm-compile:
	(cd $(BOEHM_SOURCE_DIR); make -j1 | tee _boehm.log)

boehm-install:
	(cd $(BOEHM_SOURCE_DIR); make -j1 install | tee _boehm_install.log)



boehm-clean:
	-(cd $(BOEHM_SOURCE_DIR); make clean )









readline-build:
	make readline-compile
	make readline-install

readline-setup:
	(cd readline-$(READLINE_VERSION); \
		./configure --enable-shared --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR);)
	sed -e 's/-dynamic/-dynamiclib/g' <readline-$(READLINE_VERSION)/shlib/Makefile  >readline-$(READLINE_VERSION)/shlib/Makefile.good
	mv readline-$(READLINE_VERSION)/shlib/Makefile.good readline-$(READLINE_VERSION)/shlib/Makefile


readline-compile:
	(cd readline-$(READLINE_VERSION); make -j$(PJOBS))

readline-install:
	(cd readline-$(READLINE_VERSION); make -j$(PJOBS) install)



readline-clean:
	-(cd readline-$(READLINE_VERSION); make clean )



cmake-setup:
	(cd $(CMAKE_VERSION); ./configure;)

cmake-install:
	(cd $(CMAKE_VERSION); make install; )


openmm-setup:
	install -d $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/openmm/build
	(cd $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/openmm/build; \
		ccmake -DCMAKE_INSTALL_PREFIX=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/openmm \
			-DOPENMM_BUILD_AMOEBA_CUDA_LIB=OFF \
			-DOPENMM_BUILD_CUDA_LIB=OFF \
			-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
			-DCMAKE_OSX_ARCHITECTURES=x86_64 \
			-DOPENMM_BUILD_FREE_ENERGY_CUDA_LIB=OFF \
			-i $(CLASP_EXTERNALS_SRC)/$(OPENMM_VERSION);)

xpath-install:
	(cd py-dom-xpath-0.1; python setup.py install)



openmm-install:
	(cd $(CLASP_P_RESOURCES_EXTERNALS_RELEASE_DIR)/openmm/build; make install )


pyopenmm-install:
	(cd PyOpenMM-3.0.0;python setup.py build; python setup.py install)





subBundle sb:
#	install -d $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/bin
#	install -c jamfile.jam.lib $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/jamfile.jam
#	-install -c $(OPENMM_INSTALL)/lib/lib* $(CLASP_APP_LIB_DIR)
#	-install -c $(OPENMM_INSTALL)/lib/plugins/* $(CLASP_APP_LIB_DIR)/plugins
#	make rpath-fix
# This first link allows LibTooling to find the clang include directories relative to the clasp executable path
#	install -d $(CLASP_APP_BIN_DIR)
#	-ln -s $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/lib $(CLASP_APP_BIN_DIR)/../lib
	@echo IF YOU GOT HERE EVERYTHING IS GOING TO BE JUST FINE!!!
	@echo PROCEED WITH CONFIDENCE TO BUILD CLASP!!!




############################################################
#
# linux linux linux linux linux linux linux linux linux
#
##

ifeq ($(TARGET_OS),linux)
#
# Set clang-setup --prefix to $(CLASP_APP_RESOURCES_DIR)
#
# This will also move the clang executable into the CLASP_APP_RESOURCES_DIR
# so adjust your path accordingly
#




#linux
llvm-setup-debug:
	echo GCC_TOOLCHAIN = $(GCC_TOOLCHAIN)
	-mkdir -p $(LLVM_SOURCE_DIR)/build-debug
	(cd $(LLVM_SOURCE_DIR)/build-debug; \
		../configure --enable-targets=x86_64 --enable-debug-symbols --enable-debug-runtime \
		--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR) \
		--with-gcc-toolchain=$(GCC_TOOLCHAIN) \
		CC=$(GCC_EXECUTABLE) \
		CXX=$(GXX_EXECUTABLE) \
		CXXFLAGS="-static-libstdc++ -static-libgcc" \
		CFLAGS="-static-libgcc" \
		--enable-shared=no --enable-cxx11 )


#linux
llvm-setup-release:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-release
	(cd $(LLVM_SOURCE_DIR)/build-release; \
		../configure --enable-targets=x86_64  --enable-optimized --enable-assertions \
		--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR) \
		--with-gcc-toolchain=$(GCC_TOOLCHAIN) \
		CC=$(GCC_EXECUTABLE) \
		CXX=$(GXX_EXECUTABLE) \
		CXXFLAGS="-static-libstdc++ -static-libgcc" \
		CFLAGS="-static-libgcc" \
		--enable-shared=no --enable-cxx11 )




boostbuild2-build:
	(cd $(BOOST_BUILD_SOURCE_DIR); ./bootstrap.sh; ./b2 toolset=gcc install --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR) --ignore-site-config)


gmp-build:
	(cd $(GMP_SOURCE_DIR); make install)







llvm-rpath-fix-debug:
	echo Do nothing


llvm-rpath-fix-release:
	echo Do nothing

boost-rpath-fix:
	echo Do nothing

readline-rpath-fix:
	echo Do nothing

zlib-rpath-fix:
	echo Do nothing

expat-rpath-fix:
	echo Do nothing

gmp-rpath-fix:
	echo Do nothing

endif


############################################################
#
# darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG
#
##

ifeq ($(TARGET_OS),darwin)

export RPATH_RELEASE_FIX = @executable_path/../Resources/externals/release/lib
export RPATH_DEBUG_FIX = @executable_path/../Resources/externals/debug/lib
export RPATH_COMMON_FIX = @executable_path/../Resources/externals/common/lib


#darwin
llvm-setup-debug:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-debug
	(cd $(LLVM_SOURCE_DIR)/build-debug; \
		../configure --enable-targets=x86_64 \
			--enable-debug-symbols --enable-debug-runtime \
			--enable-cxx11 \
			--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR);)

#darwin
llvm-setup-release:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-release
	(cd $(LLVM_SOURCE_DIR)/build-release; \
		../configure --enable-targets=x86_64  --enable-optimized --enable-assertions  \
			--enable-cxx11 \
			--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR);)

gmp-build:
	(cd $(GMP_SOURCE_DIR); make install)
#	(cd $(GMP_SOURCE_DIR); source fixlibgmpxx.sh)   # fixes libgmpxx so that it uses libc++ on OS X


boostbuild2-build:
	(cd $(BOOST_BUILD_SOURCE_DIR); ./bootstrap.sh; ./b2 toolset=clang-darwin install --prefix=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR) --ignore-site-config)





gmp-rpath-fix:
	install_name_tool -id $(RPATH_COMMON_FIX)/libgmp.dylib $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR)/libgmp.dylib
	install_name_tool -id $(RPATH_COMMON_FIX)/libgmpxx.dylib $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR)/libgmpxx.dylib

zlib-rpath-fix:
	install_name_tool -id $(RPATH_COMMON_FIX)/libz.1.dylib $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR)/libz.1.dylib

#
# On OS X you need to change the write privilages of the readline library - go figure
#
readline-rpath-fix:
	chmod u+w $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR)/libreadline.$(READLINE_VERSION).dylib
	install_name_tool -id $(RPATH_COMMON_FIX)/libreadline.$(READLINE_VERSION).dylib $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR)/libreadline.$(READLINE_VERSION).dylib

expat-rpath-fix:
	install_name_tool -id $(RPATH_COMMON_FIX)/libexpat.1.dylib $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR)/libexpat.1.dylib



llvm-rpath-fix-release:
#	-install_name_tool -id $(RPATH_RELEASE_FIX)/libLLVM-$(LLVM_VERSION).dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libLLVM-$(LLVM_VERSION).dylib
#	-install_name_tool -id $(RPATH_RELEASE_FIX)/libclang.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libclang.dylib


llvm-rpath-fix-debug:
#	-install_name_tool -id $(RPATH_DEBUG_FIX)/libLLVM-$(LLVM_VERSION).dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libLLVM-$(LLVM_VERSION).dylib
#	-install_name_tool -id $(RPATH_DEBUG_FIX)/libclang.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libclang.dylib




boost-rpath-fix:
	echo Do nothing



#
#	echo The following sets up the libraries so that clasp can find them and so that they can find each other
#	echo Fixing rpaths for release boost libraries
#	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_program_options.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_program_options.dylib
#	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_iostreams.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_iostreams.dylib
#	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_regex.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_regex.dylib
#	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_filesystem.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_filesystem.dylib
#	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_date_time.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_date_time.dylib
#	-install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_mpi.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_mpi.dylib
#	-install_name_tool -change libboost_serialization.dylib $(RPATH_RELEASE_FIX)/libboost_serialization.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_mpi.dylib
##	-install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_thread.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_thread.dylib
#	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_serialization.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_serialization.dylib
##	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_python.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_python.dylib
#	install_name_tool -id $(RPATH_RELEASE_FIX)/libboost_system.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_system.dylib
##	install_name_tool -change libboost_system.dylib $(RPATH_RELEASE_FIX)/libboost_system.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_thread.dylib
#	install_name_tool -change libboost_system.dylib $(RPATH_RELEASE_FIX)/libboost_system.dylib $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR)/libboost_filesystem.dylib
#	echo Fixing rpaths for debug boost libraries
#	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_program_options.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_program_options.dylib
#	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_iostreams.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_iostreams.dylib
#	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_regex.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_regex.dylib
#	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_filesystem.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_filesystem.dylib
#	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_date_time.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_date_time.dylib
#	-install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_mpi.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_mpi.dylib
#	-install_name_tool -change libboost_serialization.dylib $(RPATH_DEBUG_FIX)/libboost_serialization.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_mpi.dylib
##	-install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_thread.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_thread.dylib
#	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_serialization.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_serialization.dylib
##	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_python.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_python.dylib
#	install_name_tool -id $(RPATH_DEBUG_FIX)/libboost_system.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_system.dylib
##	install_name_tool -change libboost_system.dylib $(RPATH_DEBUG_FIX)/libboost_system.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_thread.dylib
#	install_name_tool -change libboost_system.dylib $(RPATH_DEBUG_FIX)/libboost_system.dylib $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR)/libboost_filesystem.dylib
#


endif








############################################################
#
# kraken kraken kraken kraken kraken kraken kraken kraken kraken
#
##

ifeq ($(TARGET_OS),kraken)
subAll sa:
	make boost-jam
	make boost
	make expat
	make readline
	make subBundle
#	-make ez_setup
#	-make pyOpenGl-cleanBuild


subClean:
	make boost-jam-clean
	make boost-clean
	make expat-clean



boost-jam:
	(cd $(BJAM_SOURCE_DIR); sh ./build.sh $(BOOST_TOOLSET))
	install -d $(OS_BUILDTOP)/bin
	install -c $(BJAM) $(OS_BUILDTOP)/bin


boost-jam-clean:
	-(cd $(BJAM_SOURCE_DIR); rm -rf $(BJAM_EXE_LOCAL_DIR) bootstrap)



boost-fresh:
	(cd $(BOOST_SOURCE_DIR); \
		$(BJAM) -j$(COMPILE_PROCESSORS) -a \
			-d+2 \
			--toolset=$(BOOST_TOOLSET) \
			--prefix=$(OS_BUILDTOP) \
			--with-filesystem \
			--with-date_time\
			--with-serialization \
			--with-program_options \
			--with-mpi \
			--with-thread \
			--with-regex \
			--debug-configuration \
			--ignore-site-config \
			link=static \
			install \
			2>&1 | tee ../logs/_boost.log )
	make boost-rpath-fix

boost-build:
	(cd $(BOOST_SOURCE_DIR); \
		$(BJAM) -j$(COMPILE_PROCESSORS) \
			-d+2 \
			--toolset=$(BOOST_TOOLSET) \
			--prefix=$(OS_BUILDTOP) \
			--with-filesystem \
			--with-date_time\
			--with-serialization \
			--with-program_options \
			--with-mpi \
			--with-thread \
			--with-regex \
			--debug-configuration \
			--ignore-site-config \
			link=static \
			install \
			2>&1 | tee ../logs/_boost.log )
	make boost-rpath-fix

boost-n:
	(cd $(BOOST_SOURCE_DIR); \
		$(BJAM) -j$(COMPILE_PROCESSORS) \
			-n \
			-d+2 \
			--toolset=$(BOOST_TOOLSET) \
			--prefix=$(OS_BUILDTOP) \
			--with-filesystem \
			--with-date_time\
			--with-serialization \
			--with-program_options \
			--with-mpi \
			--with-regex \
			--with-thread \
			--ignore-site-config \
			link=static \
			install )



boost-rpath-fix:
	echo Nothing to fix

boost-clean:
	-(cd $(BOOST_SOURCE_DIR); $(BJAM) --toolset=$(BOOST_TOOLSET) --cleanAll clean --ignore-site-config)



expat-build:
	(cd $(EXPAT_SOURCE_DIR); make -j1 install)

expat-clean:
	-(cd $(EXPAT_SOURCE_DIR); make clean )


readline-clean:
	-(cd $(READLINE_SOURCE_DIR); make clean )

subBundle sb:
	install -d $(CLASP_APP_LIB_DIR)
	install -d $(OS_BUILDTOP)/lib
	install -c jamfile.linux $(OS_BUILDTOP)/lib/jamfile.jam
	install -c $(OS_BUILDTOP)/lib/* $(CLASP_APP_LIB_DIR)





endif




#
# To fix python so that it compiles on os x without barfing when it tries to handle unicodedata module
# make entries in Makefile.pre and Makefile.pre.in for compileall.py ignore errors
#
#
unexport	PYTHONPATH
unexport	PYTHONHOME
python-rpath-fix:
	cp $(PYTHON_SOURCE_DIR)/configure.in $(PYTHON_SOURCE_DIR)/configure.in.orig
	sed 's/arch_only ppc/arch_only i386/g' $(PYTHON_SOURCE_DIR)/configure.in.orig >$(PYTHON_SOURCE_DIR)/configure.in


python:
	make python-clean
	make python-config
	make python-compile


python-config:
	(cd $(PYTHON_SOURCE_DIR); \
		./configure \
			--enable-framework \
			--enable-unicode=ucs2 \
			--enable-universalsdk \
			--prefix=$(EXTERNALS_DIR) 2>&1 | tee ../logs/_python-config.log;\
	)



python-compile:
	make -j 1 -C $(PYTHON_SOURCE_DIR) frameworkinstall 2>&1 | tee ../logs/_python-compile.log

python-clean:
	-make -C $(PYTHON_SOURCE_DIR) clean


#
# PyOpenGL
#
#


pyOpenGl-all:
	-make pyOpenGl-clean
	-make pyOpenGl-build
	-make pyOpenGl-install

pyOpenGl-cleanBuild:
	-make pyOpenGl-clean
	-make pyOpenGl-build

pyOpenGl-clean:
	-(cd $(PYOPENGL_SOURCE_DIR); python setup.py clean )

pyOpenGl-build:
	-(cd $(PYOPENGL_SOURCE_DIR); python setup.py build )

pyOpenGl-install:
	-(cd $(PYOPENGL_SOURCE_DIR); python setup.py install )

#
#
# wxPython
#
#
wxPython-all:
	-make wxPython-nuke
	-make wxPython-create
	-make wxPython-config
	echo GOING INTO wxPython-wxWidgets
	-make wxPython-wxWidgets
	echo GOING INTO wxPython-python
	-make wxPython-wxPython
	echo GOING INTO wxPython-install
	-make wxPython-install

wxPython-rest:
	echo GOING INTO wxPython-wxWidgets
	-make wxPython-wxWidgets
	echo GOING INTO wxPython-python
	-make wxPython-wxPython
	echo GOING INTO wxPython-install


wxPython-nuke:
	-rm -rf $(WXPYTHON_SOURCE_DIR)/macbuild

wxPython-create:
	-(cd $(WXPYTHON_SOURCE_DIR); mkdir -p macbuild)

wxPython-config:
	-(cd $(WXPYTHON_SOURCE_DIR)/macbuild; \
		../configure --prefix $(EXTERNALS_DIR)\
			--enable-monolithic \
			--with-mac \
			--enable-unicode \
			--with-open-gl\
	)

wxPython-wxWidgets:
	-(cd $(WXPYTHON_SOURCE_DIR)/macbuild; \
		make -j $(COMPILE_PROCESSORS);\
	)

#		make -j $(COMPILE_PROCESSORS) -C contrib/src/gizmos\
#		make -j $(COMPILE_PROCESSORS) -C contrib/src/stc;\

#working
#WX_CONFIG=$(EXTERNALS_DIR)/bin/wx_config;


export WXWIN=$(WXPYTHON_SOURCE_DIR)
export WX_CONFIG=$(EXTERNALS_DIR)/bin/wx-config

#
#  Took out these options (--inplace --debug ) and now it compiles?!?!
#
wxPython-wxPython:
	( echo WX_CONFIG==== $(WX_CONFIG); \
		cd $(WXPYTHON_SOURCE_DIR)/wxPython;\
		python setup.py build_ext \
				WX_CONFIG=$(WX_CONFIG)\
				BUILD_STC=1\
				BUILD_GLCANVAS=1;\
	)


wxPython-install:
	-(cd $(WXPYTHON_SOURCE_DIR)/macbuild; make install)

wxPython-clean:
	make wxPython-nuke
	(cd $(WXPYTHON_SOURCE_DIR)/wxPython; python setup.py clean)
