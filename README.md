**externals-clasp**
===============

Clasp can be found at:   https://github.com/drmeister/clasp

These are the external libraries that Clasp depends on. If there are legal issues with incorporating these libraries in this repository please tell me and I will fix it.  All of these libraries are publically available on the internet.

To build everything from within the top level directory (externals-clasp/) do the following.

1) Copy local.config.darwin or local.config.linux to local.config

2) Edit local.config and configure it for your system

3) make

4) Go to the Clasp library and configure and build it.

The libraries are built and put into the $PREFIX (see local.config) directory

Other useful make targets:

make setup      - configures all libraries<br>
make subAll     - makes all libraries<br>
make clean      - Clean out all built files under this directory, but not the $PREFIX target directory.<br>
make llvm-debug - Build the debug version of the LLVM library.

