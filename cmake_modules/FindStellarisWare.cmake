set (CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} $ENV{HOME}/stellarisware)

find_path (StellarisWare_PATH
	NAMES inc/lm4f120h5qr.h)

include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (StellarisWare DEFAULT_MSG
	StellarisWare_PATH)
