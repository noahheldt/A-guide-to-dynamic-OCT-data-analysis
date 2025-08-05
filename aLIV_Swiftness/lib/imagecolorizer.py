import numpy as np

def hsv_to_rgb(H, S, V):
        """
        Converts HSL color array to RGB array
    
        H = [0..360]
        S = [0..1]
        V = [0..1]
    
        http://en.wikipedia.org/wiki/HSL_and_HSV#From_HSL
        
        Arguments:
            H: Hue
            S: Saturation
            V: Value (brightness)
    
        Returns:
            R, G, B in [0..255]
        """
        # chroma
        C = V * S
        
        # H' and X (intermediate value for the second largest component)
        Hp = H / 60.0
        X = C * (1 - np.absolute(np.mod(Hp, 2) - 1))
    
        # initilize with zero
        R = np.zeros(H.shape, float)
        G = np.zeros(H.shape, float)
        B = np.zeros(H.shape, float)
    
        # handle each case:
        mask = (Hp >= 0) == ( Hp < 1)
        R[mask] = C[mask]
        G[mask] = X[mask]
    
        mask = (Hp >= 1) == ( Hp < 2)
        R[mask] = X[mask]
        G[mask] = C[mask]
    
        mask = (Hp >= 2) == ( Hp < 3)
        G[mask] = C[mask]
        B[mask] = X[mask]
    
        mask = (Hp >= 3) == ( Hp < 4)
        G[mask] = X[mask]
        B[mask] = C[mask]
    
        mask = (Hp >= 4) == ( Hp < 5)
        R[mask] = X[mask]
        B[mask] = C[mask]
    
        mask = (Hp >= 5) == ( Hp < 6)
        R[mask] = C[mask]
        B[mask] = X[mask]
        
        # adding the same amount to each component, to match value
        m = V - C
        R += m
        G += m
        B += m
        
        # [0..1] to [0..255]
        R *= 255.0
        G *= 255.0
        B *= 255.0
    
        return R.astype(int), G.astype(int), B.astype(int)

def valueRerange(img, inRange, outRange):
    inMin = inRange[0]
    inMax = inRange[1]
    outMin = outRange[0] 
    outMax = outRange[1]

    outImg = np.clip(img, inMin, inMax)
    outImg = ((outImg - inMin) / (inMax - inMin) * (outMax-outMin)) + outMin
    return (outImg)

def hsvToRgbImage(H, S, V):
    R, G, B = hsv_to_rgb(H, S, V)
    temp = np.concatenate([[R], [G], [B]], axis = 0)
    rgbImage = np.rollaxis(temp, 0, len(np.shape(R))+1).astype('uint8')
    return(rgbImage)

def generate_RgbImage_twoContrasts(aLIV, Swiftness, dbInt, hueRange, satuRange, octRange):
    """
    

    Parameters
    ----------
    aLIV : 3D array
       aLIV image, which is used as saturation of pseudo-color image
    Swiftness : 3D array
       Swiftness image, which is used as hue of pseudo-color image
    dbInt : 3D array
        dB-scale OCT intensity image
    hueRange : 1D tuple (min, max)
        dynamic range of Swiftness, which is used as hue of pseudo-color image
    satuRange : 1D tuple (min, max)
        dynamic range of aLIV, which is used as saturation of pseudo-color image
    octRange : 1D tuple (min, max)
        dynamic range of dB-scaled OCT intensity, which is used as brightness of pseudo-color image

    Returns
    -------
    rgbImage : RGB array of pseudo-color image
        pseudo-color image

    """
    # Input and output image ranges as [INT, Hue(Swiftness), Saturation(aLIV)]
    inRanges = [octRange, hueRange, satuRange]
    outRanges = [(0., 1.), (240., 0.), (0., 1.)] # if the hue angle is (240,0), the blue-green-red color order is assigned.
    
    
    rgbImage = np.zeros((Swiftness.shape[0], Swiftness.shape[1], Swiftness.shape[2],3))
    
    for bscanId in range(0, Swiftness.shape[0]):
        
        print(bscanId)
        imgIndex = 0
        V = valueRerange(dbInt[bscanId,:,:], inRanges[imgIndex], outRanges[imgIndex])
        imgIndex = 1
        H = valueRerange(Swiftness[bscanId,:,:], inRanges[imgIndex], outRanges[imgIndex])
        imgIndex = 2
        S = valueRerange(aLIV[bscanId,:,:], inRanges[imgIndex], outRanges[imgIndex])
    
        rgbImage[bscanId,:,:] = hsvToRgbImage(H,S,V)
    
    return rgbImage
