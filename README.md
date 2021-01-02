# Neuroimaging Software Tools

This program install neuroimaging software tools on Ubuntu based machines.

On UCloud the script was tested using the apps [Ubuntu VDE](https://docs.cloud.sdu.dk/Apps/ubuntu.html) and [Terminal Ubuntu](https://docs.cloud.sdu.dk/Apps/terminal.html).


## Usage

```
Usage: ./neuro.sh [-h | --help] [-p | --path <ARG>] [-i | --install <ARG>]

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

```

## Supported software

- [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- [FreeSurfer](https://surfer.nmr.mgh.harvard.edu/)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
- [MATLAB Runtime](https://www.mathworks.com/products/compiler/matlab-runtime.html)
- [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)

## License

The code for the software installation functions is generated suing the [Neurodocker](https://github.com/ReproNim/neurodocker) command-line program. 



