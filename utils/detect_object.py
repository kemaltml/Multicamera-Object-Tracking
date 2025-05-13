import numpy as np 
import cv2 as cv 

def DetectObject(image, mask_path, flag, i):
    img = cv.imread(image)
    if img is None:
        print('ERROR: IMAGE CONT LOAD')
        return

    hsv = cv.cvtColor(img, cv.COLOR_BGR2HSV)
    lower_orange = np.array([3, 117, 160])
    upper_orange = np.array([7, 255, 255])
    mask = cv.inRange(hsv, lower_orange, upper_orange)

    cv.imwrite(mask_path, mask)
    print(f'Mask saved as {mask_path}')

    if cv.countNonZero(mask) > 0:
        flag[i] = 1 
    else:
        print('THERE IS NO ORANGE OBJECT IN IMAGE')
        flag[i] = 0

    return flag
