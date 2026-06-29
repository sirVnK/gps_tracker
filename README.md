# gps_tracker — Flutter GPS Tracking UI Demo

A minimal Flutter app that generates fake GPS data locally and renders a moving marker on OpenStreetMap. It's a UI demo — useful for prototyping map/telemetry interfaces without hardware or a backend.

## Overview

gps_tracker simulates GPS movement locally and draws a moving marker on an OpenStreetMap view. Because the data is generated on-device, you can develop and demo location/telemetry UI without a real GPS source or server.

## Motivation

When building telemetry-style interfaces (like the map views in my SkyVision case study), it helps to iterate on the UI without depending on live hardware. This small app provides exactly that: a self-contained, hardware-free way to test map and marker behavior.

## Features

- Locally generated (simulated) GPS data
- Moving marker on OpenStreetMap
- No backend or hardware required
- Clean base for telemetry/map UI prototyping

## Tech Stack

- **Framework:** Flutter (Dart)
- **Maps:** OpenStreetMap
- **Category:** UI demo / telemetry prototyping

## Installation

```bash
git clone https://github.com/Logshi/gps_tracker.git
cd gps_tracker
flutter pub get
```

## Usage

```bash
flutter run
```

The app starts generating simulated GPS points and animates the marker on the map.

## Demo

> Placeholders — replace with real captures.

- `docs/demo.gif`

## What I Learned

- Rendering OpenStreetMap and markers in Flutter
- Simulating data sources for hardware-free UI development
- Building reusable telemetry/map UI components

## Security & Privacy

All GPS data is synthetic and generated locally. No real location data is collected or transmitted.

## License

MIT — see [LICENSE](LICENSE).
