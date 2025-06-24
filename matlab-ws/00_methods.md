# Giriş
- Blender 
- Matlab 
- Rotasyon, transformasyon, projeksiyon (prejection) matrisleri 
- Kamera kalibrasyonu 
- Stereo kamera kalibrasyonu 
- Maskeleme 
- triangulation (üçgenleme)
- zaman serisi veri düzeltme/filtreleme
- polyfit (polinom düzeltme)

# Methods
## Hazırlık
1. **Blender üzerinden 6 kameralı bir oda kuruldu**
    - blender fotoğrafı
2. **Kalibrasyon için satranç tahtası oluşturuldu** 
    - Damalı fotoğraf
3. **Her kamera ikilileri için satranç tahtası çeşitli koordinatlarda ve açılarda olacak şekilde 20'şer fotoğraf render alındı**
4. **Önceki işlem sonucu her kamera için de ayrıca elimizde 40 kalibrasyon fotoğrafı oluşmuş oldu**
5. **Her kamera tekil olarak kalibre edilip verileri kaydedildi**
6. ~~Kalibre edilen kamera verileri kullanılarak stereo kamera kalibrasyon işlemi yapılıp verileri kaydedildi~~
6. **Stereo kalibrasyon yapılmadı. Projection matrisi manuel hesaplandı.**
7. blender ortamından 0.1m yarıçaplı turuncu topun her 3 eksende de hareket ettiği bir animasyon hazırlanıp her kamera için render alındı. İşlem sonucu 6 video dosyası elde edildi.
8. **Elde edilen görüntülerden matlab uygulamasında color treshold kullnılarak turuncu topu maskelemek için hsv değerleri elde edildi.**
9. **Oluşturulan kameraların yapılacak işlemlerin doğruluğu için koordinatları ve açıları kullanılarak dünya merkezine göre rotasyon, transformasyon ve projeksiyon matrisleri hesaplandı**
    - matlab kameraları resmini koy
10. Bu işlemlerin ardından takip işlemi yapıldı

## Takip
1. **Oluşturulan videolardan 6 kamera için kareler okundu**
2. **Okunan karelerin kalibre edilen kamera verileriyle yatay ve dikey bozulmaları giderildi**
3. **Düzeltilen kareler elde edilen HSV değerleriyle topu beyaz geri kalan renkler siyah olacak şekilde binary maskelendi**
4. **Maskeleme sonrası oluşan veriden görüntüde nesne olup olmadığı kontrol edildi.**
5. **Görüntüde nesne olması durumunda orijininin video karesindeki koordinatı bulundu.**
6. **Bulunan koordinat topun hareketini görselleştirmek için bir dizide kaydedildi.**
7. **Elde edilen kare koordinatları ve projeksiyon matrisleriyle her kamera ikilisi için üçgenleme yöntemiyle 6 adet 3B koordinat hesaplandı.**
    - nasıl hesaplandı? mantığı anlat.
8. **Hesaplanan 6 koordinatın ortalaması alınarak bir diziye kaydedildi.**
9. ~~Elde edilen 3B koordinat ile topun dünya merkezine olan uzaklığı hesaplandı~~
10. **Hesaplanan koordinatlar ve uzaklıklar çıktı olarak bir dosyaya kaydedildi**
11. **Okunan her kareye daha önce kaydedilen karedeki nesne koordinatları kullanılarak izlemiş olduğu yok çizdirildi**
12. **Bahsedilen işlemler her kamera ve her video karesi için tekrar edildi.**
13. **İşlemler bittikten sonra kaydedilen çıktı dosyası okunup zaman serisi verisindeki gürültüyü azaltmak, hareket doğruluğunu artırmak ve eğilimleri yakalamak için polinom düzeltme algoritması kullanıldı.**
