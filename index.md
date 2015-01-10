---
layout: index
---
This project aims to experiment with cmake's `ExternalProject` to build an ARM toolchain.

To compile and install, unpack Stellaris Ware in your homedir and issue the following:

    git clone https://github.com/tarc/lm4f-cross-tools.git
    cd lm4ftools
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=$HOME ..
    make
    make install

If everything went OK, there should be a new directory `$HOME/lm-cross-tools` with a bare-bone toolchain for the Stellaris LM4F120 LaunchPad Evaluation Kit.
