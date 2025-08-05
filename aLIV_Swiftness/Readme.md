Example scripts for aLIV and Swiftness computation
===================================================

Note: This simlified example is based on an [open-source COG dyanmic-OCT contrast library](https://github.com/ComputationalOpticsGroup/COG-dynamic-OCT-contrast-generation-library)
(Release: COG-DOCT_v1.0.1).
The full and latest version can be found at the GitHub repository (the link above).

# How to install
This example is mainly written by Python 3.8.20 and the Python libraries listed below. 
## Requirements
- [NumPy](https://numpy.org/) (version 1.19.2 or newer)
- [tifffile](https://pypi.org/project/tifffile/) (version 2020.10.1 or newer)
- [tqdm](https://pypi.org/project/tqdm/) (version 4.50.2 or newer)
- [opencv-python](https://pypi.org/project/opencv-python/) (version 4.0.1 or newer)
- [SciPy](https://scipy.org/) (version 1.5.2 or newer)
- [skimage](https://scikit-image.org/) (version 0.17.2 or newer)
- [Matplotlib](https://matplotlib.org/) (version 3.3.2 or newer)

The default version of this program uses GPU to accelerate the computation and requires following library.
You can disabel the GPU accerelation by replacing CuPy function by NumPy functions, and disable GPU fit algorithm (see the latter section "How to use (or to disable) GPUfit.").
- [CuPy](https://cupy.dev/) (version 10.0.0 or newer; Please follow [Cupy installation](https://docs.cupy.dev/en/stable/install.html).)
- [CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit) (version 11.8.0)

This version of the software includes pre-complied GPU-based fitting function for Windows.
If you use the GPU-based fitting on other types of OS, the following library is required.
- [Gpufit](https://github.com/gpufit/Gpufit.git)

### Environment file for Anaconda
If you use Anaconda to run the program, the environment file ([cog38env.yml](doc/cog38env.yml)) for Anaconda navigator is available.
Anaconda navigator is a tool to launch applications and manage environments without command line commands; [[Download](https://www.anaconda.com/download)].

Use Anaconda powershell prompt for the following steps:
- The environment file : [cog38env.yml](doc/cog38env.yml)
1. Environment is created from the environment file (cog38env.yml).
	```
	conda env create -n cog38env -f cog38env.yml
	```
2. You can check that the environment has been correctly installed.
	```
	conda env list
	```

## General installation
1. Put all files on your PC as keeping the directory structure.

## Enable/disable GPU accerelation
This example uses two types of GPU accelaration including (1) CuPy (alternating NumPy), and (2) Gpufit library to accelerate curve fittig operation.
The Gpufit library is primarily written in C, and we inlcude a pre-compiled dll file only for Windows.
See follwoing for how to adapt (enable/disable) the GPU environment and how to recompline the fitting function (based on Gpufit library) on your environment.

### How to use (or to disable) GPUfit

**Using pre-compiled fitting fuction for Windows**
1. The included Gpufit has newly compiled a model function (i.e., 1st order saturation function), and the "Gpufit.dll" and "gpufit.py" has been stored in a "pygpufit" folder. 
2. Put the "Gpufit.dll" and "gpufit.py" on your PC as keeping the directory structure.

**Compile fitting function on your environment** 

The compile method can be found in the [Gpufit document](https://gpufit.readthedocs.io/en/latest/installation.html#building-from-source-code). In short,
1. Download the source code from the [Gpufit GitHub](https://github.com/gpufit/Gpufit.git).
2. Define an additional "model ID" (e.g., SATURATION_1D = 13) in "constants.h" file. The model IDs usable in the call of the Gpufit are defined in "constants.h" file.
3. Create a new cuh file for the new model function (e.g., saturation_1d.cuh) according to the other cuh files in [Gpufit GitHub](https://github.com/gpufit/Gpufit/tree/master/Gpufit/models).
4. Implement a CUDA device function and fitting model functions in the newly created cuh file.
5. In "models.cuh" file, include the newly created cuh file name, add a switch case in the CUDA device function "calculate_model()", and add a swich case in "configure_model()" function to allow calling the newly added model function.
6. Re-build the Gpufit project.
7. Add the newly added model ID in "gpufit.py" file.
8. Put "Gpufit.dll" and "gpufit.py" files in the location of "aLIV_Swiftness/VLIV/pygpufit/".

**Disable GPUfit**

If you are not comfortable to use Gpufit, you can disable it as follows. 
But please note that disabling of Gpufit will cause significant (around 831 times) slowing down of the computation, such as 2.1 min/volume with Gpufit to 160.54 min/volume without Gpufit.
1. Define "fitting method", which is one of the inputs for the function "vliv_postprocessing()",
as "CPU" instead of "GPU". "CPU" uses CPU-based function fitting, while "GPU" uses Gpufit library.


# How to use

There are two main example scripts as follows.

**exe_computeAlivSwiftness.py** is an example Python script to compute aLIV and Swiftness from the time sequence of OCT images.
The input is a linear-scaled OCT intensity raw data, which is designated as a file path in Line 14 of this Python script.
The avairable data input is a 3D array aligned as [time, z, x] or [time, x, z] with a data type "float 32". 
The raw data and pseudo-color images of computed aLIV and Swiftness are saved at the same location with the input file. 

**exe_makePseudoColorImage_useTwoContrasts.py** is an example Python script to generate pseudo-color images based on both aLIV and Swiftness.
Swiftness, aLIV, and dB-scaled OCT intensity are assigned as hue, saturation, and brightness, respectively.
The input is the common path of dB-scaled OCT intensity, aLIV, and Swiftness, which is designated as a file path in Line 11 of this Python script.
The pseudo-color image is saved at the same location with the input path.

# Files
Except for the above mentioned main example scripts, this example folder consists of follwoing files.

- **Readme.md**: This file.

In "lib" folder:
- **postprocess_vliv.py** defines methods (functios) for computing aLIV and Swiftness.
- **variableLIV.py** defines methods (functios) for frame re-alignment, bulk-motion correction, LIV computation, and function fitting. 
- **colorizeImage.py** defines methods (functios) for making pseudo-color image for each aLIV and Swiftness.
- **imagecolorizer.py** defines methods (functios) for making pseudo-color image by fusing aLIV and Swiftness.
- **pygpufit** folder includes **\_\_init\_\_.py**, **Gpufit.dll**, and **gpufit.py**.

In "doc" folder:
- **cog38env.yml** is the environment file, which enables to install all requirements in Anaconda navigator.


The relationships between each example script and library file are as follows:
- **exe_computeAlivSwiftness.py** <--import-- **postprocess_vliv** <--import-- **variableLIV**, **colorizeImage**
- **variableLIV** <--import-- **gpufit**
- **exe_makePseudoColorImage_useTwoContrasts.py** <--import-- **imagecolorizer**





# Lisence terms
This library is licensed under either of the following options.
1. GNU lesser general public license version 3 (LGPLv3).
2. Any licenses except for GNU LGPLv3 as far as the authors and the uses agree for it. It may include business licenses, closed-source licenses, and others. 
 
Option 1 (GNU LGPLv3) can be selected without notifying the authors. (However, it is recommended to cite [open-source COG dyanmic-OCT contrast library](https://github.com/ComputationalOpticsGroup/COG-dynamic-OCT-contrast-generation-library)
and the proper reference paper "R. Morishita et.al., arXiv 2412.09351 (2024)" when you publish research papers using this library.)
If you want to select any other licensing conditions except for GNU LGPLv3 (i.e., Option 2), please contact the corresponding author (Yoshiaki Yasuno, University of Tsukuba, <yoshiaki.yasuno@cog-labs.org>) to obtain an explicit agreement.