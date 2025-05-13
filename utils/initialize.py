"""
This library used for generating cameras with xyz coordinates and xyz angles.
"""

# A class representing a camera with posistion and angle atributes.
class Camera:
    #Initializes the Camera object with default position and angle values.
    def __init__(self):
        self.position = type('Position', (), {'x': 0, 'y': 0, 'z': 0})
        self.angle = type('Angle', (), {'x': 0, 'y': 0, 'z': 0})
        

#Create and initialize a Camera object with specified position and angle values.
def CreateCamera(pos_x, pos_y, pos_z, ang_x, ang_y, ang_z):
    camera = Camera()
    camera.position.x = pos_x
    camera.position.y = pos_y
    camera.position.z = pos_z
    camera.angle.x = ang_x
    camera.angle.y = ang_y
    camera.angle.z = ang_z
    return camera