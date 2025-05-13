import math
import cv2 as cv 

WIDTH = 1920
HEIGHT = 1080
FRAME_CENTER_X = WIDTH/2 
FRAME_CENTER_Y = HEIGHT/2 

HFOV = math.radians(90)
VFOV = HFOV * (HEIGHT/WIDTH)

ANGLE_PER_PIXEL_X = math.degrees(HFOV) / WIDTH
ANGLE_PER_PIXEL_Y = math.degrees(VFOV) / HEIGHT

def CalculateAngle(image_directory, assets, image_number, flags, CAMS):
    print('FINDING ORIGINS OF THE OBJECT')
    origins = FindOrigins(image_directory, assets, image_number, flags)

    triangle_angles_xy = []
    triangle_angles_3d = []

    # triangle_angles_xy(1, 2, 3)
    # 1: angle of the corner that Object-CurrentCamera-NextCamera
    # 2: angle of the cornet that Object-NectCamera-CurrentCamera
    # 3: angle of the corner that CurentCamera-Object-NextCamera

    # triangle_angles_3d(1, 2)
    # 1: 90-Object-Camera corner 
    # 2: 90-Camera-Object corner

    triangle_angles_xy = CalculateAngleHorizontal(origins, FRAME_CENTER_X, ANGLE_PER_PIXEL_X, image_number, CAMS)
    triangle_angles_3d = CalculateAngleVertical(origins, FRAME_CENTER_Y, ANGLE_PER_PIXEL_Y, image_number)

    return triangle_angles_xy, triangle_angles_3d

def CalculateAngleHorizontal(origins,  FRAME_CENTER_X, ANGLE_PER_PIXEL_X, image_number, CAMS):
    frame_angles = []
    triangle = []
    for i in range(image_number):
        frame_angles.append((FRAME_CENTER_X - origins[i][0]) * (ANGLE_PER_PIXEL_X + 0.0131))

    print('ANGLE CALCULATION PROCESS IN XY IS STARTING\n')
    ang_oc0c1 = round(CAMS[0].angle.z + frame_angles[0], 4)
    ang_oc1c0 = round(180 - (CAMS[1].angle.z + frame_angles[1]),4)
    obj_ang = round(abs(180 - (ang_oc0c1 + ang_oc1c0)),4)
    triangle.append([ang_oc0c1, ang_oc1c0, obj_ang])
    print(f'ang_oc0c1: {triangle[0][0]}, '
            f'ang_oc1c0: {triangle[0][1]}, '
            f'obj_ang: {triangle[0][2]}')

    ang_oc1c2 = round(CAMS[1].angle.z + frame_angles[1],4)
    ang_oc2c1 = round(90 - (CAMS[2].angle.z + frame_angles[2]),4)
    obj_ang = round(abs(180 - (ang_oc1c2 + ang_oc2c1)),4)
    triangle.append([ang_oc1c2, ang_oc2c1, obj_ang])
    print(f'ang_oc1c2: {triangle[1][0]}, '
            f' ang_oc2c1: {triangle[1][1]}, '
            f'obj_ang: {triangle[1][2]}')

    ang_oc2c3 = round(CAMS[2].angle.z + frame_angles[2],4)
    ang_oc3c2 = round(180 - (CAMS[3].angle.z + frame_angles[3]),4)
    obj_ang = round(abs(180 - (ang_oc2c3 + ang_oc3c2)),4)
    triangle.append([ang_oc2c3, ang_oc3c2, obj_ang])
    print(f'ang_oc2c3: {triangle[2][0]}, '
            f'ang_oc3c2: {triangle[2][1]}, '
            f'obj_ang: {triangle[2][2]}')
    
    ang_oc3c4 = round((CAMS[3].angle.z + frame_angles[3]) - (math.degrees(math.atan(abs(CAMS[3].position.x - CAMS[4].position.x) / abs(CAMS[3].position.y - CAMS[4].position.y)))),4)
    ang_oc4c3 = round((CAMS[4].angle.z + frame_angles[4]) - (math.degrees(math.atan(abs(CAMS[3].position.y - CAMS[4].position.y) / abs(CAMS[3].position.x - CAMS[4].position.x)))),4)
    obj_ang = round(abs(180 - (ang_oc3c4 + ang_oc4c3)),4)
    triangle.append([ang_oc3c4, ang_oc4c3, obj_ang])
    print(f'ang_oc3c4: {triangle[3][0]}, '
            f'ang_oc4c3: {triangle[3][1]}, '
            f'obj_ang: {triangle[3][2]}')

    ang_oc4c5 = round((CAMS[4].angle.z + frame_angles[4]) - (math.degrees(math.atan(abs(CAMS[4].position.y - CAMS[5].position.y) / abs(CAMS[4].position.x - CAMS[5].position.x)))),4)
    ang_oc5c4 = round(180 - (CAMS[5].angle.z + frame_angles[5]) - (math.degrees(math.atan(abs(CAMS[4].position.x - CAMS[5].position.x) / abs(CAMS[4].position.y - CAMS[5].position.y)))),4)
    obj_ang = round(abs(180 - (ang_oc4c5 + ang_oc5c4)),4)
    triangle.append([ang_oc4c5, ang_oc5c4, obj_ang])
    print(f'ang_oc4c5: {triangle[4][0]}, '
            f'ang_oc5c4: {triangle[4][1]}, '
            f'obj_ang: {triangle[4][2]}')

    ang_oc5c0 = round(CAMS[5].angle.z + frame_angles[5],4)
    ang_oc0c5 = round(90 - (CAMS[0].angle.z + frame_angles[0]),4)
    obj_ang = round(abs(180 - (ang_oc5c0 + ang_oc0c5)),4)
    triangle.append([ang_oc5c0, ang_oc0c5, obj_ang])
    print(f'ang_oc5c0: {triangle[5][0]}, '
            f'ang_oc0c5: {triangle[5][1]}, '
            f'obj_ang: {triangle[5][2]}')



    return triangle

def CalculateAngleVertical(origins, FRAME_CENTER_Y, ANGLE_PER_PIXEL_Y, image_number):
    triangle_3d = []
    frame_angles = []

    for i in range(image_number):
        frame_angles.append((FRAME_CENTER_Y - origins[i][1]) * (ANGLE_PER_PIXEL_Y + 0.0131))

    for i in range(image_number):
        cam_ang = round(60 + frame_angles[i],4)
        obj_ang = round(90 - cam_ang,4) 
        triangle_3d.append([cam_ang, obj_ang])
        print(f'cam {i} angle: {cam_ang}, obj_angle: {obj_ang}')

    return triangle_3d

def FindOrigins(image_directory, assets, image_number, flags):
    origins = []
    for i in range(image_number):
        if flags[i] == 1:
            img = cv.imread(f'{assets}/{image_directory}/mask/cam{i}.png', cv.IMREAD_GRAYSCALE)
            contours, _ = cv.findContours(img, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
            largest_contour = max(contours, key=cv.contourArea)

            M = cv.moments(largest_contour)
            if M['m00'] != 0:
                cx = int(M['m10'] / M['m00'])
                cy = int(M['m01'] / M['m00'])
                origin = [cx, cy]
                origins.append(origin)
            else:
                origins.append([0,0])
                print(f'COULD NOT DETERMONE THE CENTER OF THE OBJECT {i}')
        else:
            print(f'IAMGE {i} HAS NO ORANGE COLOR')
    return origins 
