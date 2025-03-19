from utils import CalculateCoordinate, CalculateDistance, CalculateAngle, DetectObject
import numpy as np
import cv2 as cv
from matplotlib import pyplot as plt
import os 

def count_files(directory):
    files = os.listdir(directory)
    file_count = sum(1 for f in files if os.path.isfile(os.path.join(directory, f)))
    return file_count

def main():
    flags = [0, 0, 0, 0, 0, 0]
    
    assets = 'assets'
    image_directory = '7-5_4'
    image_number = count_files(os.path.join(assets, image_directory))

    if not os.path.exists(f"{assets}/{image_directory}/mask"):
            os.makedirs(f"{assets}/{image_directory}/mask")


    for i in range(image_number):
        print(f'{i}. Image sent')
        image_path = os.path.join(assets, image_directory, f'cam{i}.png')
        mask_path = os.path.join(assets, image_directory, f'mask/mask_cam{i}.png')
        DetectObject(image_path, mask_path, flags, i)

    print(f"process has done and the flag is: {flags}")
    

if __name__ == '__main__':
    main()