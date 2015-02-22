This project aims to experiment with cmake's `ExternalProject` to build an ARM toolchain.

### Prerequisites

    sudo apt-get install git cmake build-essential texinfo libreadline-dev libusb-1.0-0-dev

### Compilation

To compile and install issue the following:

    git clone https://github.com/tarc/lm4f-cross-tools.git
    cd lm4ftools
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=$HOME ..
    make
    make install

If everything went OK, there should be a new directory `$HOME/lm-cross-tools` with a bare-bone toolchain for the Stellaris LM4F120 LaunchPad Evaluation Kit.

### Build Stellaris Ware

In order to build Stellaris Ware to test the newly generated toolchain, unpack it in your homedir, reconfigure from the build dir and make it again:

    cmake -DBUILD_STELLARIS_WARE=ON ..
    make
