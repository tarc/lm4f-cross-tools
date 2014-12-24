cmake_minimum_required (VERSION 2.8.12)

set (CLFS_FLOAT softfp)
set (CLFS_FPU fpv4-sp-d16)
set (CLFS_HOST x86_64-cross-linux-gnu)
set (CLFS_TARGET arm-none-eabi)
set (CLFS_ARCH arm)
set (CLFS_ARM_ARCH armv7-m)

set (CLFS_PREFIX cross-tools)

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

ExternalProject_Add (
	mpfr
	PREFIX cross-tools
	URL http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.bz2
	URL_HASH MD5=ee2c3ac63bf0c2359bf08fc3ee094c19
	CONFIGURE_COMMAND ""
	BUILD_COMMAND ""
	INSTALL_COMMAND ""
	)

ExternalProject_Get_Property(mpfr source_dir) 
set (MPFR_SOURCE_DIR ${source_dir})

ExternalProject_Add (
	gmp
	PREFIX cross-tools
	URL https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2
	URL_HASH MD5=b7ff2d88cae7f8085bd5006096eed470
	CONFIGURE_COMMAND ""
	BUILD_COMMAND ""
	INSTALL_COMMAND ""
	)

ExternalProject_Get_Property(gmp source_dir) 
set (GMP_SOURCE_DIR ${source_dir})

ExternalProject_Add (
	mpc
	PREFIX cross-tools
	URL ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz
	URL_HASH SHA1=5072d82ab50ec36cc8c0e320b5c377adb48abe70
	CONFIGURE_COMMAND ""
	BUILD_COMMAND ""
	INSTALL_COMMAND ""
	)

ExternalProject_Get_Property(mpc source_dir) 
set (MPC_SOURCE_DIR ${source_dir})

ExternalProject_Add (
	gcc
	PREFIX cross-tools
	DEPENDS mpfr gmp mpc binutils
	URL ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2
	URL_HASH MD5=4df8ee253b7f3863ad0b86359cd39c43
	CONFIGURE_COMMAND <SOURCE_DIR>/configure
		--prefix=<INSTALL_DIR>
		--with-sysroot=<INSTALL_DIR>/${CLFS_TARGET}
		--target=${CLFS_TARGET}
		--disable-nls
		--build=${CLFS_HOST}
		--host=${CLFS_HOST}
		--target=${CLFS_TARGET}
		--disable-shared
		--without-headers
		--with-newlib
		--disable-decimal-float
		--disable-libgomp
		--disable-libmudflap
		--disable-libssp
		--disable-libatomic
		--disable-libquadmath
		--disable-threads
		--enable-languages=c,c++
		--disable-multilib
		--with-mpfr-include=<SOURCE_DIR>/mpfr/src
		--with-mpfr-lib=<BINARY_DIR>/mpfr/src/.libs
		--with-arch=${CLFS_ARM_ARCH}
		--with-float=${CLFS_FLOAT}
		--with-fpu=${CLFS_FPU}
		--with-mode=thumb
	BUILD_COMMAND
		make all-gcc all-target-libgcc
	INSTALL_COMMAND make
		make install-gcc install-target-libgcc
	)

ExternalProject_Get_Property(gcc source_dir) 
set (GCC_SOURCE_DIR ${source_dir})

ExternalProject_Add_Step (
	gcc copy_mpfr
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${MPFR_SOURCE_DIR} ${GCC_SOURCE_DIR}/mpfr
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add_Step (
	gcc copy_gmp
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${GMP_SOURCE_DIR} ${GCC_SOURCE_DIR}/gmp
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add_Step (
	gcc copy_mpc
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${MPC_SOURCE_DIR} ${GCC_SOURCE_DIR}/mpc
	DEPENDEES download
	DEPENDERS configure
	)
