from utils import CalculateCoordinate, CalculateDistance, CalculateAngle, DetectObject, CreateCamera

import os 
from termcolor import colored

# Defining Cameras and constant values
BALL_RADIUS = 0.1 # meter

# CreateCamera(x, y, z, roll, pitch, yaw)
CAM0 = CreateCamera(0, 0, 3, 60, 0, 45)
CAM1 = CreateCamera(7.5, 0, 3, 60, 0, 90)
CAM2 = CreateCamera(15, 0, 3, 60, 0, 45)
CAM3 = CreateCamera(15, 4, 3, 60, 0, 90)
CAM4 = CreateCamera(7.5, 8, 3, 60, 0, 90)
CAM5 = CreateCamera(0, 7, 3, 60, 0, 60)
CAMS = [CAM0, CAM1, CAM2, CAM3, CAM4, CAM5]

whites_x = []
whites_y = []

# Counting the number of pictures. It will change to frames of video
def count_files(directory):
    files = os.listdir(directory)
    file_count = sum(1 for f in files if os.path.isfile(os.path.join(directory, f)))
    return file_count

def main(args=None):
    # controlling if there are any orange colors or not. Affects the next processes
    flags = [0, 0, 0, 0, 0, 0] 
    
    assets = 'assets'
    image_directory = '7-5_4'
    image_number = count_files(os.path.join(assets, image_directory))

    # checks if there is a path or not for save the masked B&W image
    if not os.path.exists(f"{assets}/{image_directory}/mask"):
            os.makedirs(f"{assets}/{image_directory}/mask")

    print('-------------------------\n', colored('OBJECT DETECTION PROCESS STARTED', 'red'))
    # Detecting the object and finds origins of the object
    for i in range(image_number):
        if not os.path.exists(f"{assets}/{image_directory}/mask/cam{i}.png"):
            
            print(f'{i}. Image sent')
            image_path = os.path.join(assets, image_directory, f'cam{i}.png')
            mask_path = os.path.join(assets, image_directory, f'mask/cam{i}.png')
            flags = DetectObject(image_path, mask_path, flags, i)
        else:
            print(f'{i}. <<IMAGE ALREADY PROCESSED>>')
            flags = [1, 1, 1, 1, 1, 1]
    print(print('-------------------------\n', colored('OBJECT DETECTION PROCESS DONE', 'red'), f'\t<<FLAGS: {flags}>>\n'))
    

    print(colored('ANGLE CALCULATION PROCESS STARTING', 'red'))
    triangle_angles_xy, triangle_angles_3d = CalculateAngle(image_directory, assets, image_number, flags, CAMS)
    print(colored('ANGLE CALCULATION PROCESS DONE', 'red'))
    
    print(colored('DISTANCE CALCULATION PROCESS STARTING', 'red'))
    vectors_xy, vectors_3d, heights = CalculateDistance(triangle_angles_xy, triangle_angles_3d, flags, CAMS)
    print(colored('DISTANCE CALCULATION PROCESS DONE', 'red'))
    
    print(colored('COORDINATE CALCULATION PROCESS STARTING', 'red'))
    coordinates = CalculateCoordinate(vectors_xy, vectors_3d, CAMS)
    print(colored('COORDINATE CALCULATION PROCESS DONE', 'red'))
    print(f'x: {coordinates[0]:.4f}, y: {coordinates[1]:.4f}, z: {coordinates[2]:.4f}')
if __name__ == '__main__':
    main()