cmake_minimum_required (VERSION 3.1)

project (lm4fCrossTools)

option (BUILD_STELLARIS_WARE
	"Search and build Texas' Stellaris Ware" ON)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
	"${CMAKE_SOURCE_DIR}/cmake_modules/")

set (LM_FLOAT hard)
set (LM_FPU fpv4-sp-d16)
set (LM_HOST x86_64-cross-linux-gnu)
set (LM_TARGET arm-none-eabi)
set (LM_ARCH arm)
set (LM_ARM_ARCH armv7-m)
set (LM_ARM_CPU cortex-m4)

set (LM_PREFIX cross-tools)

include (ExternalProject)

ExternalProject_Add (
	lm4tools
	PREFIX lm4tools
	GIT_REPOSITORY https://github.com/utzig/lm4tools
	CONFIGURE_COMMAND ""
	BUILD_IN_SOURCE 1
	BUILD_COMMAND
		make -C lm4flash
	INSTALL_COMMAND
		COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/lm4flash/lm4flash <INSTALL_DIR>
	)

ExternalProject_Get_Property(lm4tools install_dir) 
set (LM4TOOLS_INSTALL_DIR ${install_dir})

ExternalProject_Add (
	binutils
	PREFIX cross-tools
	URL http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.bz2
	URL_HASH MD5=e0f71a7b2ddab0f8612336ac81d9636b
	CONFIGURE_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		<SOURCE_DIR>/configure
			--prefix=<INSTALL_DIR>
			--target=${LM_TARGET}
			--with-sysroot=<INSTALL_DIR>/${LM_TARGET}
			--disable-nls
			--enable-multilib &&
		make configure-host
	BUILD_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make all
	INSTALL_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make install
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
	gcc-minimal
	PREFIX cross-tools
	DEPENDS binutils mpfr gmp mpc
	URL ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2
	URL_HASH MD5=4df8ee253b7f3863ad0b86359cd39c43
	CONFIGURE_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		<SOURCE_DIR>/configure
			--prefix=<INSTALL_DIR>
			--with-sysroot=<INSTALL_DIR>/${LM_TARGET}
			--build=${LM_HOST}
			--host=${LM_HOST}
			--target=${LM_TARGET}
			--disable-nls
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
			--enable-languages=c
			--disable-multilib
			--with-arch=${LM_ARM_ARCH}
			--with-cpu=${LM_ARM_CPU}
			--with-float=${LM_FLOAT}
			--with-fpu=${LM_FPU}
			--with-mode=thumb
			--with-no-thumb-interwork
	BUILD_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make all-gcc
	INSTALL_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make install-gcc
	)

ExternalProject_Get_Property(gcc-minimal source_dir) 
set (GCC_SOURCE_DIR ${source_dir})

ExternalProject_Add_Step (
	gcc-minimal copy_mpfr
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${MPFR_SOURCE_DIR} ${GCC_SOURCE_DIR}/mpfr
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add_Step (
	gcc-minimal copy_gmp
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${GMP_SOURCE_DIR} ${GCC_SOURCE_DIR}/gmp
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add_Step (
	gcc-minimal copy_mpc
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${MPC_SOURCE_DIR} ${GCC_SOURCE_DIR}/mpc
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add (
	newlib
	PREFIX cross-tools
	DEPENDS gcc-minimal
	URL ftp://sourceware.org/pub/newlib/newlib-2.2.0.tar.gz
	URL_HASH MD5=f2294ded26e910a73637ecdfbdd1ef05
	CONFIGURE_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		<SOURCE_DIR>/configure
			--prefix=<INSTALL_DIR>
			--with-sysroot=<INSTALL_DIR>/${LM_TARGET}
			--build=${LM_HOST}
			--host=${LM_HOST}
			--target=${LM_TARGET}
			--enable-multilib
	BUILD_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make all
	INSTALL_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make install
	)

ExternalProject_Get_Property(newlib source_dir) 
set (NEWLIB_SOURCE_DIR ${source_dir})

ExternalProject_Add (
	gcc
	PREFIX cross-tools
	DEPENDS newlib gcc-minimal
	URL ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2
	URL_HASH MD5=4df8ee253b7f3863ad0b86359cd39c43
	CONFIGURE_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		<SOURCE_DIR>/configure
			--prefix=<INSTALL_DIR>
			--with-sysroot=<INSTALL_DIR>/${LM_TARGET}
			--build=${LM_HOST}
			--host=${LM_HOST}
			--target=${LM_TARGET}
			--disable-nls
			--disable-shared
			--with-newlib
			--disable-threads
			--enable-languages=c,c++
			--with-arch=${LM_ARM_ARCH}
			--with-cpu=${LM_ARM_CPU}
			--with-float=${LM_FLOAT}
			--with-fpu=${LM_FPU}
			--with-mode=thumb
			--with-no-thumb-interwork
	BUILD_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make all
	INSTALL_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make install
	)

ExternalProject_Get_Property(gcc source_dir) 
set (GCC_FINAL_SOURCE_DIR ${source_dir})
ExternalProject_Get_Property(gcc install_dir) 
set (GCC_FINAL_INSTALL_DIR ${install_dir})

ExternalProject_Add_Step (
	gcc copy_mpfr
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${MPFR_SOURCE_DIR} ${GCC_FINAL_SOURCE_DIR}/mpfr
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add_Step (
	gcc copy_gmp
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${GMP_SOURCE_DIR} ${GCC_FINAL_SOURCE_DIR}/gmp
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add_Step (
	gcc copy_mpc
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${MPC_SOURCE_DIR} ${GCC_FINAL_SOURCE_DIR}/mpc
	DEPENDEES download
	DEPENDERS configure
	)

ExternalProject_Add (
	gdb	
	PREFIX cross-tools
	DEPENDS gcc
	URL ftp://ftp.gnu.org/gnu/gdb/gdb-7.8.tar.gz
	URL_HASH MD5=38d816d641093db2e13ba284e26090b4
	CONFIGURE_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		<SOURCE_DIR>/configure
			--prefix=<INSTALL_DIR>
			--target=${LM_TARGET}
			--with-sysroot=<INSTALL_DIR>/${LM_TARGET}
			--enable-multilib
	BUILD_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make all
	INSTALL_COMMAND
		hash -r &&
		unset CFLAGS &&
		LC_ALL=POSIX
		PATH=<INSTALL_DIR>/bin:/bin:/usr/bin
		make install
	)

if (BUILD_STELLARIS_WARE)
	find_package(StellarisWare REQUIRED)

	file (GLOB MAKEDEFS_PATCH_FILE ${CMAKE_CURRENT_SOURCE_DIR}/makedefs.patch)

	ExternalProject_Add (
		stellarisware	
		PREFIX stellarisware
		DEPENDS gcc
		URL ${StellarisWare_PATH}
		PATCH_COMMAND
			patch < ${MAKEDEFS_PATCH_FILE}
		CONFIGURE_COMMAND
			make clean
		BUILD_IN_SOURCE 1
		BUILD_COMMAND ""
			hash -r &&
			unset CFLAGS &&
			LC_ALL=POSIX
			PATH=${GCC_FINAL_INSTALL_DIR}/bin:/bin:/usr/bin
			make
		INSTALL_COMMAND ""
		)

endif ()

configure_file (
	lm4fCrossToolsConfig.cmake.in
	lm4fCrossToolsConfig.cmake
	)
