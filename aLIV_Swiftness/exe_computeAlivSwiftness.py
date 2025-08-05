"""
This code example is for processing aLIV and Swiftness images.
The codes and files in this folder are the partial copy of an open-source COG dynamic-OCT contrast library (release: COG-DOCT_v1.0.1).
The full and latest version of the library is available at the following GitHub repository.
https://github.com/ComputationalOpticsGroup/COG-dynamic-OCT-contrast-generation-library/blob/main/Program/main.py
"""

import numpy as np
import time
from lib.postprocess_vliv import *


## Input file path of linear OCT intensity
path_OCT = [
    r"C:\Users\rionm\Dropbox\programs\COG-DOCT\Test\data_forTest\MCF7_Spheroid_20210707_025_OCTIntensityPDavg.tiff"
            ]
volumeDataType =  "Ibrahim2021BOE"


## Input parameters of the scanning protocols
frameRepeat = 1 # Number of frames in a single burst
bscanLocationPerBlock = 16 # Number of Bscan locations per Block
blockRepeat =  32 # Number of block repeats
blockPerVolume = 8 # Number of blocks in a volume
frameSeparationTime = 12.8e-3 # Successive frame measurement time [s]: 12.8e-3 (TransToad), 12.66e-3 (Hyracotherium)

def main():
    for id in range(len(path_OCT)):
        tStart = time.time()
            
        vliv_postprocessing (path_OCT[id], volumeDataType, frameSeparationTime,
                            frameRepeat, bscanLocationPerBlock, blockRepeat, blockPerVolume, fitting_method = "GPU",
                             motionCorrection = False, octRange = (10,40), alivRange =(0,10), swiftRange =(0, 3))
        
    tEnd = time.time()
    print(f'Computation time:{(tEnd-tStart)/60: .2f} min')
    
    
if __name__ == "__main__":
    main()