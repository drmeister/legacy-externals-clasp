**externals-clasp**
===============

Update Feb 5, 2015:   **NOTE:  EXTERNALS_BUILD_TARGET_DIR is no longer required in local.config - I moved the build directory into the externals-clasp directory hierarchy to ensure that "make clean" was safe and could not destroy user files if this environment variable was set incorrectly.**

Clasp can be found at:   https://github.com/drmeister/clasp

These are the external libraries that Clasp depends on. If there are legal issues with incorporating these libraries in this repository please tell me and I will fix it.  All of these libraries are publically available on the internet.

I am working to eliminate the need for externals-clasp when installing clasp and rely on standard libraries that are shipped with respective operating system distributions or downloadable from the internet.  Currently externals-clasp incorporates a few libraries that have been patched to add features that Clasp requires.

**Building externals-clasp**

_You need to have gcc 4.8 or higher to build externals-clasp._

To build everything from within the top level directory (externals-clasp/) do the following.

1) Copy local.config.darwin or local.config.linux to local.config

2) Edit local.config and configure it for your system<br>
  The following configuration variables are important:
  
| Variable  |   Description 
| ------------- | --------------|
|**TARGET_OS**                    |Currently either _linux_ or _darwin_|
|**PJOBS**                        |The number of processors you have available to build with|
|**GCC_TOOLCHAIN**                |Important on Linux systems. | 
|                                 |gcc and g++ must be found in $(**GCC_TOOLCHAIN**)/bin/ |
|                                 |On a linux system with an up-to-date (>= 4.8) gcc/g++ you can use /usr |
|**GCC_EXECUTABLE**               |Set this if the gcc you use is NOT found at $(**GCC_TOOLCHAIN**)/bin/gcc |
|**GXX_EXECUTABLE**               |Set this if the g++ you use is NOT found at $(**GCC_TOOLCHAIN**)/bin/g++ |
  
3) Type:  _make_    - this will download llvm/clang, build everything and install it in $(**EXTERNALS_BUILD_TARGET_DIR**)

4) Go to the Clasp library and configure and build it.


## On OS X
You need to install automake and libtool<br>
brew install automake<br>
brew install libtool<br>
brew install pkg-config<br>
brew install autoconf<br>



The libraries are built and put into the $PREFIX (see local.config) directory

Other useful make targets:<br>
make            - this is the same as:  make clean; make setup; make subAll<br>
make setup      - configures all libraries<br>
make subAll     - makes all libraries<br>
make clean      - Clean out all built files under this directory, but not the $PREFIX target directory.<br>
make llvm-debug - Build the debug version of the LLVM library.


