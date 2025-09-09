// main.dart — GPS Tracker (No Backend) — Local Fake Generator
// ---------------------------------------------------------------------------
// No Firebase, no server. This app generates fake GPS data locally and
// renders it on OpenStreetMap. Useful for quick UI tests.
//
// Controls (FAB stack at bottom-right):
// - Play/Pause: start/stop fake motion
// - Trail ON/OFF: record or pause the route polyline
// - Clear: clear trail
// - Recenter: move camera to latest point
//
// Pubspec dependencies:
//   flutter: { sdk: flutter }
//   flutter_map: ^6.1.0
//   latlong2: ^0.9.1
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GpsTrackerFakeOnly(),
  ));
}

class GpsTrackerFakeOnly extends StatefulWidget {
  const GpsTrackerFakeOnly({super.key});
  @override
  State<GpsTrackerFakeOnly> createState() => _GpsTrackerFakeOnlyState();
}

class _GpsTrackerFakeOnlyState extends State<GpsTrackerFakeOnly> {
  final MapController _map = MapController();

  // Simulation params
  LatLng _center = const LatLng(38.4237, 27.1428); // İzmir
  double _theta = 0.0;   // angle
  double _radius = 0.003; // ~300 m
  double _omega = 0.12;  // step per tick
  Duration _tick = const Duration(milliseconds: 600);

  Timer? _timer;
  bool _running = true;
  bool _recordTrail = true;
  bool _follow = true;

  LatLng? _last;
  double? _alt;
  double? _speed;
  String? _timeStr;
  final List<LatLng> _trail = [];
  int _rxCount = 0; // number of fake points produced

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _step());
    setState(() => _running = true);
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _step() {
    _theta += _omega;
    final dLat = _radius * math.sin(_theta);
    final dLon = _radius * math.cos(_theta);
    final lat = _center.latitude + dLat;
    final lon = _center.longitude + dLon;

    // simple synthetic telem
    final alt = 80 + 10 * math.sin(_theta);      // m
    final spd = 18 + 5 * math.cos(_theta);       // km/h
    final now = DateTime.now();
    final timeStr = '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';

    final pt = LatLng(lat, lon);
    setState(() {
      _rxCount++;
      _last = pt;
      _alt = alt;
      _speed = spd;
      _timeStr = timeStr;
      if (_recordTrail) _trail.add(pt);
    });

    if (_follow) {
      _map.move(pt, 15);
    }
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _recenter() { if (_last != null) _map.move(_last!, 15); }
  void _clearTrail() => setState(() => _trail.clear());

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle();
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracker — Fake (No Backend)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(children: [
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 2),
              Text('FAKE points: $_rxCount', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
        ),
        actions: [
          IconButton(
            tooltip: _follow ? 'Follow: ON' : 'Follow: OFF',
            icon: Icon(_follow ? Icons.center_focus_strong : Icons.center_focus_weak),
            onPressed: () => setState(() => _follow = !_follow),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(
            right: 12,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _RoundBtn(
                  icon: _running ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  onTap: () => _running ? _pause() : _start(),
                  tooltip: _running ? 'Pause' : 'Play',
                ),
                const SizedBox(height: 12),
                _RoundBtn(
                  icon: _recordTrail ? Icons.route : Icons.route_outlined,
                  onTap: () => setState(() => _recordTrail = !_recordTrail),
                  tooltip: _recordTrail ? 'Trail recording: ON' : 'Trail recording: OFF',
                ),
                const SizedBox(height: 12),
                _RoundBtn(icon: Icons.clear, onTap: _clearTrail, tooltip: 'Clear trail'),
                const SizedBox(height: 12),
                _RoundBtn(icon: Icons.my_location, onTap: _recenter, tooltip: 'Recenter'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final alt = _alt != null ? '${_alt!.toStringAsFixed(1)} m' : '—';
    final spd = _speed != null ? '${_speed!.toStringAsFixed(1)} km/h' : '—';
    final t = _timeStr ?? '—';
    return 'Alt: $alt   |   Hız: $spd   |   Zaman: $t';
  }

  Widget _buildMap() {
    final center = _last ?? _center; // İzmir fallback
    final markers = <Marker>[];
    if (_last != null) {
      markers.add(Marker(
        width: 36,
        height: 36,
        point: _last!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 6)],
          ),
        ),
      ));
    }

    return FlutterMap(
      mapController: _map,
      options: MapOptions(initialCenter: center, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.gps_tracker_fake',
        ),
        if (_trail.length >= 2)
          PolylineLayer(polylines: [Polyline(points: _trail, strokeWidth: 4)]),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const _RoundBtn({required this.icon, required this.onTap, this.tooltip, super.key});

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
