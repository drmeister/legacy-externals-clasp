**externals-clasp**
===============

Clasp can be found at:   https://github.com/drmeister/clasp

These are the external libraries that Clasp depends on.<br>
If there are legal issues with incorporating these libraries in this repository please tell me and I will fix it.<br>
They are all publically available on the internet.

Libraries that Clasp depends on.

To build everything from within the top level directory do the following.

1) Copy local.config.darwin or local.config.linux to local.config

2) Edit local.config (ignored by the git repo) and configure it for your system

3) make

The libraries are built and put into the $PREFIX (see local.config) directory

Other useful make targets:

make setup - configures all libraries<br>
make subAll - makes all libraries


