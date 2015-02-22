This project aims to experiment with cmake's `ExternalProject` to build an ARM toolchain.

Prerrequisites:

    sudo apt-get install git cmake build-essential texinfo

To compile and install issue the following:

    git clone https://github.com/tarc/lm4f-cross-tools.git
    cd lm4ftools
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=$HOME ..
    make
    make install

To build Stellaris Ware to test the newly generated toolchain, unpack it in your homedir, reconfigure from the build dir and make it again:

    cmake -DBUILD_STELLARIS_WARE=ON ..
    make

If everything went OK, there should be a new directory `$HOME/lm-cross-tools` with a bare-bone toolchain for the Stellaris LM4F120 LaunchPad Evaluation Kit.
