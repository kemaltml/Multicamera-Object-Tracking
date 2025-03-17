import numpy as np
import matplotlib.pyplot as plt

def find_intersection():
    # Given points and distances
    x1, y1 = 0, 0  # Point1
    x2, y2 = 12, 0  # Point2
    r1 = 12  # Distance from Point1 to Point3
    r2 = 8   # Distance from Point2 to Point3
    
    # Solve for intersection of circles
    d = np.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
    
    if d > r1 + r2 or d < abs(r1 - r2):
        print("No intersection")
        return None
    
    # Midpoint between intersections
    a = (r1**2 - r2**2 + d**2) / (2 * d)
    h = np.sqrt(r1**2 - a**2)
    
    # Base point on the line between centers
    x0 = x1 + a * (x2 - x1) / d
    y0 = y1 + a * (y2 - y1) / d
    
    # Two intersection points
    x3a = x0 + h * (y2 - y1) / d
    y3a = y0 - h * (x2 - x1) / d
    
    x3b = x0 - h * (y2 - y1) / d
    y3b = y0 + h * (x2 - x1) / d
    
    return (x3a, y3a), (x3b, y3b)

def plot_circles_and_points():
    (x3a, y3a), (x3b, y3b) = find_intersection()
    
    fig, ax = plt.subplots()
    ax.set_aspect('equal')
    
    # Draw circles
    circle1 = plt.Circle((0, 0), 12, color='b', fill=False, linestyle='dashed')
    circle2 = plt.Circle((12, 0), 8, color='r', fill=False, linestyle='dashed')
    ax.add_patch(circle1)
    ax.add_patch(circle2)
    
    # Plot points
    plt.scatter([0, 12], [0, 0], color='black', label='Known Points')
    plt.scatter([x3a, x3b], [y3a, y3b], color='green', label='Point3 (Two Possible)')
    
    # Labels
    plt.text(0, 0, " P1(0,0) ", fontsize=12, verticalalignment='bottom', horizontalalignment='right')
    plt.text(12, 0, " P2(12,0) ", fontsize=12, verticalalignment='bottom', horizontalalignment='left')
    plt.text(x3a, y3a, f" P3a({x3a:.2f},{y3a:.2f})", fontsize=12, verticalalignment='bottom')
    plt.text(x3b, y3b, f" P3b({x3b:.2f},{y3b:.2f})", fontsize=12, verticalalignment='top')
    
    plt.xlim(-15, 20)
    plt.ylim(-15, 15)
    plt.axhline(0, color='gray', linewidth=0.5)
    plt.axvline(0, color='gray', linewidth=0.5)
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.legend()
    plt.title("Circle Intersection for Finding Point3")
    plt.show()

# Run the function
plot_circles_and_points()

