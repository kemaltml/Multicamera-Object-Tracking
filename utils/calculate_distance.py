import math
import numpy as np 
WIDTH = 1920
HEIGHT = 1080
FRAME_CENTER_X = WIDTH/2
FRAME_CENTER_Y = HEIGHT/2

HFOV = math.radians(90)
VFOV = HFOV * (HEIGHT/WIDTH)

ANGLE_PER_PIXEL_X = math.degrees(HFOV) / WIDTH
ANGLE_PER_PIXEL_Y = math.degrees(VFOV) / HEIGHT

real_vectors_xy = [8.5, 4.0, 8.5, 7.5, 4.0, 8.077]
real_vectors_3d = [8.9185, 4.826, 8.9185, 7.9712, 4.826, 8.517]

def CalculateDistance(triangle_angles_xy, triangle_angles_3d, flags, CAMS):
    print('DISTANCE CALCULATION IS STARTING')
    vectors_xy = [0,0,0,0,0,0]
    heights = []
    vectors_3d = []
    cams_distance = CamDistance(CAMS)

    for i in range(len(CAMS)):
        if i == 5:
            n=0 
        else:
            n = i+1 

        if i == 0:
            distance = math.sin(math.radians(triangle_angles_xy[i][0])) / math.sin(math.radians(triangle_angles_xy[i][2])) * cams_distance[i]
        else:
            distance = math.sin(math.radians(triangle_angles_xy[i][0])) / math.sin(math.radians(triangle_angles_xy[i][1])) * vectors_xy[i]
        

        vectors_xy[n] = round(distance, 2)
        print(f'3d triangle cam angle[{i}][0]: {triangle_angles_xy[i][0]}d {math.radians(triangle_angles_xy[i][0])}r')
        print(f'object angle: {triangle_angles_xy[i][2]}d {triangle_angles_xy[i][2]}')
        print(f'{n}. cam distance in xy: {round(distance, 2)}\n')
    for i in range(len(CAMS)):
        height = math.sin(math.radians(triangle_angles_3d[i][1])) / math.sin(math.radians(triangle_angles_3d[i][0])) * vectors_xy[i]
        heights.append(height)
        vector = math.sqrt((height**2) + vectors_xy[i]**2)
        vectors_3d.append(round(vector, 2))
    print('DISTANCE CALCULATION IS DONE')
    print(f'heights: {heights}')
    print(f'vectors_xy: {vectors_xy}')
    print(f'vectors_3d: {vectors_3d}')
    return vectors_xy, vectors_3d, heights

def CamDistance(CAMS):
    cam_distance = []
    for i in range(len(CAMS)):
        if i == 5:
            n = 0 
        else:
            n = i+1 
        distance = math.sqrt((CAMS[i].position.x - CAMS[n].position.x)**2 + (CAMS[i].position.y - CAMS[n].position.y)**2)
        cam_distance.append(round(distance, 2))
    return cam_distance
