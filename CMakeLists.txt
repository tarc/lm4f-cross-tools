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
	PREFIX cross-tools
	URL http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.bz2
	URL_HASH MD5=e0f71a7b2ddab0f8612336ac81d9636b
	CONFIGURE_COMMAND <SOURCE_DIR>/configure
		--prefix=<INSTALL_DIR>
		--target=${CLFS_TARGET}
		--with-sysroot=<INSTALL_DIR>/${CLFS_TARGET}
		--disable-nls
		--disable-multilib && make configure-host
	)
