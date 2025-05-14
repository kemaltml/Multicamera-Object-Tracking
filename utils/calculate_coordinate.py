import numpy as np 
from scipy.optimize import least_squares
def CalculateCoordinate(vectors_xy, vectors_3d, CAMS):
    print('CALCULATE COORDINATE PROCESS STARTING')
    print('Finding X and Y Point')
    lower_bounds = [0, 0]
    upper_bounds = [15, 8]
    initial_guess = [6, 3]
    height = []
    
    # Pass vectors_xy and CAMS as additional arguments
    result_xy = least_squares(equations_xy, initial_guess, args=(vectors_xy, CAMS), bounds=(lower_bounds, upper_bounds))
    #print(f'result_xy: {result_xy}')
    x, y = round(result_xy.x[0], 3), round(result_xy.x[1], 3)
    print(f'x: {x:.4f}, y: {y:.4f}')

    initial_guess = 2.5

    for i in range(len(CAMS)):
        result = least_squares(equations_3d, initial_guess, args=(vectors_3d[i], x, y), bounds=(0, 3))
        #print(f'result_z: {result.x}')
        if result.x > 2:
            height.append(result.x) 
    
    z = 3 - round(np.mean(height),4)
    print(f'z: {z:.4f}')
    print('CALCULATE COORDINATE PROCESS DONE')
    return [x, y, z]

def equations_xy(vars, vectors_xy, CAMS):
    x, y = vars
    eq1 = np.sqrt((x - CAMS[0].position.x)**2 + (y - CAMS[0].position.y)**2) - vectors_xy[0]
    eq2 = np.sqrt((x - CAMS[1].position.x)**2 + (y - CAMS[1].position.y)**2) - vectors_xy[1]
    eq3 = np.sqrt((x - CAMS[2].position.x)**2 + (y - CAMS[2].position.y)**2) - vectors_xy[2]
    eq4 = np.sqrt((x - CAMS[3].position.x)**2 + (y - CAMS[3].position.y)**2) - vectors_xy[3]
    eq5 = np.sqrt((x - CAMS[4].position.x)**2 + (y - CAMS[4].position.y)**2) - vectors_xy[4]
    eq6 = np.sqrt((x - CAMS[5].position.x)**2 + (y - CAMS[5].position.y)**2) - vectors_xy[5]
    return [eq1, eq2, eq3, eq4, eq5, eq6]

def equations_3d(vars, distance, x, y):
    z = vars 
    eq = np.sqrt(x**2 + y**2 + z**2) - distance
    return eq
