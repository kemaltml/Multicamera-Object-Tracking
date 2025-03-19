import numpy as np
import cv2 as cv
from matplotlib import pyplot as plt
import os



def DetectObject(image, mask_path, flag, i):
    img = cv.imread(image)
    if img is None:
        print("Error: Image cant load")
        return 
    
    hsv = cv.cvtColor(img, cv.COLOR_BGR2HSV)

    lower_orange = np.array([4,129,146])
    upper_orange = np.array([6,255,226])

    mask = cv.inRange(hsv, lower_orange, upper_orange)

    cv.imwrite(mask_path, mask)
    print(f'Mask saved as {mask_path}')

    if cv.countNonZero(mask) > 0:
        flag[i] = 1
    else:
        print('There is no orange object in image')
        flag[i] = 0

    res = cv.bitwise_and(img, img, mask=mask)

    width = 800
    height = int(img.shape[0] * (width / img.shape[1]))
    flag[i] = 1
    img_resized = cv.resize(img, (width, height))
    mask_resized = cv.resize(mask, (width, height))
    res_resized = cv.resize(res, (width, height))

    
    # cv.imshow('Original Image', img_resized)
    # cv.imshow('Mask', mask_resized)
    # cv.imshow('Result', res_resized)

    # k = cv.waitKey(0)
    # if k == 27:
    #     cv.destroyAllWindows()