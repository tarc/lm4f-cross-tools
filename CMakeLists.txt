cmake_minimum_required (VERSION 2.8)

set (CLFS_FLOAT softfp)
set (CLFS_FPU fpv4-sp-d16)
set (CLFS_HOST x86_64-cross-linux-gnu)
set (CLFS_TARGET arm-none-eabi)
set (CLFS_ARCH arm)
set (CLFS_ARM_ARCH armv7-m)

include (ExternalProject)

ExternalProject_Add (
	binutils	
	URL http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.bz2
	CONFIGURE_COMMAND <SOURCE_DIR>/configure
		--prefix=<INSTALL_DIR>
		--target=${CLFS_TARGET}
		--disable-nls
		--disable-multilib && make configure-host
	)
