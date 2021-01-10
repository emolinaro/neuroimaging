# Neuroimaging Software Tools

The program must be used to install and configure neuroimaging software tools on Ubuntu-based Linux distributions.

On UCloud the program was tested using the apps [Ubuntu Xfce](https://docs.cloud.sdu.dk/Apps/ubuntu.html) and [Terminal Ubuntu](https://docs.cloud.sdu.dk/Apps/terminal.html).


## Usage

```
Usage: ./neuro.sh [-h | --help] [-p | --path <ARG>] [-i | --install <ARG>]

DESCRIPTION
    Install neuroimaging software tools.

OPTIONS:
-p, --path
        Specify the installation path (default is: /work/neuro-software).
-i, --install
        Specify software name from the following list:
        - afni
        - freesurfer
        - fsl
        - matlabmcr
        - miniconda
        - spm12
-h, --help
        Print command usage options.

```

The default installation path is: `/work/neuro-software`. This can be changed using the option `-p` (`--path`). 

The folder structure looks like the following:
```
neuro-software/
|-- env_miniconda-4.7.12.sh
|-- env_miniconda-latest.sh
|-- env_freesurfer-7.1.1.sh
|-- env_fsl-6.0.4.sh
|-- env_matlabmcr-2019b.sh
|-- env_matlabmcr-2020b.sh
|-- env_spm12-r7771.sh
|-- freesurfer-7.1.1/
|-- fsl-6.0.4/
|-- matlabmcr-2019b/
|-- matlabmcr-2020b/
|-- miniconda-4.7.12/
|-- miniconda-latest/
|-- spm12-r7771/
```

For each software a script named as `env_<software>-<release>.sh` is automatically generated. The script should be used to set the software environmental variables: 
```
source env_<name>-<release>.sh
```

Multiple software releases can be installed by specifying the corresponding version in the command line, e.g.:
```
MINICONDA_VERSION=4.7.12 ./neuro.sh --install miniconda
```

## Supported software

- [Analysis of Functional Neuro Images (AFNI)](https://afni.nimh.nih.gov/)
- [FreeSurfer](https://surfer.nmr.mgh.harvard.edu/)
- [FMRIB Software Library (FSL)](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
- [MATLAB Compiler Runtime (MCR)](https://www.mathworks.com/products/compiler/matlab-runtime.html)
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- [Standalone Statistical Parametric Mapping (SPM)](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)

## License

The code for the software installation functions is generated with the [Neurodocker](https://github.com/ReproNim/neurodocker) command-line program. 



