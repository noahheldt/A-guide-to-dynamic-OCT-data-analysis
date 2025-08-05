"""
This code example is for generating pseudo-color images based on aLIV and Swiftness.
"""

import tifffile
import lib.imagecolorizer as icz
    
    
    
## Input file path (common path of all input data)
dataFileId = r"D:\aaa\MCF7_Spheroid"

## Input parameters-------------------------------
# 1D tuple (min, max) of dynamic range.
octRange = (10., 40.) # dB-scaled OCT intensity
alivRange =(0., 5.) # aLIV
swiftRange =(0., 3.) # Swiftness
##------------------------------------------------

newLoad = 1
if newLoad == 1:
    Swiftness = tifffile.imread(dataFileId+'_swiftness.tif') # swiftness
    aLIV = tifffile.imread(dataFileId+'_aliv.tif') # aLIV
    dbInt = tifffile.imread(dataFileId+'_dbOct.tif') # dB-scaled OCT intensity


rgbImage = icz.generate_RgbImage_twoContrasts(aLIV, Swiftness, dbInt, hueRange = swiftRange, satuRange = alivRange, octRange = octRange)

tifffile.imsave(dataFileId+'_fusedImage'+'_int'+str(octRange)+'_Swiftness'+str(swiftRange)+'_aLIV'+str(alivRange)+'.tiff', rgbImage.astype('uint8'), photometric='rgb',compress=6)
