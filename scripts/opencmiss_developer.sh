#!/bin/bash
# Sets up environment variables, paths etc. for an OpenCMISS developer

HOST=`hostname -s`
sysname=`uname -s`
machine=`uname -m`

# Make sure OPENCMISS_ROOT is an absolute path
if [ ! $OPENCMISS_ROOT ]; then
    echo "OpenCMISS: OPENCMISS_ROOT is not defined."
else
    if [ -r $OPENCMISS_ROOT ]; then
      export OPENCMISS_ROOT=`cd $OPENCMISS_ROOT && pwd `
    else
      echo "OpenCMISS: OPENCMISS_ROOT directory does not exist."
    fi
fi

# Make sure OPENCMISS_INSTALL_ROOT is an absolute path
if [ ! $OPENCMISS_INSTALL_ROOT ]; then
    export OPENCMISS_INSTALL_ROOT=$OPENCMISS_ROOT/install
else
    if [ -r $OPENCMISS_INSTALL_ROOT ]; then
      export OPENCMISS_INSTALL_ROOT=`cd $OPENCMISS_INSTALL_ROOT && pwd `
    else
      echo "OpenCMISS: OPENCMISS_INSTALL_ROOT directory does not exist."
    fi
fi

# Set defaults if not defined
if [ ! $OPENCMISS_SETUP_INTEL ]; then
    export OPENCMISS_SETUP_INTEL=true
fi
if [ ! $OPENCMISS_SETUP_TOTALVIEW ]; then
    export OPENCMISS_SETUP_TOTALVIEW=true
fi
if [ ! $OPENCMISS_SETUP_LATEX ]; then
    export OPENCMISS_SETUP_LATEX=true
fi
if [ ! $OPENCMISS_SETUP_PYTHONPATH ]; then
    export OPENCMISS_SETUP_PYTHONPATH=true
fi
if [ ! $OPENCMISS_SETUP_GITPROMPT ]; then
    export OPENCMISS_SETUP_GITPROMPT=true
fi
if [ ! $OPENCMISS_MPI_BUILD_TYPE ]; then
    export OPENCMISS_MPI_BUILD_TYPE=system
fi
if [ ! $OPENCMISS_BUILD_TYPE ]; then
    export OPENCMISS_BUILD_TYPE=release
fi

case $sysname in
    'AIX')
        export PROCESSOR_TYPE="`lsattr -El proc0 | grep "Processor type" | tr -s ' ' | cut -f2 -d" "`"
	case $PROCESSOR_TYPE in
	  'PowerPC_POWER7')
	    export OPENCMISS_ARCHNAME=power7-aix
	    ;;
	  'PowerPC_POWER6')
	    export OPENCMISS_ARCHNAME=power6-aix
	    ;;
	  'PowerPC_POWER5')
	    export OPENCMISS_ARCHNAME=power5-aix
	    ;;
	  'PowerPC_POWER4')
	    export OPENCMISS_ARCHNAME=power4-aix
	    ;;
	  *)
	    echo "OpenCMISS: The processor architecture of $PROCESSOR_TYPE is unknown for AIX."
	    export OPENCMISS_ARCHNAME=unknown-aix
	esac
	unset PROCESSOR_TYPE

	;;
    'Linux')
	export OPENCMISS_ARCHNAME=$machine-linux

	#Try and work out what linux distribution we are on
	if [ -r "/etc/SuSE-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=suse
	    export OPENCMISS_SUSE_RELEASE="`grep "VERSION" /etc/SuSE-release | cut -f2 -d"=" | tr -d " "`"."`grep "PATCHLEVEL" /etc/SuSE-release | cut -f2 -d"=" | tr -d " "`"
	elif [ -r "/etc/redhat-release" ]; then
	    #Work out if it is Red Hat, Fedora or Scientific Linux
            if [ -n "`grep "Red Hat Enterprise" /etc/redhat-release`" ] ; then
		export OPENCMISS_LINUX_DISTRIBUTION=redhat
	        export OPENCMISS_REDHAT_RELEASE=`cat /etc/redhat-release | cut -f7 -d" "`
            elif [ -n "`grep "Fedora" /etc/redhat-release`" ] ; then
		export OPENCMISS_LINUX_DISTRIBUTION=fedora
	        export OPENCMISS_FEDORA_RELEASE=`cat /etc/redhat-release | cut -f3 -d" "`
            elif [ -n "`grep "Scientific Linux" /etc/redhat-release`" ] ; then
		export OPENCMISS_LINUX_DISTRIBUTION=scientificlinux
	        export OPENCMISS_SCILINUX_RELEASE=`cat /etc/redhat-release | cut -f4 -d" " | cut -f1 -d"."`
            elif [ -n "`grep "CentOS" /etc/redhat-release`" ] ; then
		export OPENCMISS_LINUX_DISTRIBUTION=centos
	        export OPENCMISS_CENTOS_RELEASE=`cat /etc/redhat-release | cut -f4 -d" " | cut -f1 -d"."`
            else 
		echo "OpenCMISS: Can not determine Linux distribution from /etc/redhat-release."
		export OPENCMISS_LINUX_DISTRIBUTION=unknown
	    fi
	elif [ -r "/etc/redhat_version" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=redhat
	elif [ -r "/etc/fedora-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=fedora
	    export OPENCMISS_FEDORA_RELEASE=`cat /etc/fedora-release | cut -f3 -d" "`
	elif [ -r "/etc/slackware-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=slackware
	elif [ -r "/etc/slackware-version" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=slackware
	elif [ -r "/etc/lsb-release" ]; then
	    #Work out if it is Ubuntu or Mint
            if [ -n "`grep "DISTRIB_ID=Ubuntu" /etc/lsb-release`" ] ; then
		export OPENCMISS_LINUX_DISTRIBUTION=ubuntu
		export OPENCMISS_UBUNTU_RELEASE=`grep "DISTRIB_RELEASE" /etc/lsb-release | cut -f2 -d"="`
            elif [ -n "`grep "DISTRIB_ID=LinuxMint" /etc/lsb-release`" ] ; then
		export OPENCMISS_LINUX_DISTRIBUTION=mint
		export OPENCMISS_MINT_RELEASE=`grep "DISTRIB_RELEASE" /etc/lsb-release | cut -f2 -d"="`
            else 
		echo "OpenCMISS: Can not determine Linux distribution from /etc/lsb-release."
		export OPENCMISS_LINUX_DISTRIBUTION=unknown
	    fi
	elif [ -r "/etc/debian_release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=debian
	elif [ -r "/etc/debian_version" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=debian
	elif [ -r "/etc/mandrake-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=mandrake
	elif [ -r "/etc/yellowdog-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=yellowdog
	elif [ -r "/etc/sun-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=sun
	elif [ -r "/etc/release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=solaris
	elif [ -r "/etc/gentoo-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=gentoo
	elif [ -r "/etc/UnitedLinux-release" ]; then
	    export OPENCMISS_LINUX_DISTRIBUTION=unitedlinux
        else
	    echo "OpenCMISS: Can not read /etc/issue. Linux distribution is unknown."
	    export OPENCMISS_LINUX_DISTRIBUTION=unknown
        fi

	case $OPENCMISS_LINUX_DISTRIBUTION in
	  'ubuntu')
	    case $OPENCMISS_ARCHNAME in
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
                echo "OpenCMISS: Architecture name of $OPENCMISS_ARCHNAME is unknown."
	    esac
	    ;;
	  'mint')
	    case $OPENCMISS_ARCHNAME in
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
                echo "OpenCMISS: Architecture name of $OPENCMISS_ARCHNAME is unknown."
	    esac
	    ;;
	  *)	  
	    case $OPENCMISS_ARCHNAME in
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
                echo "OpenCMISS: Architecture name of $OPENCMISS_ARCHNAME is unknown."
	    esac
	esac

	#Setup intel compilers if defined
	if [ $OPENCMISS_SETUP_INTEL == true ]; then
	    if [ ! $INTEL_ROOT ]; then
		export INTEL_ROOT=/opt/intel
	    fi
	    #Add in intel compilers if defined
	    if [ -x "$INTEL_ROOT/compilers_and_libraries/linux/bin/compilervars.sh" ]; then
		. $INTEL_ROOT/compilers_and_libraries/linux/bin/compilervars.sh $INTELAPI
		if [ -x "$INTEL_ROOT/compilers_and_libraries/linux/mkl/bin/mklvars.sh" ]; then
		    . $INTEL_ROOT/compilers_and_libraries/linux/mkl/bin/mklvars.sh $INTELAPI
		fi
	    else
		#Add in the newer version of the compilers
		if [ -x "$INTEL_ROOT/composerxe/bin/compilervars.sh" ]; then
		    . $INTEL_ROOT/composerxe/bin/compilervars.sh $INTELAPI
		    if [ -x "$INTEL_ROOT/mkl/bin/mklvars.sh" ]; then
			. $INTEL_ROOT/mkl/bin/mklvars.sh $INTELAPI
		    fi
		else
		    if [ -x "$INTEL_ROOT/bin/compilervars.sh" ]; then
			#Newer version of intel compilers
			. $INTEL_ROOT/bin/compilervars.sh $INTELAPI
			if [ -x "$INTEL_ROOT/mkl/bin/mklvars.sh" ]; then
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
			if [ -x "$INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/ifortvars.sh" ]; then
			    . $INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/ifortvars.sh $INTELAPI
			fi
			if [ -x "$INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/iccvars.sh" ]; then
			    . $INTEL_ROOT/Compiler/$INTEL_COMPILER_VERSION/$INTEL_COMPILER_BUILD/bin/iccvars.sh $INTELAPI
			fi
		    fi
		fi
	    fi
	    # Setup Intel advisor if it is installed
	    if [ -x "$INTEL_ROOT/advisor/advixe-vars.csh" ]; then
		. $INTEL_ROOT/advisor/advixe-vars.sh quiet
	    fi
	    # Setup Intel inspector if it is installed
	    if [ -x "$INTEL_ROOT/inspector/inspxe-vars.csh" ]; then
		. $INTEL_ROOT/inspector/inspxe-vars.sh quiet
	    fi    		
	fi

	if [ $OPENCMISS_SETUP_TOTALVIEW == true ]; then
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
		if [ -d $TOTALVIEW_PATH ]; then
		    if [ ! $TOTALVIEW_VERSION ]; then
			export TOTALVIEW_VERSION1=`ls $TOTALVIEW_PATH | grep -i totalview | tail -1 | cut -f2 -d.`
			if [ -n $TOTALVIEW_VERSION1 ]; then
			    export TOTALVIEW_VERSION2=`ls $TOTALVIEW_PATH | grep -i totalview | tail -1 | cut -f3 -d.`
			    if [ -n $TOTALVIEW_VERSION2 ]; then
				export TOTALVIEW_VERSION3=`ls $TOTALVIEW_PATH | grep -i totalview | tail -1 | cut -f4 -d.`
				if [ -n $TOTALVIEW_VERSION3 ]; then
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
	    if [ -d $TOTALVIEW_PATH ]; then
		if [ ! $FLEXLM_VERSION ]; then
		    export FLEXLM_VERSION1=`ls $TOTALVIEW_PATH | grep -i flexlm | tail -1 | cut -f2 -d'-'`
		    if [ -n $FLEXLM_VERSION1 ]; then
			export FLEXLM_VERSION2=`ls $TOTALVIEW_PATH | grep -i flexlm | tail -1 | cut -f3 -d'-'`
			if [ -n $FLEXLM_VERSION2 ]; then
			    export FLEXLM_VERSION=$FLEXLM_VERSION1-$FLEXLM_VERSION2
			fi
			unset FLEXLM_VERSION1
		    fi
		    unset FLEXLM_VERSION1
		fi
		#Add in totalview path
		if [ $TOTALVIEW_VERSION ]; then
		    if [ -d "$TOTALVIEW_PATH/totalview.$TOTALVIEW_VERSION/bin" ]; then
			if [ -z "$PATH" ]; then
			    export PATH=$TOTALVIEW_PATH/totalview.$TOTALVIEW_VERSION/bin
			else
			    export PATH=$TOTALVIEW_PATH/totalview.$TOTALVIEW_VERSION/bin:$PATH
			fi
		    fi
		fi
		#Add in FlexLM path
		if [ $FLEXLM_VERSION ]; then
		    if [ -d "$TOTALVIEW_PATH/flexlm-$FLEXLM_VERSION" ]; then
			if [ -z "$LM_LICENSE_FILES" ]; then
			    export LM_LICENSE_FILESPATH=$TOTALVIEW_PATH/flexlm-$FLEXLM_VERSION
			else
			    export LM_LICENSE_FILESPATH=$TOTALVIEW_PATH/flexlm-$FLEXLM_VERSION:$LM_LICENSE_FILES
			fi
		    fi
		fi
	    fi
	fi

	if [ $OPENCMISS_TOOLCHAIN ]; then
	    case $OPENCMISS_TOOLCHAIN in
	      'gnu')
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
	      'intel')
		which icc >& /dev/null		
		if [ $? == 0 ]; then
		    export INTEL_ICC_MAJOR_VERSION=`icc --version | grep ICC | cut -c 11-12`
		    export INTEL_ICC_MINOR_VERSION=`icc --version | grep ICC | cut -c 14`
		    export C_COMPILER_STRING=intel-C$INTEL_ICC_MAJOR_VERSION.$INTEL_ICC_MINOR_VERSION
		    unset INTEL_ICC_MAJOR_VERSION    
		    unset INTEL_ICC_MINOR_VERSION    
		else
		    export C_COMPILER_STRING=unknown
		fi
		which ifort >& /dev/null		
		if [ $? == 0 ]; then
		    export INTEL_IFORT_MAJOR_VERSION=`ifort --version | grep IFORT | cut -c 15-16`
		    export INTEL_IFORT_MINOR_VERSION=`ifort --version | grep IFORT | cut -c 18`
		    export FORTRAN_COMPILER_STRING=intel-F$INTEL_IFORT_MAJOR_VERSION.$INTEL_IFORT_MINOR_VERSION
		    unset INTEL_IFORT_MAJOR_VERSION    
		    unset INTEL_IFORT_MINOR_VERSION    
		else
		    export FORTRAN_COMPILER_STRING=unknown
		fi
		;;
	      *)
		echo "OpenCMISS: OPENCMISS_TOOLCHAIN of $OPENCMISS_TOOLCHAIN is unknown."
		export C_COMPILER_STRING=unknown
		export FORTRAN_COMPILER_STRING=unknown
	    esac
	    export OPENCMISS_COMPILER_ARCHPATH=$C_COMPILER_STRING-$FORTRAN_COMPILER_STRING
	    unset C_COMPILER_STRING
	    unset FORTRAN_COMPILER_STRING
	fi

	# If MKL has been found, set some environment variables used by the MKL single dynamic library
	if [ $?MKLROOT ]; then
	    if [ $?OPENCMISS_USE_MKL_THREADING ]; then
		case $OPENCMISS_TOOLCHAIN in
		  'intel')
		    export MKL_THREADING_LAYER=INTEL
		    ;;
		  'gnu')
		    export MKL_THREADING_LAYER=GNU
		    ;;
		  'ibm')
		    ;;
		  *)
		    echo "OpenCMISS: OPENCMISS_TOOLCHAIN of ${OPENCMISS_TOOLCHAIN} is unknown."
		    ;;
		esac
	    else
	        export MKL_THREADING_LAYER=SEQUENTIAL
	    fi
	    export MKL_INTERFACE_LAYER=LP64
	fi

	if [ ! $OPENCMISS_INSTRMENTATION ]; then
	    export OPENCMISS_INSTRUMENTATION_ARCHPATH=''
	else
	    case $OPENCMISS_INSTRUMENTATION in
	      'scorep')
		export OPENCMISS_INSTRUMENTATION_ARCHPATH=-scorep
		;;
	      'gprof')
		export OPENCMISS_INSTRUMENTATION_ARCHPATH=-gprof      
		;;
	      'vtune')
		export OPENCMISS_INSTRUMENTATION_ARCHPATH=-vtune      
		;;
	      'none')
		export OPENCMISS_INSTRUMENTATION_ARCHPATH='' 
		;;
	      *)
		echo "OpenCMISS: OPENCMISS_INSTRUMENTATION of ${OPENCMISS_INSTRUMENTATION} is unknown."
		export OPENCMISS_INSTRUMENTATION_ARCHPATH=-unknown
	    esac
	fi

	if [ ! $OPENCMISS_MULTITHREADING ]; then
	    export OPENCMISS_MULTITHREADING_ARCHPATH=''
	else
	    export OPENCMISS_MULTITHREADING_ARCHPATH=mt
	fi
    
	if [ $?OPENCMISS_MPI ]; then
	    case $OPENCMISS_MPI in
	      'none')
		export MPI_STRING=''
		;;
	      'mpich')
		export MPI_STRING=mpich
		case $OPENCMISS_LINUX_DISTRIBUTION in
		  'fedora')
		    #Fedora doesn't include mpich in the path by default
		    if [ -z "$PATH" ]; then
			export PATH=/usr/$LIBAPI/mpich/bin
		    else
			export PATH=/usr/$LIBAPI/mpich/bin:$PATH
		    fi
		    if [ -z "$LD_LIBRARY_PATH" ]; then
			export LD_LIBRARY_PATH=/usr/$LIBAPI/mpich/lib
		    else
			export LD_LIBRARY_PATH=/usr/$LIBAPI/mpich/lib:$LD_LIBRARY_PATH
		    fi
		    ;;
		esac
		;;
	      'mpich2')
		export MPI_STRING=mpich2
		;;
	      'openmpi')
		export MPI_STRING=openmpi
		case $OPENCMISS_LINUX_DISTRIBUTION in
		  'fedora')
		    #Fedora doesn't include openmpi in the path by default
		    if [ -z "$PATH" ]; then
			export PATH=/usr/$LIBAPI/openmpi/bin
		    else
			export PATH=/usr/$LIBAPI/openmpi/bin:$PATH
		    fi
		    if [ -z "$LD_LIBRARY_PATH" ]; then
			export LD_LIBRARY_PATH=/usr/$LIBAPI/openmpi/lib
		    else
			export LD_LIBRARY_PATH=/usr/$LIBAPI/openmpi/lib:$LD_LIBRARY_PATH
		    fi
		    ;;
		esac
		;;
	      'mvapich2')
		export MPI_STRING=mvapich2
		;;
	      'msmpi')
		export MPI_STRING=msmpi
		;;
	      'intel')
		export MPI_STRING=intel
		#Newer Intel directory structure
		if [ -d "$INTEL_ROOT/itac_latest" ]; then
		    #New Itac directory structure
		    if [ -r "$INTEL_ROOT/itac_latest/bin/itacvars.sh" ]; then
			. $INTEL_ROOT/itac_latest/bin/itacvars.sh
		    fi
		else
		    if [ ! $INTEL_TRACE_COLLECTOR_VERSION ]; then
			export INTEL_TRACE_COLLECTOR_VERSION=1.2.3
		    fi
		    #Old Itac directory structure
		    if [ -r "$INTEL_ROOT/itac/$INTEL_TRACE_COLLECTOR_VERSION/bin/itacvars.sh" ]; then
			. $INTEL_ROOT/itac/$INTEL_TRACE_COLLECTOR_VERSION/bin/itacvars.sh impi4
		    fi
		fi
		#Newer Intel MPI directory structure
		if [ -r "$INTEL_ROOT/compilers_and_libraries/linux/mpi/$BINAPI/mpivars.sh" ]; then
		    . $INTEL_ROOT/compilers_and_libraries/linux/mpi/$BINAPI/mpivars.sh
		else
		    if [ -d "$INTEL_ROOT/impi/latest" ]; then
			#New Intel MPI directory structure. Use latest directory
			if [ -r "$INTEL_ROOT/impi/latest/$BINAPI/mpivars.sh" ]; then
			    . $INTEL_ROOT/impi/latest/$BINAPI/mpivars.csh
			fi
		    else			    
			if [ -d "$INTEL_ROOT/impi_latest" ]; then
			    #New Intel MPI directory structure. Use latest directory
			    if [ -r "$INTEL_ROOT/impi_latest/$BINAPI/mpivars.sh" ]; then
				    . $INTEL_ROOT/impi_latest/$BINAPI/mpivars.sh
			    fi
			else
			    if [ ! $INTEL_MPI_VERSION ]; then
				export INTEL_MPI_VERSION=1.2.3
			    fi
			    #Old Intel MPI directory strucutre. Use specific version
			    if [ -r "$INTEL_ROOT/impi/$INTEL_MPI_VERSION/$BINAPI/mpivars.sh" ]; then
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
		echo "OpenCMISS: OPENCMISS_MPI of $OPENCMISS_MPI is unknown."
		export MPI_STRING=unknown
	    esac
	    export OPENCMISS_MPI_ARCHPATH=$MPI_STRING
	    export OPENCMISS_NOMPI_ARCHPATH=no_mpi
	    unset MPI_STRING
	else
	    export OPENCMISS_MPI_ARCHPATH=''
	    export OPENCMISS_NOMPI_ARCHPATH=''	    
	fi

        if [ $?OPENCMISS_MPI_BUILD_TYPE ]; then
	    case $OPENCMISS_MPI_BUILD_TYPE in
	      'debug')
		export MPI_BUILD_TYPE_STRING=_debug
		;;
	      'release')
		export MPI_BUILD_TYPE_STRING=_release
		;;
	      'relwithdebinfo')
		export MPI_BUILD_TYPE_STRING=_relwithdebinfo
		;;
	      'system')
		export MPI_BUILD_TYPE_STRING=_system
		;;
	      *)
		echo "OpenCMISS: OPENCMISS_MPI_BUILD_TYPE of $OPENCMISS_MPI_BUILD_TYPE is unknown."
		export MPI_BUILD_TYPE_STRING=unknown		    
	    esac
	    export OPENCMISS_MPI_ARCHPATH=$OPENCMISS_MPI_ARCHPATH$MPI_BUILD_TYPE_STRING
	    unset MPI_BUILD_TYPE_STRING
	fi
    
	if [ ! $OPENCMISS_BUILD_TYPE ]; then
	    export OPENCMISS_BUILD_TYPE_ARCHPATH=''
	else
	    case $OPENCMISS_BUILD_TYPE in
	      'debug')
		export BUILD_TYPE_STRING=debug
		;;
	      'Debug')
		export BUILD_TYPE_STRING=Debug
		;;
	      'release')
		export BUILD_TYPE_STRING=release
		;;
	      'Release')
		export BUILD_TYPE_STRING=Release
		;;
	      'relwithdebinfo')
		export BUILD_TYPE_STRING=relwithdebinfo
		;;
	      'RelwithDebInfo')
		export BUILD_TYPE_STRING=RelwithDebInfo
		;;
	      'minsizerel')
		export BUILD_TYPE_STRING=minsizerel
		;;
	      'MinSizeRel')
		export BUILD_TYPE_STRING=MinSizeRel
		;;
	      *)
		echo "OpenCMISS: OPENCMISS_BUILD_TYPE of $OPENCMISS_BUILD_TYPE is unknown."
		export BUILD_TYPE_STRING=unknown		    
	    esac
	    export OPENCMISS_BUILD_TYPE_ARCHPATH=$BUILD_TYPE_STRING
	    unset BUILD_TYPE_STRING	
	fi

        case $OPENCMISS_ARCHNAME in
	  'i686-linux')
	    export OPENCMISS_SYSTEM_ARCHPATH=i686_linux
	    ;;    
	  'x86_64-linux')
	    export OPENCMISS_SYSTEM_ARCHPATH=x86_64_linux
	    ;;
	  *)
	    echo "OpenCMISS: OPENCMISS_ARCHNAME of $OPENCMISS_ARCHNAME is unknown."
	    export OPENCMISS_SYSTEM_ARCHPATH='' 
        esac
	    
	export OPENCMISS_ARCHPATH_MPI=$OPENCMISS_SYSTEM_ARCHPATH/$OPENCMISS_COMPILER_ARCHPATH$OPENCMISS_INSTRUMENTATION_ARCHPATH$OPENCMISS_MULTITHREADING_ARCHPATH/$OPENCMISS_MPI_ARCHPATH
	export OPENCMISS_ARCHPATH_NOMPI=$OPENCMISS_SYSTEM_ARCHPATH/$OPENCMISS_COMPILER_ARCHPATH$OPENCMISS_INSTRUMENTATION_ARCHPATH$OPENCMISS_MULTITHREADING_ARCHPATH/$OPENCMISS_NOMPI_ARCHPATH

	# Add installed binary directories to path
	if [ -d $OPENCMISS_INSTALL_ROOT/$OPENCMISS_ARCHPATH_NOMPI/bin ]; then
	    if [ ! $?PATH ]; then
		export PATH=$OPENCMISS_INSTALL_ROOT/$OPENCMISS_ARCHPATH_NOMPI/bin
	    else
		export PATH=$OPENCMISS_INSTALL_ROOT/$OPENCMISS_ARCHPATH_NOMPI/bin:$PATH
	    fi
    	fi    
	if [ -d $OPENCMISS_INSTALL_ROOT/$OPENCMISS_ARCHPATH_MPI/bin ]; then
	    if [ ! $?PATH ]; then
		export PATH=$OPENCMISS_INSTALL_ROOT/$OPENCMISS_ARCHPATH_MPI/bin
	    else
		export PATH=$OPENCMISS_INSTALL_ROOT/$OPENCMISS_ARCHPATH_MPI/bin:$PATH
	    fi
	fi

	# Setup python path for OpenCMISS
	if [ $OPENCMISS_SETUP_PYTHONPATH == true ]; then
	    if [ ! $OPENCMISS_PYTHON_VERSION ]; then
		which python >& /dev/null
		if [ $? == 0 ]; then
		    export OPENCMISS_PYTHON_MAJOR_VERSION=`python --version | cut -f2 -d' ' | cut -f1 -d.`
		    export OPENCMISS_PYTHON_MINOR_VERSION=`python --version | cut -f2 -d' ' | cut -f2 -d.`
		else
		    export OPENCMISS_PYTHON_MAJOR_VERSION=2
		    export OPENCMISS_PYTHON_MINOR_VERSION=7
		fi
		export OPENCMISS_PYTHON_VERSION=$OPENCMISS_PYTHON_MAJOR_VERSION.$OPENCMISS_PYTHON_MINOR_VERSION
	    fi
	    export OPENCMISS_PYTHON_PATH=$OPENCMISS_INSTALL_ROOT/$OPENCMISS_ARCHPATH_MPI/lib/python$OPENCMISS_PYTHON_VERSION/$OPENCMISS_BUILD_TYPE_ARCHPATH/opencmiss.iron
	    if [ -d $OPENCMISS_PYTHON_PATH ]; then
		if [ ! $?PYTHONPATH ]; then
		    export PYTHONPATH=$OPENCMISS_PYTHON_PATH
		else
		    export PYTHONPATH=$OPENCMISS_PYTHON_PATH:$PYTHONPATH
		fi
 	    fi
	fi

	# Setup LaTeX paths for OpenCMISS
	if [ ${OPENCMISS_SETUP_LATEX} == true ]; then
	    if [ -d $OPENCMISS_ROOT/documentation/notes/latex ]; then
		if [ -d $OPENCMISS_ROOT/documentation/notes/figures ]; then
		    if [ ! $?TEXINPUTS ]; then
			export TEXINPUTS=.:$OPENCMISS_ROOT/documentation/notes/latex//:$OPENCMISS_ROOT/documentation/notes/figures//:
		    else
			export TEXINPUTS=.:$OPENCMISS_ROOT/documentation/notes/latex//:$OPENCMISS_ROOT/documentation/notes/figures//:$TEXINPUTS:
		    fi
		else
		    if [ ! $?TEXINPUTS ]; then
			export TEXINPUTS=.:$OPENCMISS_ROOT/documentation/notes/latex//:
		    else
			export TEXINPUTS=.:$OPENCMISS_ROOT/documentation/notes/latex//:$TEXINPUTS:
		    fi
		fi    
 	    fi
	    if [ -d $OPENCMISS_ROOT/documentation/notes/references ]; then
		if [ ! $?BIBINPUTS ]; then
		    export BIBINPUTS=.:$OPENCMISS_ROOT/documentation/notes/references//:
		else
		    export BIBINPUTS=.:$OPENCMISS_ROOT/documentation/notes/references//:$BIBINPUTS:
		fi
		if [ ! $?BSTINPUTS ]; then
		    export BSTINPUTS=.:$OPENCMISS_ROOT/documentation/notes/references//:
		else
		    export BSTINPUTS=.:$OPENCMISS_ROOT/documentation/notes/references//:$BSTINPUTS:
		fi
	    fi
	    if [ ! -e ~/texTextPreamble.ini ]; then
		ln -s $OPENCMISS_ROOT/documentation/notes/latex/texTextPreamble.ini ~/texTextPreamble.ini
	    fi
	    alias latexmake='./Latex_make.sh'
	fi
	
	# Setup git prompt for OpenCMISS
	if [ ${OPENCMISS_SETUP_GITPROMPT} == true ]; then
	    if [ -r $OPENCMISS_ROOT/utilities/scripts/opencmiss_developer_gitprompt.sh ]; then
		. $OPENCMISS_ROOT/utilities/scripts/opencmiss_developer_gitprompt.sh
		
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
