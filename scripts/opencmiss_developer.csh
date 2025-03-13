#!/bin/csh -f
# Sets up environment variables, paths etc. for an OpenCMISS developer
#

setenv HOST `hostname -s`
setenv sysname `uname -s`
setenv machine `uname -m`

# Make sure OpenCMISS_ROOT is an absolute path
if ( $?OpenCMISS_ROOT ) then
    if ( -r ${OpenCMISS_ROOT} ) then
      setenv OpenCMISS_ROOT `cd ${OpenCMISS_ROOT} && pwd `
    else
      echo "OpenCMISS: OpenCMISS_ROOT directory does not exist."
    endif
else
    echo "OpenCMISS: OpenCMISS_ROOT is not defined."
endif

# Make sure OpenCMISS_INSTALL_ROOT is an absolute path
if ( $?OpenCMISS_INSTALL_ROOT ) then
    if ( -r ${OpenCMISS_INSTALL_ROOT} ) then
      setenv OpenCMISS_INSTALL_ROOT `cd ${OpenCMISS_INSTALL_ROOT} && pwd `
    else
      echo "OpenCMISS: OpenCMISS_INSTALL_ROOT directory does not exist."
    endif
else
    setenv OpenCMISS_INSTALL_ROOT ${OpenCMISS_ROOT}/install	
endif

# Set defaults if not defined
if ( ! $?OpenCMISS_SETUP_INTEL ) then
    setenv OpenCMISS_SETUP_INTEL true
endif
if ( ! $?OpenCMISS_SETUP_TOTALVIEW ) then
    setenv OpenCMISS_SETUP_TOTALVIEW true
endif
if ( ! $?OpenCMISS_SETUP_CUDA ) then
    setenv OpenCMISS_SETUP_CUDA true
endif
if ( ! $?OpenCMISS_SETUP_LATEX ) then
    setenv OpenCMISS_SETUP_LATEX true
endif
if ( ! $?OpenCMISS_SETUP_PYTHONPATH ) then
    setenv OpenCMISS_SETUP_PYTHONPATH true
endif
if ( ! $?OpenCMISS_SETUP_GITPROMPT ) then
    setenv OpenCMISS_SETUP_GITPROMPT true
endif
if ( ! $?OpenCMISS_MPI_BUILD_TYPE ) then
    setenv OpenCMISS_MPI_BUILD_TYPE system
endif
if ( ! $?OpenCMISS_BUILD_TYPE ) then
    setenv OpenCMISS_BUILD_TYPE release
endif

switch ( ${sysname} )
    case AIX:

        setenv PROCESSOR_TYPE="`lsattr -El proc0 | grep "Processor type" | tr -s ' ' | cut -f2 -d" "`"
	switch ( ${PROCESSOR_TYPE} )
	    case PowerPC_POWER7:
		setenv OpenCMISS_ARCHNAME power7-aix
		breaksw
	    case PowerPC_POWER6:
		setenv OpenCMISS_ARCHNAME power6-aix
		breaksw
	    case PowerPC_POWER5:
		setenv OpenCMISS_ARCHNAME power5-aix
		breaksw
	    case PowerPC_POWER4:
		setenv OpenCMISS_ARCHNAME power4-aix
		breaksw
	    default:
		echo "OpenCMISS: The processor architecture of ${PROCESSOR_TYPE} is unknown for AIX."
		setenv OpenCMISS_ARCHNAME unknown-aix
	endsw
	unsetenv PROCESSOR_TYPE
   	    
    case Linux:
	
	setenv OpenCMISS_ARCHNAME ${machine}-linux

	#Try and work out what linux distribution we are on
	if ( -r "/etc/SuSE-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION suse
	    setenv OpenCMISS_SUSE_RELEASE `grep "VERSION" /etc/SuSE-release | cut -f2 -d"="`.`grep "PATCHLEVEL" /etc/SuSE-release | cut -f2 -d"="`
	else if ( -r "/etc/redhat-release" ) then
	    #Work out if it is Red Hat, Fedora or Scientific Linux
            if ( `grep "Red Hat Enterprise" /etc/redhat-release` !~ "" ) then
		setenv OpenCMISS_LINUX_DISTRIBUTION redhat
	        setenv OpenCMISS_REDHAT_RELEASE `cat /etc/redhat-release | cut -f7 -d" "`
            else if ( `grep "Fedora" /etc/redhat-release` !~ "" ) then
		setenv OpenCMISS_LINUX_DISTRIBUTION fedora
	        setenv OpenCMISS_FEDORA_RELEASE `cat /etc/fedora-release | cut -f3 -d" "`
            else if ( `grep "Scientific Linux" /etc/redhat-release` !~ "" ) then
		setenv OpenCMISS_LINUX_DISTRIBUTION scientificlinux
	        setenv OpenCMISS_SCILINUX_RELEASE `cat /etc/fedora-release | cut -f4 -d" " | cut -f1 -d"."`
            else if ( `grep "CentOS" /etc/redhat-release` !~ "" ) then
		setenv OpenCMISS_LINUX_DISTRIBUTION centos
	        setenv OpenCMISS_CENTOS_RELEASE `cat /etc/redhat-release | cut -f4 -d" " | cut -f1 -d"."`
            else 
		echo "OpenCMISS: Can not determine Linux distribution from /etc/redhat-release."
		setenv OpenCMISS_LINUX_DISTRIBUTION unknown
	    endif
	else if ( -r "/etc/redhat_version" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION redhat
	else if ( -r "/etc/fedora-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION fedora
	    setenv OpenCMISS_FEDORA_RELEASE `cat /etc/fedora-release | cut -f3 -d" "`
	else if ( -r "/etc/slackware-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION slackware
	else if ( -r "/etc/slackware-version" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION slackware
	else if ( -r "/etc/lsb-release" ) then
            #Work out if it is Ubuntu or Mint
            if ( `grep "DISTRIB_ID=Ubuntu" /etc/lsb-release` !~ "" ) then
	      setenv OpenCMISS_LINUX_DISTRIBUTION ubuntu
	      setenv OpenCMISS_UBUNTU_RELEASE `grep "DISTRIB_RELEASE" /etc/lsb-release | cut -f2 -d"="`
            else if ( `grep "DISTRIB_ID=LinuxMint" /etc/lsb-release` !~ "" ) then
	      setenv OpenCMISS_LINUX_DISTRIBUTION mint
	      setenv OpenCMISS_MINT_RELEASE `grep "DISTRIB_RELEASE" /etc/lsb-release | cut -f2 -d"="`
            else 
		echo "OpenCMISS: Can not determine Linux distribution from /etc/lsb-release."
		setenv OpenCMISS_LINUX_DISTRIBUTION unknown
	    endif
	else if ( -r "/etc/debian_release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION debian
	else if ( -r "/etc/debian_version" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION debian
	else if ( -r "/etc/mandrake-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION mandrake
	else if ( -r "/etc/yellowdog-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION yellowdog
	else if ( -r "/etc/sun-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION sun
	else if ( -r "/etc/release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION solaris
	else if ( -r "/etc/gentoo-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION gentoo
	else if ( -r "/etc/UnitedLinux-release" ) then
	    setenv OpenCMISS_LINUX_DISTRIBUTION unitedlinux
        else
	    echo "OpenCMISS: Can not read /etc/issue. Linux distribution is unknown."
	    setenv OpenCMISS_LINUX_DISTRIBUTION unknown
	endif
	    
	switch ( ${OpenCMISS_LINUX_DISTRIBUTION} )
	    case ubuntu:
		switch ( ${OpenCMISS_ARCHNAME} )
		    case i686-linux:
			setenv LIBAPI lib
			setenv SYSLIBAPI lib
			setenv BINAPI bin
			setenv INTELAPI ia32
			breaksw
		    case x86_64-linux:
			setenv LIBAPI lib64
			setenv SYSLIBAPI lib
			setenv BINAPI bin64
			setenv INTELAPI intel64
			breaksw
		    default:
			echo "OpenCMISS: Architecture name of ${OpenCMISS_ARCHNAME} is unknown."
                endsw
		breaksw
	    case mint:
		switch ( ${OpenCMISS_ARCHNAME} )
		    case i686-linux:
			setenv LIBAPI lib
			setenv SYSLIBAPI lib
			setenv BINAPI bin
			setenv INTELAPI ia32
			breaksw
		    case x86_64-linux:
			setenv LIBAPI lib64
			setenv SYSLIBAPI lib
			setenv BINAPI bin64
			setenv INTELAPI intel64
			breaksw
		    default:
			echo "OpenCMISS: Architecture name of ${OpenCMISS_ARCHNAME} is unknown."
		endsw
		breaksw
	    default:
		switch ( ${OpenCMISS_ARCHNAME} )
		    case i686-linux:
			setenv LIBAPI lib
			setenv SYSLIBAPI lib
			setenv BINAPI bin
			setenv INTELAPI ia32
			breaksw
		    case x86_64-linux:
			setenv LIBAPI lib64
			setenv SYSLIBAPI lib64
			setenv BINAPI bin64
			setenv INTELAPI intel64
			breaksw
		    default:
			echo "OpenCMISS: Architecture name of ${OpenCMISS_ARCHNAME} is unknown."
		endsw
	endsw
	    
	#Setup intel compilers if defined
	if ( ${OpenCMISS_SETUP_INTEL} == true ) then
	    setenv INTEL_ONEAPI false
	    if ( ! $?INTEL_ROOT ) then
		if ( -d "/opt/intel/oneapi" ) then
		    #New oneAPI intel setup
		    setenv INTEL_ROOT /opt/intel/oneapi
		    setenv INTEL_ONEAPI true
		else
		    setenv INTEL_ROOT /opt/intel
		endif
	    endif	
	    #Add in intel compilers if defined
	    if ( -r "$INTEL_ROOT/setvars.sh" ) then
		#New oneAPI intel setup
		echo "OpenCMISS: Cannot set up new Intel oneAPI variabls with csh at the moment."
		setenv INTEL_ONEAPI true
	    else
		if ( -r "${INTEL_ROOT}/compilers_and_libraries/linux/bin/compilervars.csh" ) then
		    source ${INTEL_ROOT}/compilers_and_libraries/linux/bin/compilervars.csh ${INTELAPI}
		    if ( -r "${INTEL_ROOT}/compilers_and_libraries/linux/mkl/bin/mklvars.csh" ) then
			source ${INTEL_ROOT}/compilers_and_libraries/linux/mkl/bin/mklvars.csh ${INTELAPI}
		    endif
		else
		    #Add in the newer version of the compilers
		    if ( -r "${INTEL_ROOT}/composerxe/bin/compilervars.csh" ) then
			source ${INTEL_ROOT}/composerxe/bin/compilervars.csh ${INTELAPI}
			if ( -r "${INTEL_ROOT}/mkl/bin/mklvars.csh" ) then
			    source ${INTEL_ROOT}/mkl/bin/mklvars.csh ${INTELAPI}
			endif
		    else
			#Add in intel compilers if defined
			if ( -r "${INTEL_ROOT}/bin/compilervars.csh" ) then
			    #Newer version of intel compilers
			    source ${INTEL_ROOT}/bin/compilervars.csh ${INTELAPI}
			    if ( -r "${INTEL_ROOT}/mkl/bin/mklvars.csh" ) then
				source ${INTEL_ROOT}/mkl/bin/mklvars.csh ${INTELAPI}
			    endif
			else
			    #Older version of intel compilers
			    if ( ! $?INTEL_COMPILER_VERSION ) then
				setenv INTEL_COMPILER_VERSION 1.0
			    endif	
			    if ( ! $?INTEL_COMPILER_BUILD ) then
				setenv INTEL_COMPILER_BUILD 1.0
			    endif	
			    if ( -r "${INTEL_ROOT}/Compiler/${INTEL_COMPILER_VERSION}/${INTEL_COMPILER_BUILD}/bin/ifortvars.csh" ) then
				source ${INTEL_ROOT}/Compiler/${INTEL_COMPILER_VERSION}/${INTEL_COMPILER_BUILD}/bin/ifortvars.csh ${INTELAPI}
			    endif
			    if ( -r "${INTEL_ROOT}/Compiler/${INTEL_COMPILER_VERSION}/${INTEL_COMPILER_BUILD}/bin/iccvars.csh" ) then
				source ${INTEL_ROOT}/Compiler/${INTEL_COMPILER_VERSION}/${INTEL_COMPILER_BUILD}/bin/iccvars.csh ${INTELAPI}
			    endif
			endif
		    endif
		endif
		# Setup Intel advisor if it is installed
		if ( -r "${INTEL_ROOT}/advisor/advixe-vars.csh" ) then
		    source ${INTEL_ROOT}/advisor/advixe-vars.csh quiet
		endif
		# Setup Intel inspector if it is installed
		if ( -r "${INTEL_ROOT}/inspector/inspxe-vars.csh" ) then
		    source ${INTEL_ROOT}/inspector/inspxe-vars.csh quiet
		endif
	    endif
	endif

	#Setup totalview if defined
	if ( ${OpenCMISS_SETUP_TOTALVIEW} == true ) then
	    which totalview >& /dev/null
	    if ( $? == 0 ) then
		if ( ! $?TOTALVIEW_PATH ) then
		    setenv TOTALVIEW_PATH1 `which totalview | cut -f2 -d'/'`
		    setenv TOTALVIEW_PATH2 `which totalview | cut -f3 -d'/'`
		    setenv TOTALVIEW_PATH ${TOTALVIEW_PATH1}/${TOTALVIEW_PATH2}
		    unsetenv TOTALVIEW_PATH1
		    unsetenv TOTALVIEW_PATH2
		endif
		if ( ! $?TOTALVIEW_VERSION ) then
		    setenv TOTALVIEW_VERSION `totalview -v | cut -f4 -d' '`
		endif
	    else
		if ( ! $?TOTALVIEW_PATH ) then
		    setenv TOTALVIEW_PATH /opt/toolworks
		endif
		if ( -d ${TOTALVIEW_PATH} ) then    
		    if ( ! $?TOTALVIEW_VERSION ) then
			setenv TOTALVIEW_VERSION1 `ls ${TOTALVIEW_PATH} | grep -i totalview | tail -1 | cut -f2 -d.`
			if ( ${TOTALVIEW_VERSION1} != "" ) then    
			    setenv TOTALVIEW_VERSION2 `ls ${TOTALVIEW_PATH} | grep -i totalview | tail -1 | cut -f3 -d.`
			    if ( ${TOTALVIEW_VERSION2} != "" ) then
				setenv TOTALVIEW_VERSION3 `ls ${TOTALVIEW_PATH} | grep -i totalview | tail -1 | cut -f4 -d.`
				if ( ${TOTALVIEW_VERSION3} != "" ) then    
					setenv TOTALVIEW_VERSION ${TOTALVIEW_VERSION1}.${TOTALVIEW_VERSION2}.${TOTALVIEW_VERSION3}
				endif
				unsetenv TOTALVIEW_VERSION3
			    endif
			    unsetenv TOTALVIEW_VERSION2
			endif
			unsetenv TOTALVIEW_VERSION1
		    endif
		endif
	    endif
	    if ( -d ${TOTALVIEW_PATH} ) then
		if ( ! $?FLEXLM_VERSION ) then
		    setenv FLEXLM_VERSION1 `ls ${TOTALVIEW_PATH} | grep -i flexlm | tail -1 | cut -f2 -d'-'`
		    if ( ${FLEXLM_VERSION1} != "" ) then
			setenv FLEXLM_VERSION2 `ls ${TOTALVIEW_PATH} | grep -i flexlm | tail -1 | cut -f3 -d'-'`
			if ( ${FLEXLM_VERSION2} != "" ) then    
			    setenv FLEXLM_VERSION ${FLEXLM_VERSION1}-${FLEXLM_VERSION2}
			endif	
			unsetenv FLEXLM_VERSION2
		    endif
		    unsetenv FLEXLM_VERSION1
		endif
		#Add in totalview path
		if ( $?TOTALVIEW_VERSION ) then
		    if ( -d "${TOTALVIEW_PATH}/totalview.${TOTALVIEW_VERSION}/bin" ) then
			if ( ! $?PATH ) then
			    setenv PATH ${TOTALVIEW_PATH}/totalview.${TOTALVIEW_VERSION}/bin
		        else
			    setenv PATH ${TOTALVIEW_PATH}/totalview.${TOTALVIEW_VERSION}/bin:${PATH}
			endif
		    endif
		endif	
		#Add in FlexLM path
		if ( $?FLEXLM_VERSION ) then
		    if ( -d "${TOTALVIEW_PATH}/flexlm-${FLEXLM_VERSION}" ) then
			if ( ! $?LM_LICENSE_FILE ) then
			    setenv LM_LICENSE_FILE ${TOTALVIEW_PATH}/flexlm-${FLEXLM_VERSION}
			else
			    setenv LM_LICENSE_FILE ${TOTALVIEW_PATH}/flexlm-${FLEXLM_VERSION}:${LM_LICENSE_FILE}
			endif
		    endif
		endif
	    endif
	endif	

	#Setup cuda if defined
	if ( $?OpenCMISS_SETUP_CUDA ) then
	    which nvcc >& /dev/null		
	    if ( $? == 0 ) then
		setenv CUDA_NVCC_PATH `which nvcc`
		setenv CUDA_BIN_PATH `dirname ${CUDA_NVCC_PATH}`
		setenv CUDA_PATH `dirname ${CUDA_BIN_PATH}`
		setenv CUDA_NVCC_MAJOR_VERSION `nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f1 -d.`
		setenv CUDA_NVCC_MINOR_VERSION `nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f2 -d.`
		setenv CUDA_NVCC_VERSION ${CUDA_NVCC_MAJOR_VERSION}.${CUDA_NVCC_MINOR_VERSION}
		unsetenv CUDA_NVCC_MAJOR_VERSION
		unsetenv CUDA_NVCC_MINOR_VERSION
		unsetenv CUDA_BIN_PATH
	    else
		if ( $?CUDA_PATH ) then
		    setenv CUDA_PATH /usr/local/cuda
		endif
		setenv CUDA_BIN_PATH ${CUDA_PATH}/bin
		if ( -d ${CUDA_PATH} ) then
		    if ( -x ${CUDA_BIN_PATH}/nvcc ) then
			setenv CUDA_NVCC_MAJOR_VERSION `${CUDA_BIN_PATH}/nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f1 -d.`
			setenv CUDA_NVCC_MINOR_VERSION `${CUDA_BIN_PATH}/nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f2 -d.`
		    endif
		    setenv CUDA_NVCC_VERSION ${CUDA_NVCC_MAJOR_VERSION}.${CUDA_NVCC_MINOR_VERSION}
		    unsetenv CUDA_NVCC_MAJOR_VERSION
		    unsetenv CUDA_NVCC_MINOR_VERSION
		else
		    setenv CUDA_NVCC_VERSION unknown
		endif
		unsetenv CUDA_BIN_PATH
	    endif
	    if ( -d ${CUDA_PATH} ) then
		setenv CUDA_PARENT_PATH `dirname ${CUDA_PATH}`
		setenv CUDA_VERSION_BIN_PATH ${CUDA_PARENT_PATH}/cuda-${CUDA_NVCC_VERSION}/bin
		setenv CUDA_VERSION_LIB_PATH ${CUDA_PARENT_PATH}/cuda-${CUDA_NVCC_VERSION}/${LIBAPI}
		if ( -d ${CUDA_VERSION_BIN_PATH} ) then
		    if ( ! $?PATH ) then
			setenv PATH ${CUDA_VERSION_BIN_PATH}
		    else
			setenv PATH ${CUDA_VERSION_BIN_PATH}:${PATH}
		    endif
		endif
		if ( -d ${CUDA_VERSION_LIB_PATH} ) then
		    if ( ! $?LD_LIBRARY_PATH ) then
			setenv LD_LIBRARY_PATH ${CUDA_VERSION_LIB_PATH}
		    else
			setenv LD_LIBRARY_PATH ${CUDA_VERSION_LIB_PATH}:${LD_LIBRARY_PATH}
		    endif
		endif
	    endif
	endif
		
	#Setup toolchain if defined
	if ( $?OpenCMISS_TOOLCHAIN ) then
	    switch ( ${OpenCMISS_TOOLCHAIN} )
		case gnu:
		    which gcc >& /dev/null		
		    if ( $? == 0 ) then
			setenv GNU_GCC_MAJOR_VERSION `gcc -dumpversion | cut -f1 -d.`
			if ( ${GNU_GCC_MAJOR_VERSION} >= 7) then
			    setenv GNU_GCC_MAJOR_VERSION `gcc --version | grep -i gcc | cut -f1 -d. | cut -f3 -d' '`
			    setenv GNU_GCC_MINOR_VERSION `gcc --version | grep -i gcc | cut -f2 -d.`
			else
			    setenv GNU_GCC_MINOR_VERSION `gcc -dumpversion | cut -f2 -d.`
			endif
			setenv C_COMPILER_STRING gnu-C${GNU_GCC_MAJOR_VERSION}.${GNU_GCC_MINOR_VERSION}
			unsetenv GNU_GCC_MAJOR_VERSION    
			unsetenv GNU_GCC_MINOR_VERSION    
		    else
			setenv C_COMPILER_STRING unknown
		    endif
		    which gfortran >& /dev/null		
		    if ( $? == 0 ) then
			setenv GNU_GFORTRAN_MAJOR_VERSION `gfortran -dumpversion | cut -f1 -d.`
			if ( ${GNU_GFORTRAN_MAJOR_VERSION} >= 7) then
			    setenv GNU_GFORTRAN_MAJOR_VERSION `gfortran --version | grep -i fortran | cut -f1 -d. | cut -f4 -d' '`
			    setenv GNU_GFORTRAN_MINOR_VERSION `gfortran --version | grep -i fortran | cut -f2 -d.`
			else
			    setenv GNU_GFORTRAN_MINOR_VERSION `gfortran -dumpversion | cut -f2 -d.`
			endif
			setenv FORTRAN_COMPILER_STRING gnu-F${GNU_GFORTRAN_MAJOR_VERSION}.${GNU_GFORTRAN_MINOR_VERSION}
			unsetenv GNU_GFORTRAN_MAJOR_VERSION    
			unsetenv GNU_GFORTRAN_MINOR_VERSION    
		    else
			setenv FORTRAN_COMPILER_STRING unknown
		    endif
		    breaksw
		case intel:
		    which icc >& /dev/null		
		    if ( $? == 0 ) then
			if ( ${INTEL_ONEAPI} == true ) then
			    setenv INTEL_ICC_MAJOR_VERSION `icc --version | grep ICC | cut -c 11-14`
			else
			    setenv INTEL_ICC_MAJOR_VERSION `icc --version | grep ICC | cut -c 11-12`
			endif
			setenv INTEL_ICC_MINOR_VERSION `icc --version | grep ICC | cut -c 14`
			setenv C_COMPILER_STRING intel-C${INTEL_ICC_MAJOR_VERSION}.${INTEL_ICC_MINOR_VERSION}
			unsetenv INTEL_ICC_MAJOR_VERSION    
			unsetenv INTEL_ICC_MINOR_VERSION    
		    else
			setenv C_COMPILER_STRING unknown
		    endif
		    which ifort >& /dev/null		
		    if ( $? == 0 ) then
			if ( ${INTEL_ONEAPI} == true ) then
			    setenv INTEL_IFORT_MAJOR_VERSION `ifort --version | grep IFORT | cut -c 15-18`
			else
			    setenv INTEL_IFORT_MAJOR_VERSION `ifort --version | grep IFORT | cut -c 15-16`
			endif
			setenv INTEL_IFORT_MINOR_VERSION `ifort --version | grep IFORT | cut -c 18`
			setenv FORTRAN_COMPILER_STRING intel-F${INTEL_IFORT_MAJOR_VERSION}.${INTEL_IFORT_MINOR_VERSION}
			unsetenv INTEL_IFORT_MAJOR_VERSION    
			unsetenv INTEL_IFORT_MINOR_VERSION    
		    else
			setenv FORTRAN_COMPILER_STRING unknown
		    endif
		    breaksw
		default:
		    echo "OpenCMISS: OpenCMISS_TOOLCHAIN of ${OpenCMISS_TOOLCHAIN} is unknown."
		    setenv C_COMPILER_STRING unknown
		    setenv FORTRAN_COMPILER_STRING unknown
	    endsw
	    setenv OpenCMISS_COMPILER_ARCHPATH ${C_COMPILER_STRING}-${FORTRAN_COMPILER_STRING}
	    unsetenv C_COMPILER_STRING
	    unsetenv FORTRAN_COMPILER_STRING
	endif

	# If MKL has been found, set some environment variables used by the MKL single dynamic library
	if ( $?MKLROOT ) then
	    if ( $?OpenCMISS_USE_MKL_THREADING ) then
		switch ( ${OpenCMISS_TOOLCHAIN} )
		    case intel:
			setenv MKL_THREADING_LAYER INTEL
			breaksw
		    case gnu:
			setenv MKL_THREADING_LAYER GNU
			breaksw
		    case ibm:
			breaksw
		    default:
			echo "OpenCMISS: OpenCMISS_TOOLCHAIN of ${OpenCMISS_TOOLCHAIN} is unknown."
			breaksw
		endsw
	    else
	        setenv MKL_THREADING_LAYER SEQUENTIAL
	    endif
	    setenv MKL_INTERFACE_LAYER LP64
	endif

	if ( $?OpenCMISS_INSTRMENTATION ) then
	    switch ( ${OpenCMISS_INSTRUMENTATION} )
		case scorep:
		    setenv OpenCMISS_INSTRUMENTATION_ARCHPATH -scorep
		    breaksw
		case gprof:
		    setenv OpenCMISS_INSTRUMENTATION_ARCHPATH -gprof      
		    breaksw
		case vtune:
		    setenv OpenCMISS_INSTRUMENTATION_ARCHPATH -vtune      
		    breaksw
		case none:
		    setenv OpenCMISS_INSTRUMENTATION_ARCHPATH      
		    breaksw
		default:
		    echo "OpenCMISS: OpenCMISS_INSTRUMENTATION of ${OpenCMISS_INSTRUMENTATION} is unknown."
		    setenv OpenCMISS_INSTRUMENTATION_ARCHPATH  -unknown
	    endsw
	else
	    setenv OpenCMISS_INSTRUMENTATION_ARCHPATH
	endif

	if ( $?OpenCMISS_MULTITHREADING ) then
	    setenv OpenCMISS_MULTITHREADING_ARCHPATH mt
	else
	    setenv OpenCMISS_MULTITHREADING_ARCHPATH
	endif
    
	if ( $?OpenCMISS_MPI ) then
	    switch ( ${OpenCMISS_MPI} )
		case none:
		    setenv MPI_STRING 
		    breaksw
		case mpich:
		    setenv MPI_STRING mpich
		    breaksw
		case mpich2:
		    setenv MPI_STRING mpich2
		    switch ( ${OpenCMISS_LINUX_DISTRIBUTION} )
			case fedora:
			    #Fedora doesn't include mpich in the path by default
			    if ( ! $?PATH ) then
				setenv PATH /usr/${LIBAPI}/mpich/bin
			    else
				setenv PATH /usr/${LIBAPI}/mpich/bin:${PATH}
			    endif
			    if ( ! $?LD_LIBRARY_PATH ) then
				setenv LD_LIBRARY_PATH /usr/${LIBAPI}/mpich/lib
			    else
				setenv LD_LIBRARY_PATH /usr/${LIBAPI}/mpich/lib:${LD_LIBRARY_PATH}
			    endif
			    breaksw
		    endsw
		    breaksw
		case openmpi:
		    setenv MPI_STRING openmpi
		    switch ( ${OpenCMISS_LINUX_DISTRIBUTION} )
			case fedora:
			    #Fedora doesn't include openmpi in the path by default
			    if ( ! $?PATH ) then
				setenv PATH /usr/${LIBAPI}/openmpi/bin
			    else
				setenv PATH /usr/${LIBAPI}/openmpi/bin:${PATH}
			    endif
			    if ( ! $?LD_LIBRARY_PATH ) then
				setenv LD_LIBRARY_PATH /usr/${LIBAPI}/openmpi/lib
			    else
				setenv LD_LIBRARY_PATH /usr/${LIBAPI}/openmpi/lib:${LD_LIBRARY_PATH}
			    endif
			    breaksw
		    endsw
		    breaksw      
		case mvapich2:
		    setenv MPI_STRING mvapich2
		    breaksw      
		case msmpi:
		    setenv MPI_STRING msmpi
		    breaksw      
		case intel:
		    setenv MPI_STRING intel
		    #Newer Intel directory structure
		    if ( -d "${INTEL_ROOT}/itac_latest" ) then
			#New Itac directory structure
			if ( -r "${INTEL_ROOT}/itac_latest/bin/itacvars.csh" ) then
			    #source ${INTEL_ROOT}/itac_latest/bin/itacvars.csh
			endif
		   else
			if ( ! $?INTEL_TRACE_COLLECTOR_VERSION ) then
			    setenv INTEL_TRACE_COLLECTOR_VERSION 1.2.3
			endif
			#Old Itac directory structure
			if ( -r "${INTEL_ROOT}/itac/${INTEL_TRACE_COLLECTOR_VERSION}/bin/itacvars.csh" ) then
			    source ${INTEL_ROOT}/itac/${INTEL_TRACE_COLLECTOR_VERSION}/bin/itacvars.csh impi4
			endif
		    endif
		    #Newer Intel MPI directory structure
		    if ( -r "${INTEL_ROOT}/compilers_and_libraries/linux/mpi/${BINAPI}/mpivars.csh" ) then
			source ${INTEL_ROOT}/compilers_and_libraries/linux/mpi/${BINAPI}/mpivars.csh
		    else
			if ( -d "${INTEL_ROOT}/impi/latest" ) then
			    #New Intel MPI directory structure. Use latest directory
			    if ( -r "${INTEL_ROOT}/impi/latest/${BINAPI}/mpivars.csh" ) then
				source ${INTEL_ROOT}/impi/latest/${BINAPI}/mpivars.csh
			    endif
			else			    
			    if ( -d "${INTEL_ROOT}/impi_latest" ) then
				#New Intel MPI directory structure. Use latest directory
				if ( -r "${INTEL_ROOT}/impi_latest/${BINAPI}/mpivars.csh" ) then
				    source ${INTEL_ROOT}/impi_latest/${BINAPI}/mpivars.csh
				endif
			    else
				if ( ! $?INTEL_MPI_VERSION ) then
				    setenv INTEL_MPI_VERSION 1.2.3
				endif
				#Old Intel MPI directory strucutre. Use specific version
				if ( -r "${INTEL_ROOT}/impi/${INTEL_MPI_VERSION}/${BINAPI}/mpivars.csh" ) then
				    source ${INTEL_ROOT}/impi/${INTEL_MPI_VERSION}/${BINAPI}/mpivars.csh
				endif
			    endif
			endif
		    endif
		    #Setup Hydra hostfile
		    if ( ! $?I_MPI_HYDRA_HOST_FILE ) then
			setenv I_MPI_HYDRA_HOST_FILE ~/hydra.hosts
		    endif
		    breaksw      
		default:
		    echo "OpenCMISS: OpenCMISS_MPI of ${OpenCMISS_MPI} is unknown."
		    setenv MPI_STRING unknown
	    endsw
	    setenv OpenCMISS_MPI_ARCHPATH mpi-${MPI_STRING}
	    setenv OpenCMISS_NOMPI_ARCHPATH mpi-none
	    unsetenv MPI_STRING
	else
	    setenv OpenCMISS_MPI_ARCHPATH 
	    setenv OpenCMISS_NOMPI_ARCHPATH	    
	endif

        if ( $?OpenCMISS_MPI_BUILD_TYPE ) then
	    switch ( ${OpenCMISS_MPI_BUILD_TYPE} )
	       case debug:
		    setenv MPI_BUILD_TYPE_STRING _debug
		    breaksw
	        case release:
		    setenv MPI_BUILD_TYPE_STRING _release
		    breaksw
		case relwithdebinfo:
		    setenv MPI_BUILD_TYPE_STRING _relwithdebinfo
		    breaksw
		case system:
		    setenv MPI_BUILD_TYPE_STRING _system
		    breaksw
		default:
		    echo "OpenCMISS: OpenCMISS_MPI_BUILD_TYPE of ${OpenCMISS_MPI_BUILD_TYPE} is unknown."
		    setenv MPI_BUILD_TYPE_STRING unknown		    
	     endsw
	     setenv OpenCMISS_MPI_ARCHPATH ${OpenCMISS_MPI_ARCHPATH}${MPI_BUILD_TYPE_STRING}
	     unsetenv MPI_BUILD_TYPE_STRING
	endif
    
	if ( $?OpenCMISS_BUILD_TYPE ) then
	    switch ( ${OpenCMISS_BUILD_TYPE} )
		case debug:
		    setenv BUILD_TYPE_STRING debug
		    breaksw
		case Debug:
		    setenv BUILD_TYPE_STRING Debug
		    breaksw
		case release:
		    setenv BUILD_TYPE_STRING release
		    breaksw
		case Release:
		    setenv BUILD_TYPE_STRING Release
		    breaksw
		case relwithdebinfo:
		    setenv BUILD_TYPE_STRING relwithdebinfo
		    breaksw
		case RelwithDebInfo:
		    setenv BUILD_TYPE_STRING RelwithDebInfo
		    breaksw
		case minsizerel:
		    setenv BUILD_TYPE_STRING minsizerel
		    breaksw
		case MinSizeRel:
		    setenv BUILD_TYPE_STRING MinSizeRel
		    breaksw
		default:
		    echo "OpenCMISS: OpenCMISS_BUILD_TYPE of ${OpenCMISS_BUILD_TYPE} is unknown."
		    setenv BUILD_TYPE_STRING unknown		    
	    endsw
	    setenv OpenCMISS_BUILD_TYPE_ARCHPATH ${BUILD_TYPE_STRING}
	    unsetenv BUILD_TYPE_STRING	
	else
	    setenv OpenCMISS_BUILD_TYPE_ARCHPATH
	endif

        switch( ${OpenCMISS_ARCHNAME} )
	    case i686-linux:
		setenv OpenCMISS_SYSTEM_ARCHPATH i686_linux
		breaksw    
	    case x86_64-linux:
		setenv OpenCMISS_SYSTEM_ARCHPATH x86_64_linux
		breaksw    
	    default:
		echo "OpenCMISS: OpenCMISS_ARCHNAME of ${OpenCMISS_ARCHNAME} is unknown."
 		setenv OpenCMISS_SYSTEM_ARCHPATH 
        endsw
	    
	setenv OpenCMISS_ARCHPATH_MPI ${OpenCMISS_SYSTEM_ARCHPATH}/${OpenCMISS_COMPILER_ARCHPATH}${OpenCMISS_INSTRUMENTATION_ARCHPATH}${OpenCMISS_MULTITHREADING_ARCHPATH}/${OpenCMISS_MPI_ARCHPATH}
	setenv OpenCMISS_ARCHPATH_NOMPI ${OpenCMISS_SYSTEM_ARCHPATH}/${OpenCMISS_COMPILER_ARCHPATH}${OpenCMISS_INSTRUMENTATION_ARCHPATH}${OpenCMISS_MULTITHREADING_ARCHPATH}/${OpenCMISS_NOMPI_ARCHPATH}

	# Add installed binary directories to path
	if ( -d ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_NOMPI}/bin ) then
	    if ( ! $?PATH ) then
		setenv PATH ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_NOMPI}/bin
	    else
		setenv PATH ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_NOMPI}/bin:${PATH}
	    endif
    	endif    
	if ( -d ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_MPI}/bin ) then
	    if ( ! $?PATH ) then
		setenv PATH ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_MPI}/bin
	    else
		setenv PATH ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_MPI}/bin:${PATH}
	    endif
	endif

	# Setup python path for OpenCMISS
	if ( ${OpenCMISS_SETUP_PYTHONPATH} == true ) then
	    if ( ! $?OpenCMISS_PYTHON_VERSION ) then
		which python >& /dev/null		
		if ( $? == 0 ) then
		    setenv OpenCMISS_PYTHON_MAJOR_VERSION `python --version | cut -f2 -d' ' | cut -f1 -d.`
		    setenv OpenCMISS_PYTHON_MINOR_VERSION `python --version | cut -f2 -d' ' | cut -f2 -d.`
		else
		    setenv OpenCMISS_PYTHON_MAJOR_VERSION 3
		    setenv OpenCMISS_PYTHON_MINOR_VERSION 12
		endif
		setenv OpenCMISS_PYTHON_VERSION ${OpenCMISS_PYTHON_MAJOR_VERSION}.${OpenCMISS_PYTHON_MINOR_VERSION}
	    endif
	    setenv OpenCMISS_PYTHON_PATH_OLD ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_MPI}/python/${OpenCMISS_BUILD_TYPE_ARCHPATH}
	    setenv OpenCMISS_PYTHON_PATH ${OpenCMISS_INSTALL_ROOT}/${OpenCMISS_ARCHPATH_MPI}/${OpenCMISS_BUILD_TYPE_ARCHPATH}/lib/python${OpenCMISS_PYTHON_VERSION}/opencmiss
	    if ( -d ${OpenCMISS_PYTHON_PATH_OLD} ) then
		if ( ! $?PYTHONPATH ) then
		    setenv PYTHONPATH ${OpenCMISS_PYTHON_PATH_OLD}
		else
		    setenv PYTHONPATH ${OpenCMISS_PYTHON_PATH_OLD}:${PYTHONPATH}
		endif
 	    endif
	    if ( -d ${OpenCMISS_PYTHON_PATH} ) then
		if ( ! $?PYTHONPATH ) then
		    setenv PYTHONPATH ${OpenCMISS_PYTHON_PATH}
		else
		    setenv PYTHONPATH ${OpenCMISS_PYTHON_PATH}:${PYTHONPATH}
		endif
 	    endif
	endif

	# Setup LaTeX paths for OpenCMISS
	if ( ${OpenCMISS_SETUP_LATEX} == true ) then
	    if ( -d ${OpenCMISS_ROOT}/documentation/notes/latex ) then
		if ( -d ${OpenCMISS_ROOT}/documentation/notes/figures ) then
		    if ( ! $?TEXINPUTS ) then
			setenv TEXINPUTS .:${OpenCMISS_ROOT}/documentation/notes/latex//:${OpenCMISS_ROOT}/documentation/notes/figures//:
		    else
			setenv TEXINPUTS .:${OpenCMISS_ROOT}/documentation/notes/latex//:${OpenCMISS_ROOT}/documentation/notes/figures//:${TEXINPUTS}:
		    endif
		else
		    if ( ! $?TEXINPUTS ) then
			setenv TEXINPUTS .:${OpenCMISS_ROOT}/documentation/notes/latex//:
		    else
			setenv TEXINPUTS .:${OpenCMISS_ROOT}/documentation/notes/latex//:${TEXINPUTS}:
		    endif
		endif    
 	    endif
	    if ( -d ${OpenCMISS_ROOT}/documentation/notes/references ) then
		if ( ! $?BIBINPUTS ) then
		    setenv BIBINPUTS .:${OpenCMISS_ROOT}/documentation/notes/references//:
		else
		    setenv BIBINPUTS .:${OpenCMISS_ROOT}/documentation/notes/references//:${BIBINPUTS}:
		endif
		if ( ! $?BSTINPUTS ) then
		    setenv BSTINPUTS .:${OpenCMISS_ROOT}/documentation/notes/references//:
		else
		    setenv BSTINPUTS .:${OpenCMISS_ROOT}/documentation/notes/references//:${BSTINPUTS}:
		endif
	    endif
	    if ( ! -e ~/texTextPreamble.ini ) then
		ln -s ${OpenCMISS_ROOT}/documentation/notes/latex/texTextPreamble.ini ~/texTextPreamble.ini
	    endif
	    alias latexmake ./Latex_make.sh
	endif
	
	# Setup git prompt for OpenCMISS
	if ( ${OpenCMISS_SETUP_GITPROMPT} == true ) then
	    unalias precmd
	    alias precmd 'source ${OpenCMISS_ROOT}/utilities/scripts/opencmiss_developer_gitprompt.csh'
	endif
	
	unsetenv LIBAPI 
	unsetenv SYSLIBAPI
	unsetenv BINAPI
	unsetenv INTELAPI
	breaksw
    default:
        echo "OpenCMISS: System name of ${sysname} is unknown."
endsw
    
unsetenv sysname 
unsetenv machine
