#!/bin/bash
# Sets up environment variables, paths etc. for an OpenCMISS developer

HOST=`hostname -s`
sysname=`uname -s`
machine=`uname -m`

# Make sure OpenCMISS_ROOT is an absolute path
if [ ! $OpenCMISS_ROOT ]; then
    echo "OpenCMISS: OpenCMISS_ROOT is not defined."
else
    if [ -r $OpenCMISS_ROOT ]; then
      export OpenCMISS_ROOT=`cd $OpenCMISS_ROOT && pwd `
    else
      echo "OpenCMISS: OpenCMISS_ROOT directory does not exist."
    fi
fi

# Make sure OpenCMISS_INSTALL_ROOT is an absolute path
if [ ! $OpenCMISS_INSTALL_ROOT ]; then
    export OpenCMISS_INSTALL_ROOT=$OpenCMISS_ROOT/install
else
    if [ -r $OpenCMISS_INSTALL_ROOT ]; then
      export OpenCMISS_INSTALL_ROOT=`cd $OpenCMISS_INSTALL_ROOT && pwd `
    else
      echo "OpenCMISS: OpenCMISS_INSTALL_ROOT directory does not exist."
    fi
fi

# Set defaults if not defined
if [ ! $OpenCMISS_SETUP_INTEL ]; then
    export OpenCMISS_SETUP_INTEL=true
fi
if [ ! $OpenCMISS_SETUP_TOTALVIEW ]; then
    export OpenCMISS_SETUP_TOTALVIEW=true
fi
if [ ! $OpenCMISS_SETUP_CUDA ]; then
    export OpenCMISS_SETUP_CUDA=true
fi
if [ ! $OpenCMISS_SETUP_LATEX ]; then
    export OpenCMISS_SETUP_LATEX=true
fi
if [ ! $OpenCMISS_SETUP_PYTHONPATH ]; then
    export OpenCMISS_SETUP_PYTHONPATH=true
fi
if [ ! $OpenCMISS_SETUP_GITPROMPT ]; then
    export OpenCMISS_SETUP_GITPROMPT=true
fi
if [ ! $OpenCMISS_MPI_BUILD_TYPE ]; then
    export OpenCMISS_MPI_BUILD_TYPE=system
fi
if [ ! $OpenCMISS_BUILD_TYPE ]; then
    export OpenCMISS_BUILD_TYPE=release
fi

case $sysname in
    'AIX')
        export PROCESSOR_TYPE="`lsattr -El proc0 | grep "Processor type" | tr -s ' ' | cut -f2 -d" "`"
	case $PROCESSOR_TYPE in
	  'PowerPC_POWER7')
	    export OpenCMISS_ARCHNAME=power7-aix
	    ;;
	  'PowerPC_POWER6')
	    export OpenCMISS_ARCHNAME=power6-aix
	    ;;
	  'PowerPC_POWER5')
	    export OpenCMISS_ARCHNAME=power5-aix
	    ;;
	  'PowerPC_POWER4')
	    export OpenCMISS_ARCHNAME=power4-aix
	    ;;
	  *)
	    echo "OpenCMISS: The processor architecture of $PROCESSOR_TYPE is unknown for AIX."
	    export OpenCMISS_ARCHNAME=unknown-aix
	esac
	unset PROCESSOR_TYPE

	;;
    'Linux')
	export OpenCMISS_ARCHNAME=$machine-linux

	#Try and work out what linux distribution we are on
	if [ \( -r "/etc/SuSE-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=suse
	    export OpenCMISS_SUSE_RELEASE="`grep "VERSION" /etc/SuSE-release | cut -f2 -d"=" | tr -d " "`"."`grep "PATCHLEVEL" /etc/SuSE-release | cut -f2 -d"=" | tr -d " "`"
	elif [ \( -r "/etc/redhat-release" \) ]; then
	    #Work out if it is Red Hat, Fedora or Scientific Linux
            if [ \( -n "`grep "Red Hat Enterprise" /etc/redhat-release`" \) ] ; then
		export OpenCMISS_LINUX_DISTRIBUTION=redhat
	        export OpenCMISS_REDHAT_RELEASE=`cat /etc/redhat-release | cut -f7 -d" "`
            elif [ \( -n "`grep "Fedora" /etc/redhat-release`" \) ] ; then
		export OpenCMISS_LINUX_DISTRIBUTION=fedora
	        export OpenCMISS_FEDORA_RELEASE=`cat /etc/redhat-release | cut -f3 -d" "`
            elif [ \( -n "`grep "Scientific Linux" /etc/redhat-release`" \) ] ; then
		export OpenCMISS_LINUX_DISTRIBUTION=scientificlinux
	        export OpenCMISS_SCILINUX_RELEASE=`cat /etc/redhat-release | cut -f4 -d" " | cut -f1 -d"."`
            elif [ \( -n "`grep "CentOS" /etc/redhat-release`" \) ] ; then
		export OpenCMISS_LINUX_DISTRIBUTION=centos
	        export OpenCMISS_CENTOS_RELEASE=`cat /etc/redhat-release | cut -f4 -d" " | cut -f1 -d"."`
            else 
		echo "OpenCMISS: Can not determine Linux distribution from /etc/redhat-release."
		export OpenCMISS_LINUX_DISTRIBUTION=unknown
	    fi
	elif [ \( -r "/etc/redhat_version" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=redhat
	elif [ \( -r "/etc/fedora-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=fedora
	    export OpenCMISS_FEDORA_RELEASE=`cat /etc/fedora-release | cut -f3 -d" "`
	elif [ \( -r "/etc/slackware-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=slackware
	elif [ \( -r "/etc/slackware-version" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=slackware
	elif [ \( -r "/etc/lsb-release" \) ]; then
	    #Work out if it is Ubuntu or Mint
            if [ \( -n "`grep "DISTRIB_ID=Ubuntu" /etc/lsb-release`" \) ] ; then
		export OpenCMISS_LINUX_DISTRIBUTION=ubuntu
		export OpenCMISS_UBUNTU_RELEASE=`grep "DISTRIB_RELEASE" /etc/lsb-release | cut -f2 -d"="`
            elif [ \( -n "`grep "DISTRIB_ID=LinuxMint" /etc/lsb-release`" \) ] ; then
		export OpenCMISS_LINUX_DISTRIBUTION=mint
		export OpenCMISS_MINT_RELEASE=`grep "DISTRIB_RELEASE" /etc/lsb-release | cut -f2 -d"="`
            else 
		echo "OpenCMISS: Can not determine Linux distribution from /etc/lsb-release."
		export OpenCMISS_LINUX_DISTRIBUTION=unknown
	    fi
	elif [ \( -r "/etc/debian_release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=debian
	elif [ \( -r "/etc/debian_version" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=debian
	elif [ \( -r "/etc/mandrake-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=mandrake
	elif [ \( -r "/etc/yellowdog-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=yellowdog
	elif [ \( -r "/etc/sun-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=sun
	elif [ \( -r "/etc/release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=solaris
	elif [ \( -r "/etc/gentoo-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=gentoo
	elif [ \( -r "/etc/UnitedLinux-release" \) ]; then
	    export OpenCMISS_LINUX_DISTRIBUTION=unitedlinux
        else
	    echo "OpenCMISS: Can not read /etc/issue. Linux distribution is unknown."
	    export OpenCMISS_LINUX_DISTRIBUTION=unknown
        fi

	case $OpenCMISS_LINUX_DISTRIBUTION in
	  'ubuntu')
	    case $OpenCMISS_ARCHNAME in
	      'i686-linux')
	        export LIBAPI=lib
	        export SYSLIBAPI=lib
                export BINAPI=bin
		export INTELAPI=ia32
		;;
	      'x86_64-linux')
	        export LIBAPI=lib64
		export SYSLIBAPI=lib
                export BINAPI=bin64
		export INTELAPI=intel64
                ;;
	      *)
                echo "OpenCMISS: Architecture name of $OpenCMISS_ARCHNAME is unknown."
	    esac
	    ;;
	  'mint')
	    case $OpenCMISS_ARCHNAME in
	      'i686-linux')
	        export LIBAPI=lib
	        export SYSLIBAPI=lib
                export BINAPI=bin
		export INTELAPI=ia32
		;;
	      'x86_64-linux')
	        export LIBAPI=lib64
		export SYSLIBAPI=lib
                export BINAPI=bin64
		export INTELAPI=intel64
                ;;
	      *)
                echo "OpenCMISS: Architecture name of $OpenCMISS_ARCHNAME is unknown."
	    esac
	    ;;
	  *)	  
	    case $OpenCMISS_ARCHNAME in
	      'i686-linux')
	        export LIBAPI=lib
	        export SYSLIBAPI=lib
                export BINAPI=bin
		export INTELAPI=ia32
		;;
	      'x86_64-linux')
	        export LIBAPI=lib64
	        export SYSLIBAPI=lib64
                export BINAPI=bin64
		export INTELAPI=intel64
                ;;
	      *)
                echo "OpenCMISS: Architecture name of $OpenCMISS_ARCHNAME is unknown."
	    esac
	esac

	#Setup intel compilers if defined
	if [ $OpenCMISS_SETUP_INTEL == true ]; then	    
	    export INTEL_ONEAPI=false
	    if [ ! $INTEL_ROOT ]; then
		if [ \( -d "/opt/intel/oneapi" \) ]; then
		    #New oneAPI intel setup
		    export INTEL_ROOT=/opt/intel/oneapi
		    export INTEL_ONEAPI=true
		else    
		    export INTEL_ROOT=/opt/intel
		fi
	    fi
	    #Add in intel compilers if defined
	    if [ \( -r "$INTEL_ROOT/setvars.sh" \) ]; then
		#New oneAPI intel setup
		source $INTEL_ROOT/setvars.sh >& intel_setvars.out
		export INTEL_ONEAPI=true
	    else
		if [ \( -x "$INTEL_ROOT/compilers_and_libraries/linux/bin/compilervars.sh" \) ]; then
		    . $INTEL_ROOT/compilers_and_libraries/linux/bin/compilervars.sh $INTELAPI
		    if [ \( -x "$INTEL_ROOT/compilers_and_libraries/linux/mkl/bin/mklvars.sh" \) ]; then
			. $INTEL_ROOT/compilers_and_libraries/linux/mkl/bin/mklvars.sh $INTELAPI
		    fi
		else
		    #Add in the newer version of the compilers
		    if [ \( -x "$INTEL_ROOT/composerxe/bin/compilervars.sh" \) ]; then
			. $INTEL_ROOT/composerxe/bin/compilervars.sh $INTELAPI
			if [ \( -x "$INTEL_ROOT/mkl/bin/mklvars.sh" \) ]; then
			    . $INTEL_ROOT/mkl/bin/mklvars.sh $INTELAPI
			fi
		    else
			if [ \( -x "$INTEL_ROOT/bin/compilervars.sh" \) ]; then
			    #Newer version of intel compilers
			    . $INTEL_ROOT/bin/compilervars.sh $INTELAPI
			    if [ \( -x "$INTEL_ROOT/mkl/bin/mklvars.sh" \) ]; then
				. $INTEL_ROOT/mkl/bin/mklvars.sh $INTELAPI
			    fi
			else
			    #Older version of intel compilers
			    if [ ! $INTEL_COMPILER_VERSION ]; then
				export INTEL_COMPILER_VERSION=1.0
			    fi
			    if [ ! $INTEL_COMPILER_BUILD ]; then
				export INTEL_COMPILER_BUILD=1.0
			    fi
			    if [ \( -x "$INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/ifortvars.sh" \) ]; then
				. $INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/ifortvars.sh $INTELAPI
			    fi
			    if [ \( -x "$INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/iccvars.sh" \) ]; then
				. $INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/iccvars.sh $INTELAPI
			    fi
			fi
		    fi
		fi
		# Setup Intel advisor if it is installed
		if [ \( -x "$INTEL_ROOT/advisor/advixe-vars.csh" \) ]; then
		    . $INTEL_ROOT/advisor/advixe-vars.sh quiet
		fi
		# Setup Intel inspector if it is installed
		if [ \( -x "$INTEL_ROOT/inspector/inspxe-vars.csh" \) ]; then
		    . $INTEL_ROOT/inspector/inspxe-vars.sh quiet
		fi
	    fi
	fi

	#Setup totalview if defined
	if [ $OpenCMISS_SETUP_TOTALVIEW == true ]; then
	    which totalview >& /dev/null
	    if [ $? == 0 ]; then
		if [ ! $TOTALVIEW_PATH ]; then
		    export TOTALVIEW_PATH1=`which totalview | cut -f2 -d'/'`
		    export TOTALVIEW_PATH2=`which totalview | cut -f3 -d'/'`
		    export TOTALVIEW_PATH=$TOTALVIEW_PATH1/$TOTALVIEW_PATH2
		    unset TOTALVIEW_PATH1
		    unset TOTALVIEW_PATH2
		fi
	        if [ ! $TOTALVIEW_VERSION ]; then
		  export TOTALVIEW_VERSION=`totalview -v | cut -f4 -d' '`
	        fi
	    else
		if [ ! $TOTALVIEW_PATH ]; then
		    export TOTALVIEW_PATH=/opt/toolworks
		fi
		if [ \( -d $TOTALVIEW_PATH \) ]; then
		    if [ ! $TOTALVIEW_VERSION ]; then
			export TOTALVIEW_VERSION1=`ls $TOTALVIEW_PATH | grep -i totalview | tail -1 | cut -f2 -d.`
			if [ \( -n $TOTALVIEW_VERSION1 \) ]; then
			    export TOTALVIEW_VERSION2=`ls $TOTALVIEW_PATH | grep -i totalview | tail -1 | cut -f3 -d.`
			    if [ \( -n $TOTALVIEW_VERSION2 \) ]; then
				export TOTALVIEW_VERSION3=`ls $TOTALVIEW_PATH | grep -i totalview | tail -1 | cut -f4 -d.`
				if [ \( -n $TOTALVIEW_VERSION3 \) ]; then
				    export TOTALVIEW_VERSION=$TOTALVIEW_VERSION1.$TOTALVIEW_VERSION2.$TOTALVIEW_VERSION3
				fi
				unset TOTALVIEW_VERSION3
			    fi
			    unset TOTALVIEW_VERSION2
			fi
			unset TOTALVIEW_VERSION1
		    fi
		fi
	    fi
	    if [ \( -d $TOTALVIEW_PATH \) ]; then
		if [ ! $FLEXLM_VERSION ]; then
		    export FLEXLM_VERSION1=`ls $TOTALVIEW_PATH | grep -i flexlm | tail -1 | cut -f2 -d'-'`
		    if [ \( -n $FLEXLM_VERSION1 \) ]; then
			export FLEXLM_VERSION2=`ls $TOTALVIEW_PATH | grep -i flexlm | tail -1 | cut -f3 -d'-'`
			if [ \( -n $FLEXLM_VERSION2 \) ]; then
			    export FLEXLM_VERSION=$FLEXLM_VERSION1-$FLEXLM_VERSION2
			fi
			unset FLEXLM_VERSION2
		    fi
		    unset FLEXLM_VERSION1
		fi
		#Add in totalview path
		if [ $TOTALVIEW_VERSION ]; then
		    if [ \( -d "$TOTALVIEW_PATH/totalview.$TOTALVIEW_VERSION/bin" \) ]; then
			if [ \( -z "$PATH" \) ]; then
			    export PATH=$TOTALVIEW_PATH/totalview.$TOTALVIEW_VERSION/bin
			else
			    export PATH=$TOTALVIEW_PATH/totalview.$TOTALVIEW_VERSION/bin:$PATH
			fi
		    fi
		fi
		#Add in FlexLM path
		if [ $FLEXLM_VERSION ]; then
		    if [ \( -d "$TOTALVIEW_PATH/flexlm-$FLEXLM_VERSION" \) ]; then
			if [ \( -z "$LM_LICENSE_FILES" \) ]; then
			    export LM_LICENSE_FILESPATH=$TOTALVIEW_PATH/flexlm-$FLEXLM_VERSION
			else
			    export LM_LICENSE_FILESPATH=$TOTALVIEW_PATH/flexlm-$FLEXLM_VERSION:$LM_LICENSE_FILES
			fi
		    fi
		fi
	    fi
	fi

	#Setup cuda if defined
	if [ $OpenCMISS_SETUP_CUDA == true ]; then
	    which nvcc >& /dev/null		
	    if [ $? == 0 ]; then
		export CUDA_NVCC_PATH=`which nvcc`		
		export CUDA_BIN_PATH=`dirname $CUDA_NVCC_PATH`
		export CUDA_PATH=`dirname $CUDA_BIN_PATH`
		export CUDA_NVCC_MAJOR_VERSION=`nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f1 -d.`
		export CUDA_NVCC_MINOR_VERSION=`nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f2 -d.`
		export CUDA_NVCC_VERSION=$CUDA_NVCC_MAJOR_VERSION.$CUDA_NVCC_MINOR_VERSION
		unset CUDA_NVCC_MAJOR_VERSION
		unset CUDA_NVCC_MINOR_VERSION
		unset CUDA_BIN_PATH
	    else
		if [ ! $CUDA_PATH ]; then
		    export CUDA_PATH=/usr/local/cuda
		fi
		export CUDA_BIN_PATH=$CUDA_PATH/bin
		if [ \( -d $CUDA_PATH \) ]; then
		    if [ \( -x $CUDA_BIN_PATH/nvcc \) ]; then
			export CUDA_NVCC_MAJOR_VERSION=`$CUDA_BIN_PATH/nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f1 -d.`
			export CUDA_NVCC_MINOR_VERSION=`$CUDA_BIN_PATH/nvcc --version | grep -i "compilation tools" | cut -f2 -d, | cut -f3 -d' ' | cut -f2 -d.`
		    fi
		    export CUDA_NVCC_VERSION=$CUDA_NVCC_MAJOR_VERSION.$CUDA_NVCC_MINOR_VERSION
		    unset CUDA_NVCC_MAJOR_VERSION
		    unset CUDA_NVCC_MINOR_VERSION
		else
		    export CUDA_NVCC_VERSION=unknown
		fi
		unset CUDA_BIN_PATH
	    fi
	    if [ \( -d $CUDA_PATH \) ]; then
		export CUDA_PARENT_PATH=`dirname $CUDA_PATH`
		export CUDA_VERSION_BIN_PATH=$CUDA_PARENT_PATH/cuda-$CUDA_NVCC_VERSION/bin
		export CUDA_VERSION_LIB_PATH=$CUDA_PARENT_PATH/cuda-$CUDA_NVCC_VERSION/$LIBAPI
		if [ \( -d $CUDA_VERSION_BIN_PATH \) ]; then
		    if [ \( -z "$PATH" \) ]; then
			export PATH=$CUDA_VERSION_BIN_PATH
		    else
			export PATH=$CUDA_VERSION_BIN_PATH:$PATH
		    fi
		fi
		if [ \( -d $CUDA_VERSION_LIB_PATH \) ]; then
		    if [ \( -z "$LD_LIBRARY_PATH" \) ]; then
			export LD_LIBRARY_PATH=$CUDA_VERSION_LIB_PATH
		    else
			export LD_LIBRARY_PATH=$CUDA_VERSION_LIB_PATH:$LD_LIBRARY_PATH
		    fi
		fi
	    fi
	fi
	
	#Setup toolchain if defined
	if [ $OpenCMISS_TOOLCHAIN ]; then
	    case $OpenCMISS_TOOLCHAIN in
	      'gnu' | 'GNU' | 'Gnu')
		which gcc >& /dev/null		
		if [ $? == 0 ]; then
		    export GNU_GCC_MAJOR_VERSION=`gcc -dumpversion | cut -f1 -d.`
		    if [ "$GNU_GCC_MAJOR_VERSION" -ge 7 ]; then
		      export GNU_GCC_MAJOR_VERSION=`gcc --version | grep -i gcc | cut -f1 -d. | cut -f3 -d' '`
		      export GNU_GCC_MINOR_VERSION=`gcc --version | grep -i gcc | cut -f2 -d.`
		    else
		      export GNU_GCC_MINOR_VERSION=`gcc -dumpversion | cut -f2 -d.`
		    fi
		    export C_COMPILER_STRING=gnu-C$GNU_GCC_MAJOR_VERSION.$GNU_GCC_MINOR_VERSION
		    unset GNU_GCC_MAJOR_VERSION    
		    unset GNU_GCC_MINOR_VERSION    
		else
		    export C_COMPILER_STRING=unknown
		fi
		which gfortran >& /dev/null		
		if [ $? == 0 ]; then
		    export GNU_GFORTRAN_MAJOR_VERSION=`gfortran -dumpversion | cut -f1 -d.`
		    if [ "$GNU_GFORTRAN_MAJOR_VERSION" -ge 7 ]; then
			export GNU_GFORTRAN_MAJOR_VERSION=`gfortran --version | grep -i fortran | cut -f1 -d. | cut -f4 -d' '`
			export GNU_GFORTRAN_MINOR_VERSION=`gfortran --version | grep -i fortran | cut -f2 -d.`
		    else
			export GNU_GFORTRAN_MINOR_VERSION=`gfortran -dumpversion | cut -f2 -d.`
		    fi
		    export FORTRAN_COMPILER_STRING=gnu-F$GNU_GFORTRAN_MAJOR_VERSION.$GNU_GFORTRAN_MINOR_VERSION
		    unset GNU_GFORTRAN_MAJOR_VERSION    
		    unset GNU_GFORTRAN_MINOR_VERSION    
		else
		    export FORTRAN_COMPILER_STRING=unknown
		fi
		;;
	      'intel' | 'Intel' | 'INTEL')		  
		if [ $INTEL_ONEAPI == true ]; then
		    which icx >& /dev/null		
		    if [ $? == 0 ]; then
			export INTEL_ICC_MAJOR_VERSION=`icx --version | grep oneAPI | cut -f1 -d. | cut -c 36-39`
			export INTEL_ICC_MINOR_VERSION=`icx --version | grep oneAPI | cut -f2 -d.`
			export C_COMPILER_STRING=intel-C$INTEL_ICC_MAJOR_VERSION.$INTEL_ICC_MINOR_VERSION
			unset INTEL_ICC_MAJOR_VERSION    
			unset INTEL_ICC_MINOR_VERSION    
		    else
			export C_COMPILER_STRING=unknown
		    fi
		    which ifx >& /dev/null		
		    if [ $? == 0 ]; then
			export INTEL_IFORT_MAJOR_VERSION=`ifx --version | grep IFX | cut -f1 -d. | cut -c 11-14`
			export INTEL_IFORT_MINOR_VERSION=`ifx --version | grep IFX | cut -f2 -d.`
			export FORTRAN_COMPILER_STRING=intel-F$INTEL_IFORT_MAJOR_VERSION.$INTEL_IFORT_MINOR_VERSION
			unset INTEL_IFORT_MAJOR_VERSION    
			unset INTEL_IFORT_MINOR_VERSION    
		    else
			export FORTRAN_COMPILER_STRING=unknown
		    fi
		else
		    which icc >& /dev/null		
		    if [ $? == 0 ]; then
			export INTEL_ICC_MAJOR_VERSION=`icc -diag-disable=10441 --version | grep ICC | cut -f1 -d. | cut -c 11-12`
			export INTEL_ICC_MINOR_VERSION=`icc -diag-disable=10441 --version | grep ICC | cut -f2 -d.`
			export C_COMPILER_STRING=intel-C$INTEL_ICC_MAJOR_VERSION.$INTEL_ICC_MINOR_VERSION
			unset INTEL_ICC_MAJOR_VERSION    
			unset INTEL_ICC_MINOR_VERSION    
		    else
			export C_COMPILER_STRING=unknown
		    fi
		    which ifort >& /dev/null		
		    if [ $? == 0 ]; then
			export INTEL_IFORT_MAJOR_VERSION=`ifort --version | grep IFORT | cut -f1 -d. | cut -c 15-16`
			export INTEL_IFORT_MINOR_VERSION=`ifort --version | grep IFORT | cut -f2 -d.`
			export FORTRAN_COMPILER_STRING=intel-F$INTEL_IFORT_MAJOR_VERSION.$INTEL_IFORT_MINOR_VERSION
			unset INTEL_IFORT_MAJOR_VERSION    
			unset INTEL_IFORT_MINOR_VERSION    
		    else
			export FORTRAN_COMPILER_STRING=unknown
		    fi
		fi
		;;
	      *)
		  echo "OpenCMISS: OpenCMISS_TOOLCHAIN of $OpenCMISS_TOOLCHAIN is unknown."
		  export C_COMPILER_STRING=unknown
		  export FORTRAN_COMPILER_STRING=unknown
	    esac
	    export OpenCMISS_COMPILER_ARCHPATH=$C_COMPILER_STRING-$FORTRAN_COMPILER_STRING
	    unset C_COMPILER_STRING
	    unset FORTRAN_COMPILER_STRING
	fi
	
	# If MKL has been found, set some environment variables used by the MKL single dynamic library
	if [ $?MKLROOT ]; then
	    if [ $?OpenCMISS_USE_MKL_THREADING ]; then
		case $OpenCMISS_TOOLCHAIN in
		    'intel' | 'Intel' | 'INTEL')
			export MKL_THREADING_LAYER=INTEL
			;;
		    'gnu' | 'Gnu' | 'GNU')
			export MKL_THREADING_LAYER=GNU
			;;
		    'ibm' | 'Ibm' | 'IBM')
			;;
		    *)
			echo "OpenCMISS: OpenCMISS_TOOLCHAIN of $OpenCMISS_TOOLCHAIN is unknown."
			;;
		esac
	    else
	        export MKL_THREADING_LAYER=SEQUENTIAL
	    fi
	    export MKL_INTERFACE_LAYER=LP64
	fi
	
	if [ ! $OpenCMISS_INSTRMENTATION ]; then
	    export OpenCMISS_INSTRUMENTATION_ARCHPATH=''
	else
	    case $OpenCMISS_INSTRUMENTATION in
		'scorep' | 'Scorep' | 'ScoreP' | 'SCOREP')
		    export OpenCMISS_INSTRUMENTATION_ARCHPATH=-scorep
		    ;;
		'gprof' | 'Gprof' | 'GProf' | 'GPROF')
		    export OpenCMISS_INSTRUMENTATION_ARCHPATH=-gprof      
		    ;;
		'vtune' | 'Vtune' | 'VTune' | 'VTUNE')
		    export OpenCMISS_INSTRUMENTATION_ARCHPATH=-vtune      
		    ;;
		'none' | 'None' | 'NONE')
		    export OpenCMISS_INSTRUMENTATION_ARCHPATH='' 
		    ;;
		*)
		    echo "OpenCMISS: OpenCMISS_INSTRUMENTATION of $OpenCMISS_INSTRUMENTATION is unknown."
		    export OpenCMISS_INSTRUMENTATION_ARCHPATH=-unknown
	    esac
	fi
	
	if [ ! $OpenCMISS_MULTITHREADING ]; then
	    export OpenCMISS_MULTITHREADING_ARCHPATH=''
	else
	    case $OpenCMISS_MULTITHREADING in
		'none' | 'None' | 'NONE')
		    export OpenCMISS_MULTITHREADING_ARCHPATH='' 
		    ;;
		*)
		    echo "OpenCMISS: OpenCMISS_MULTITHREADING of $OpenCMISS_MULTITHREADING is unknown."
		    export OpenCMISS_MULTITHREADING_ARCHPATH=''
	    esac
	fi
	
	if [ $?OpenCMISS_MPI ]; then
	    case $OpenCMISS_MPI in
		'none' | 'None' | 'NONE')
		    export MPI_STRING=''
		    ;;
		'mpich' | 'Mpich' | 'MPICH')
		    export MPI_STRING=mpich
		    case $OpenCMISS_LINUX_DISTRIBUTION in
			'fedora')
			    #Fedora doesn't include mpich in the path by default
			    if [ \( -z "$PATH" \) ]; then
				export PATH=/usr/$LIBAPI/mpich/bin
			    else
				export PATH=/usr/$LIBAPI/mpich/bin:$PATH
			    fi
			    if [ \( -z "$LD_LIBRARY_PATH" \) ]; then
				export LD_LIBRARY_PATH=/usr/$LIBAPI/mpich/lib
			    else
				export LD_LIBRARY_PATH=/usr/$LIBAPI/mpich/lib:$LD_LIBRARY_PATH
			    fi
			    ;;
		    esac
		    ;;
		'mpich2' | 'Mpich2' | 'MPICH2')
		    export MPI_STRING=mpich2
		    ;;
		'openmpi' | 'Openmpi' | 'OpenMPI' | 'OPENMPI')
		    export MPI_STRING=openmpi
		    case $OpenCMISS_LINUX_DISTRIBUTION in
			'fedora')
			    #Fedora doesn't include openmpi in the path by default
			    if [ \( -z "$PATH" \) ]; then
				export PATH=/usr/$LIBAPI/openmpi/bin
			    else
				export PATH=/usr/$LIBAPI/openmpi/bin:$PATH
			    fi
			    if [ \( -z "$LD_LIBRARY_PATH" \) ]; then
				export LD_LIBRARY_PATH=/usr/$LIBAPI/openmpi/lib
			    else
				export LD_LIBRARY_PATH=/usr/$LIBAPI/openmpi/lib:$LD_LIBRARY_PATH
			    fi
			    ;;
		    esac
		    ;;
		'mvapich2' | 'Mvapich2' | 'MVapich2' | 'MVAPICH2')
		    export MPI_STRING=mvapich2
		    ;;
		'msmpi' | 'Msmpi' | 'MSmpi' | 'MSMPI')
		    export MPI_STRING=msmpi
		    ;;
		'intel' | 'Intel' | 'INTEL')
		    export MPI_STRING=intel
		    #Newer Intel directory structure
		    if [ \( -d "$INTEL_ROOT/itac_latest" \) ]; then
			#New Itac directory structure
			if [ \( -r "$INTEL_ROOT/itac_latest/bin/itacvars.sh" \) ]; then
			    . $INTEL_ROOT/itac_latest/bin/itacvars.sh
			fi
		    else
			if [ ! $INTEL_TRACE_COLLECTOR_VERSION ]; then
			    export INTEL_TRACE_COLLECTOR_VERSION=1.2.3
			fi
			#Old Itac directory structure
			if [ \( -r "$INTEL_ROOT/itac/$INTEL_TRACE_COLLECTOR_VERSION/bin/itacvars.sh" \) ]; then
			    . $INTEL_ROOT/itac/$INTEL_TRACE_COLLECTOR_VERSION/bin/itacvars.sh impi4
			fi
		    fi
		    #Newer Intel MPI directory structure
		    if [ \( -r "$INTEL_ROOT/compilers_and_libraries/linux/mpi/$BINAPI/mpivars.sh" \) ]; then
			. $INTEL_ROOT/compilers_and_libraries/linux/mpi/$BINAPI/mpivars.sh
		    else
			if [ \( -d "$INTEL_ROOT/impi/latest" \) ]; then
			    #New Intel MPI directory structure. Use latest directory
			    if [ \( -r "$INTEL_ROOT/impi/latest/$BINAPI/mpivars.sh" \) ]; then
				. $INTEL_ROOT/impi/latest/$BINAPI/mpivars.csh
			    fi
			else			    
			    if [ \( -d "$INTEL_ROOT/impi_latest" \) ]; then
				#New Intel MPI directory structure. Use latest directory
				if [ \( -r "$INTEL_ROOT/impi_latest/$BINAPI/mpivars.sh" \) ]; then
				    . $INTEL_ROOT/impi_latest/$BINAPI/mpivars.sh
				fi
			    else
				if [ ! $INTEL_MPI_VERSION ]; then
				    export INTEL_MPI_VERSION=1.2.3
				fi
				#Old Intel MPI directory strucutre. Use specific version
				if [ \( -r "$INTEL_ROOT/impi/$INTEL_MPI_VERSION/$BINAPI/mpivars.sh" \) ]; then
				    . $INTEL_ROOT/impi/$INTEL_MPI_VERSION/$BINAPI/mpivars.sh
				fi
			    fi
			fi
		    fi
		    #Setup Hydra hostfile
		    if [ ! $?I_MPI_HYDRA_HOST_FILE ]; then
			export I_MPI_HYDRA_HOST_FILE=~/hydra.hosts
		    fi
		    ;;
		*)
		    echo "OpenCMISS: OpenCMISS_MPI of $OpenCMISS_MPI is unknown."
		    export MPI_STRING=unknown
	    esac
	    export OpenCMISS_MPI_ARCHPATH=mpi-$MPI_STRING
	    export OpenCMISS_NOMPI_ARCHPATH=mpi-none
	    unset MPI_STRING
	else
	    export OpenCMISS_MPI_ARCHPATH=''
	    export OpenCMISS_NOMPI_ARCHPATH=''	    
	fi
	
        if [ $?OpenCMISS_MPI_BUILD_TYPE ]; then
	    case $OpenCMISS_MPI_BUILD_TYPE in
		'debug' | 'Debug' | 'DEBUG')
		    export MPI_BUILD_TYPE_STRING=-Debug
		    ;;
		'release' | 'Release' | 'RELEASE')
		    export MPI_BUILD_TYPE_STRING=-Release
		    ;;
		'relwithdebinfo' | 'Relwithdebinfo' | 'RelWithDebInfo' | 'RELWITHDEBINFO')
		    export MPI_BUILD_TYPE_STRING=-RelWithDebInfo
		    ;;
		'minsizerel' | 'Minsizerel' | 'MinSizeRel' | 'MINSIZEREL')
		    export MPI_BUILD_TYPE_STRING=-MinSizeRel
		    ;;
		'system' | 'System' | 'SYSTEM')
		    export MPI_BUILD_TYPE_STRING=-system
		    ;;
		'none' | 'None' | 'NONE')
		    export MPI_BUILD_TYPE_STRING=-system
		    ;;
		*)
		    echo "OpenCMISS: OpenCMISS_MPI_BUILD_TYPE of $OpenCMISS_MPI_BUILD_TYPE is unknown."
		    export MPI_BUILD_TYPE_STRING=unknown		    
	    esac
	    export OpenCMISS_MPI_ARCHPATH=$OpenCMISS_MPI_ARCHPATH$MPI_BUILD_TYPE_STRING
	    unset MPI_BUILD_TYPE_STRING
	fi
	
	if [ ! $OpenCMISS_BUILD_TYPE ]; then
	    export OpenCMISS_BUILD_TYPE_ARCHPATH=''
	else
	    case $OpenCMISS_BUILD_TYPE in
		'debug' | 'Debug' | 'DEBUG')
		    export BUILD_TYPE_STRING=Debug
		    ;;
		'release' | 'Release' | 'RELEASE')
		    export BUILD_TYPE_STRING=Release
		    ;;
		'relwithdebinfo' | 'Relwithdebinfo' | 'RelWithDebInfo' | 'RELWITHDEBINFO')
		    export BUILD_TYPE_STRING=RelWithDebInfo
		    ;;
		'minsizerel' | 'Minsizerel' | 'MinSizeRel' | 'MINSIZEREL')
		    export BUILD_TYPE_STRING=MinSizeRel
		    ;;
		*)
		    echo "OpenCMISS: OpenCMISS_BUILD_TYPE of $OpenCMISS_BUILD_TYPE is unknown."
		    export BUILD_TYPE_STRING=unknown		    
	    esac
	    export OpenCMISS_BUILD_TYPE_ARCHPATH=$BUILD_TYPE_STRING
	    unset BUILD_TYPE_STRING	
	fi
	
        case $OpenCMISS_ARCHNAME in
	    'i686-linux')
		export OpenCMISS_SYSTEM_ARCHPATH=i686-linux
		;;    
	    'x86_64-linux')
		export OpenCMISS_SYSTEM_ARCHPATH=x86_64-linux
		;;
	    *)
		echo "OpenCMISS: OpenCMISS_ARCHNAME of $OpenCMISS_ARCHNAME is unknown."
		export OpenCMISS_SYSTEM_ARCHPATH='' 
        esac
	
	export OpenCMISS_ARCHPATH_MPI=$OpenCMISS_SYSTEM_ARCHPATH/$OpenCMISS_COMPILER_ARCHPATH$OpenCMISS_INSTRUMENTATION_ARCHPATH$OpenCMISS_MULTITHREADING_ARCHPATH/$OpenCMISS_MPI_ARCHPATH
	export OpenCMISS_ARCHPATH_NOMPI=$OpenCMISS_SYSTEM_ARCHPATH/$OpenCMISS_COMPILER_ARCHPATH$OpenCMISS_INSTRUMENTATION_ARCHPATH$OpenCMISS_MULTITHREADING_ARCHPATH/$OpenCMISS_NOMPI_ARCHPATH
	
	# Add installed binary directories to path
	if [ \( -d $OpenCMISS_INSTALL_ROOT/$OpenCMISS_ARCHPATH_NOMPI/bin \) ]; then
	    if [ ! $?PATH ]; then
		export PATH=$OpenCMISS_INSTALL_ROOT/$OpenCMISS_ARCHPATH_NOMPI/bin
	    else
		export PATH=$OpenCMISS_INSTALL_ROOT/$OpenCMISS_ARCHPATH_NOMPI/bin:$PATH
	    fi
    	fi    
	if [ \( -d $OpenCMISS_INSTALL_ROOT/$OpenCMISS_ARCHPATH_MPI/bin \) ]; then
	    if [ ! $?PATH ]; then
		export PATH=$OpenCMISS_INSTALL_ROOT/$OpenCMISS_ARCHPATH_MPI/bin
	    else
		export PATH=$OpenCMISS_INSTALL_ROOT/$OpenCMISS_ARCHPATH_MPI/bin:$PATH
	    fi
	fi
	
	# Setup python path for OpenCMISS
	if [ $OpenCMISS_SETUP_PYTHONPATH == true ]; then
	    if [ ! $OpenCMISS_PYTHON_VERSION ]; then
		which python >& /dev/null
		if [ $? == 0 ]; then
		    export OpenCMISS_PYTHON_MAJOR_VERSION=`python --version | cut -f2 -d' ' | cut -f1 -d.`
		    export OpenCMISS_PYTHON_MINOR_VERSION=`python --version | cut -f2 -d' ' | cut -f2 -d.`
		else
		    export OpenCMISS_PYTHON_MAJOR_VERSION=3
		    export OpenCMISS_PYTHON_MINOR_VERSION=12
		fi
		export OpenCMISS_PYTHON_VERSION=$OpenCMISS_PYTHON_MAJOR_VERSION.$OpenCMISS_PYTHON_MINOR_VERSION
	    fi
	    export OpenCMISS_PYTHON_PATH=$OpenCMISS_INSTALL_ROOT/$OpenCMISS_ARCHPATH_MPI/$OpenCMISS_BUILD_TYPE_ARCHPATH/$LIBAPI/python$OpenCMISS_PYTHON_VERSION/opencmiss
	    if [ \( -d $OpenCMISS_PYTHON_PATH \) ]; then
		if [ ! $?PYTHONPATH ]; then
		    export PYTHONPATH=$OpenCMISS_PYTHON_PATH
		else
		    export PYTHONPATH=$OpenCMISS_PYTHON_PATH:$PYTHONPATH
		fi
 	    fi
	fi
	
	# Setup LaTeX paths for OpenCMISS
	if [ $OpenCMISS_SETUP_LATEX == true ]; then
	    if [ \( -d $OpenCMISS_ROOT/documentation/notes/latex \) ]; then
		if [ \( -d $OpenCMISS_ROOT/documentation/notes/figures \) ]; then
		    if [ ! $?TEXINPUTS ]; then
			export TEXINPUTS=.:$OpenCMISS_ROOT/documentation/notes/latex//:$OpenCMISS_ROOT/documentation/notes/figures//:
		    else
			export TEXINPUTS=.:$OpenCMISS_ROOT/documentation/notes/latex//:$OpenCMISS_ROOT/documentation/notes/figures//:$TEXINPUTS:
		    fi
		else
		    if [ ! $?TEXINPUTS ]; then
			export TEXINPUTS=.:$OpenCMISS_ROOT/documentation/notes/latex//:
		    else
			export TEXINPUTS=.:$OpenCMISS_ROOT/documentation/notes/latex//:$TEXINPUTS:
		    fi
		fi    
 	    fi
	    if [ \( -d $OpenCMISS_ROOT/documentation/notes/references \) ]; then
		if [ ! $?BIBINPUTS ]; then
		    export BIBINPUTS=.:$OpenCMISS_ROOT/documentation/notes/references//:
		else
		    export BIBINPUTS=.:$OpenCMISS_ROOT/documentation/notes/references//:$BIBINPUTS:
		fi
		if [ ! $?BSTINPUTS ]; then
		    export BSTINPUTS=.:$OpenCMISS_ROOT/documentation/notes/references//:
		else
		    export BSTINPUTS=.:$OpenCMISS_ROOT/documentation/notes/references//:$BSTINPUTS:
		fi
	    fi
	    if [ ! \( -e $HOME/texTextPreamble.ini \) ]; then
		ln -s $OpenCMISS_ROOT/documentation/notes/latex/texTextPreamble.ini $HOME/texTextPreamble.ini
	    fi
	    alias latexmake='./Latex_make.sh'
	fi
	
	# Setup git prompt for OpenCMISS
	if [ $OpenCMISS_SETUP_GITPROMPT == true ]; then
	    if [ \( -r $OpenCMISS_ROOT/utilities/scripts/opencmiss_developer_gitprompt.sh \) ]; then
		. $OpenCMISS_ROOT/utilities/scripts/opencmiss_developer_gitprompt.sh
		
		# Prompt variables
		export PROMPT_BEFORE="\[\033[34m\]\u@\h \[\033[37m\]\w\[\033[0m\]"
		export PROMPT_AFTER=": "
		
		# Prompt command
		export PROMPT_COMMAND='__git_ps1 "$PROMPT_BEFORE" "$PROMPT_AFTER"'
		
		# Git prompt features (read ~/.git-prompt.sh for reference)
		export GIT_PS1_SHOWDIRTYSTATE="true"
		export GIT_PS1_SHOWSTASHSTATE="true"
		export GIT_PS1_SHOWUNTRACKEDFILES="true"
		export GIT_PS1_SHOWUPSTREAM="auto"
		export GIT_PS1_SHOWCOLORHINTS="true"
	    fi
	fi
	
	unset LIBAPI 
	unset SYSLIBAPI
	unset BINAPI
	unset INTELAPI
	;;
  *)
    echo "OpenCMISS: System name of $sysname is unknown."
    ;;
esac
    
unset sysname 
unset machine
