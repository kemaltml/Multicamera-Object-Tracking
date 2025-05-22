import bpy
import csv
import math
from mathutils import Vector
from bpy_extras.object_utils import world_to_camera_view

# Ayarlar
start_frame = 1
end_frame = 30 * 30  # 30 saniye * 30 fps
fps = 30
bpy.context.scene.frame_start = start_frame
bpy.context.scene.frame_end = end_frame

# Top objesini al
sphere = bpy.data.objects.get("Sphere")
if sphere is None:
    raise Exception("'Sphere' adında bir obje bulunamadı!")

# Kamera sec (0 tabanlı index)
camera_index = 0
cameras = [obj for obj in bpy.data.objects if obj.type == 'CAMERA']
if camera_index >= len(cameras):
    raise Exception(f"{camera_index} numaralı kamera bulunamadı.")
camera = cameras[camera_index]

# Render boyutları
scene = bpy.context.scene
width = scene.render.resolution_x
height = scene.render.resolution_y

# Başlangıç ve bitçe konumları
start_pos = Vector((3, 6.5, 1.0))
end_pos = Vector((10, 2, 0.15))

# CSV dosyası aç
with open("ball_trajectory.csv", "w", newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["frame", "x", "y", "z", "pixel_x", "pixel_y"])

    for frame in range(start_frame, end_frame + 1):
        t = (frame - start_frame) / (end_frame - start_frame)  # normalize zaman [0,1]

        # İnterpolasyon (parabolik zıplama)
        x = (1 - t) * start_pos.x + t * end_pos.x
        y = (1 - t) * start_pos.y + t * end_pos.y
        # z için parabolik kavis
        z = (1 - t) * start_pos.z + t * end_pos.z + math.sin(math.pi * t) * 1.0

        sphere.location = (x, y, z)
        sphere.keyframe_insert(data_path="location", frame=frame)

        # Kamera koordinatlarına dönüştür
        co_2d = world_to_camera_view(scene, camera, sphere.location)
        pixel_x = int(co_2d.x * width)
        pixel_y = int((1 - co_2d.y) * height)

        writer.writerow([frame, round(x, 4), round(y, 4), round(z, 4), pixel_x, pixel_y])

        # İlerleme bilgisi
        if frame % 30 == 0:
            print(f"Frame {frame}/{end_frame} işlendi ({(frame/end_frame)*100:.1f}%)")

print("Animasyon ve CSV kaydı tamamlandı!")

