#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

MAIN_DIR="/work/neuro-software"
readonly script_name="${0##*/}"


######################
## SOFTWARE VERSION ##
######################
FREESURFER_VERSION=${FREESURFER_VERSION:="7.1.1"}
FSL_VERSION=${FSL_VERSION:="6.0.4"}
MATLAB_VERSION=${MATLAB_VERSION:="99"}
MATLAB_RELEASE=${MATLAB_RELEASE:="2020b"}
MATLAB_UPDATE=${MATLAB_UPDATE:="3"}
MINICONDA_VERSION=${MINICONDA_VERSION:="latest"}


#####################################
## SOFTWARE INSTALLATION FUNCTIONS ##
#####################################

## FreeSurfer ##
install_freesurfer() {

env="${FUNCNAME[0]/install/env}-${FREESURFER_VERSION}.sh"

## Set environment
{ echo export FREESURFER_VERSION=${FREESURFER_VERSION}; \
  echo export FREESURFER_HOME="${MAIN_DIR}/freesurfer-${FREESURFER_VERSION}"; \
  echo export PATH="${MAIN_DIR}/freesurfer-${FREESURFER_VERSION}/bin:\$PATH"; } > "${MAIN_DIR}/${env}"

## Software dependencies
cat >> "${MAIN_DIR}/${env}" << EOF
sudo apt-get update -qq \
&& sudo apt-get install -y -qq --no-install-recommends \
       	bc \
       	libgomp1 \
       	libxmu6 \
       	libxt6 \
       	perl \
       	tcsh \
&& sudo apt-get clean \
&& sudo rm -rf /var/lib/apt/lists/*
EOF

source "${MAIN_DIR}/${env}"

printf "\nDownloading FreeSurfer ..." \
&& mkdir -p ${MAIN_DIR}/freesurfer-${FREESURFER_VERSION} \
&& curl -fsSL --retry 5 https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${FREESURFER_VERSION}/freesurfer-linux-centos6_x86_64-${FREESURFER_VERSION}.tar.gz \
| tar -xz -C ${MAIN_DIR}/freesurfer-${FREESURFER_VERSION} --strip-components 1 \
     --exclude='freesurfer/average/mult-comp-cor' \
     --exclude='freesurfer/lib/cuda' \
     --exclude='freesurfer/lib/qt' \
     --exclude='freesurfer/subjects/V1_average' \
     --exclude='freesurfer/subjects/bert' \
     --exclude='freesurfer/subjects/cvs_avg35' \
     --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
     --exclude='freesurfer/subjects/fsaverage3' \
     --exclude='freesurfer/subjects/fsaverage4' \
     --exclude='freesurfer/subjects/fsaverage5' \
     --exclude='freesurfer/subjects/fsaverage6' \
     --exclude='freesurfer/subjects/fsaverage_sym' \
     --exclude='freesurfer/trctrain'
}

## FSL ##
install_fsl() {

env="${FUNCNAME[0]/install/env}-${FSL_VERSION}.sh"

## Set environment
{ echo export FSLDIR="${MAIN_DIR}/fsl-${FSL_VERSION}"; \
  echo export PATH="${MAIN_DIR}/fsl-${FSL_VERSION}/bin:\$PATH"; \
  echo export FSLOUTPUTTYPE="NIFTI_GZ"; \
  echo export FSLMULTIFILEQUIT="TRUE"; \
  echo export FSLTCLSH="${MAIN_DIR}/fsl-${FSL_VERSION}/bin/fsltclsh"; \
  echo export FSLWISH="${MAIN_DIR}/fsl-${FSL_VERSION}/bin/fslwish"; \
  echo export FSLLOCKDIR=""; \
  echo export FSLMACHINELIST=""; \
  echo export FSLREMOTECALL=""; \
  echo export FSLGECUDAQ="cuda.q"; } > "${MAIN_DIR}/${env}"

cat >> "${MAIN_DIR}/${env}" << EOF
sudo apt-get update -qq \
&& sudo apt-get install -y -qq --no-install-recommends \
       	bc \
       	dc \
       	file \
       	libfontconfig1 \
       	libfreetype6 \
       	libgl1-mesa-dev \
       	libgl1-mesa-dri \
       	libglu1-mesa-dev \
       	libgomp1 \
      	libice6 \
       	libxcursor1 \
       	libxft2 \
      	libxinerama1 \
       	libxrandr2 \
       	libxrender1 \
       	libxt6 \
       	wget \
&& sudo apt-get clean \
&& sudo rm -rf /var/lib/apt/lists/*
EOF

source "${MAIN_DIR}/${env}"

printf "\nDownloading FSL ..." \
&& mkdir -p ${MAIN_DIR}/fsl-${FSL_VERSION} \
&& curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-${FSL_VERSION}-centos6_64.tar.gz \
| tar -xz -C ${MAIN_DIR}/fsl-${FSL_VERSION} --strip-components 1

}

## MINICONDA ##
install_conda() {

env="${FUNCNAME[0]/install/env}-${MINICONDA_VERSION}.sh"

## Set environment
{ echo export CONDA_DIR="${MAIN_DIR}/miniconda-${MINICONDA_VERSION}"; \
  echo export PATH="${MAIN_DIR}/miniconda-${MINICONDA_VERSION}/bin:\$PATH"; } > "${MAIN_DIR}/${env}"

source "${MAIN_DIR}/${env}"

echo "Downloading Miniconda installer ..." \
&& conda_installer="/tmp/miniconda.sh" \
&& curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
&& bash "$conda_installer" -b -p "${CONDA_DIR}" \
&& rm -f "$conda_installer" \
&& conda update -yq -nbase conda \
&& conda config --system --prepend channels conda-forge \
&& conda config --system --set auto_update_conda false \
&& conda config --system --set show_channel_urls true \
&& sync && conda clean -y --all && sync \
&& conda create -y -q --name neuro \
&& conda install -y -q --name neuro \
       "jupyter" \
       "python=3.7" \
       "traits" \
       "numpy" \
       "pandas" \
&& sync && conda clean -y --all && sync \
&& bash -c "source activate neuro" \
&& pip install --no-cache-dir  \
       "nipype" \
&& rm -rf ~/.cache/pip/* \
&& sync

}

## MATLAB Runtime ##
install_matlabmcr() {

env="${FUNCNAME[0]/install/env}-${MATLAB_RELEASE}.sh"

## Set environment
{ echo export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE}/v${MATLAB_VERSION}/runtime/glnxa64:${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE}/v${MATLAB_VERSION}/bin/glnxa64:${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE}/v${MATLAB_VERSION}/sys/os/glnxa64:${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE}/v${MATLAB_VERSION}/extern/bin/glnxa64"; \
  echo export MATLABCMD="${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE}/v${MATLAB_VERSION}/toolbox/matlab"; } > "${MAIN_DIR}/${env}"

cat >> "${MAIN_DIR}/${env}" << EOF
sudo apt-get update -qq \
&& sudo apt-get install -y -q --no-install-recommends \
       	bc \
       	libncurses5 \
       	libxext6 \
       	libxmu6 \
       	libxpm-dev \
       	libxt6 \
&& sudo apt-get clean \
&& sudo rm -rf /var/lib/apt/lists/*
EOF

source "${MAIN_DIR}/${env}"

TMPDIR="$(mktemp -d)" \
&& export TMPDIR \
&& printf "\nDownloading MATLAB Compiler Runtime ..." \
&& curl -fsSL --retry 5 -o "$TMPDIR/mcr.zip" http://ssd.mathworks.com/supportfiles/downloads/R${MATLAB_RELEASE}/Release/${MATLAB_UPDATE}/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R${MATLAB_RELEASE}_Update_${MATLAB_UPDATE}_glnxa64.zip \
&& unzip -q "$TMPDIR/mcr.zip" -d "$TMPDIR/mcrtmp" \
&& "$TMPDIR/mcrtmp/install" -destinationFolder ${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE} -mode silent -agreeToLicense yes \
&& rm -rf "$TMPDIR" \
&& unset TMPDIR

}

## SPM12 ##
install_spm12() {

    if [ -d "${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE}" ]
    then
    	printf "MATLAB Runtime is already installed in %s\n" "${MAIN_DIR}/matlabmcr-${MATLAB_RELEASE}"
    	source "${MAIN_DIR}/env_matlabmcr-${MATLAB_RELEASE}.sh"
    else
    	install_matlabmcr
    	source "${MAIN_DIR}/env_matlabmcr-${MATLAB_RELEASE}.sh"
    fi

    env="${FUNCNAME[0]/install/env}.sh"

    { echo export FORCE_SPMMCR="1"; \
      echo export SPM_HTML_BROWSER="0"; } > "${MAIN_DIR}/${env}"

    source "${MAIN_DIR}/${env}"

    printf "\nDownloading standalone SPM12 ..." \
    && curl -fsSL --retry 5 -o /tmp/spm12.zip  https://www.fil.ion.ucl.ac.uk/spm/download/restricted/eldorado/spm12.zip \
    && unzip -qq /tmp/spm12.zip -d /tmp \
    && mkdir -p ${MAIN_DIR}/spm12 \
    && mv /tmp/spm12/* ${MAIN_DIR}/spm12 \
    && chmod -R 775 ${MAIN_DIR}/spm12 \
    && rm -rf /tmp/spm*
}

###################################
## SOFTWARE INSTALLATION OPTIONS ##
###################################

trap clean_up ERR EXIT SIGINT SIGTERM

usage() {
    cat << USAGE_TEXT
Usage: ./${script_name} [-h | --help] [-p | --path <ARG>] [-i | --install <ARG>]

DESCRIPTION
    Install neuroimaging software tools.

OPTIONS:
-p, --path
		Specify installation path (default is: /work/neuro-software).
-i, --install
		Specify software name from the following list:
		- conda 
		- freesurfer
		- fsl
		- matlabmcr
		- spm12
-h, --help
		Print command usage options.

USAGE_TEXT

}

clean_up() {
    ## Remove temporary files/directories, log files or rollback changes.
    trap - ERR EXIT SIGINT SIGTERM
    sudo rm -rf /tmp/*
}


## Available long options
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") 		set -- "$@" "-h" ;;
    "--path") 		set -- "$@" "-p" ;;
	"--install")	set -- "$@" "-i" ;;
    *)        		set -- "$@" "$arg"
  esac
done

## Available options
while getopts "hp:i:" option
do
	case "${option}" 
   	in
   		h) 	## Display help message
        	usage
        	exit;;
       	p) 	## Change default installation path
			MAIN_DIR=${OPTARG}
			mkdir -p "$MAIN_DIR";;
		i) 	## Install new software
			CMD=install_${OPTARG}
			if [ "$(type -t "$CMD")" != 'function' ]
			then
  				printf "Error: %s installation function not available.\n\n" "${OPTARG}" >&2
  				usage
  				exit
  			else
  				printf "\nInstall new software ...\n\n"
  				mkdir -p "${MAIN_DIR}"
  				$CMD
  				printf "\n\nSoftware installed.\n\n"
  			fi;;
     	\?) ## Invalid option
        	printf "Error: invalid option.\n\n"
         	usage
         	exit;;
   	esac
done

# shift "$((OPTIND-1))" # remove options from positional parameters
