# fake_gps_generator.py
# "Öylesine" sahte GPS üretir, ekrana JSON satırları yazar ve opsiyonel CSV kaydeder.
# python fake_gps_generator.py           # sadece ekrana yaz
# python fake_gps_generator.py out.csv   # ekrana + CSV'ye yaz

import sys, math, time, json, csv
from datetime import datetime

outfile = sys.argv[1] if len(sys.argv) > 1 else None
writer = None
if outfile:
    f = open(outfile, "w", newline="", encoding="utf-8")
    writer = csv.writer(f)
    writer.writerow(["time", "lat", "lon", "alt", "speed_kmh"])

lat0, lon0 = 38.4237, 27.1428   # İzmir başlangıç
theta = 0.0
r = 0.003                       # ~300 m yarıçap

print("Generating fake GPS... (Ctrl+C to stop)")
try:
    while True:
        lat = lat0 + r*math.sin(theta)
        lon = lon0 + r*math.cos(theta)
        alt = 80 + 10*math.sin(theta)      # m
        spd = 18 + 5*math.cos(theta)       # km/h
        now = datetime.now().strftime("%H:%M:%S")

        obj = {"time": now, "lati": round(lat, 6), "long": round(lon, 6),
               "alt": round(alt, 1), "speed": round(spd, 1)}
        print(json.dumps(obj), flush=True)

        if writer:
            writer.writerow([now, obj["lati"], obj["long"], obj["alt"], obj["speed"]])

        theta += 0.12
        time.sleep(0.6)
except KeyboardInterrupt:
    pass
finally:
    if writer:
        f.close()
