import 'dart:convert';
import 'package:http/http.dart' as http;

class RoutePoint {
  final double latitude;
  final double longitude;
  const RoutePoint(this.latitude, this.longitude);
}

class RouteResult {
  final List<RoutePoint> points;
  final int durationSeconds;
  final int distanceMeters;
  const RouteResult({
    required this.points,
    required this.durationSeconds,
    required this.distanceMeters,
  });
}

class MapsRouteService {
  // Backend proxy recommended for production. Do not ship unrestricted
  // server API keys inside the mobile application.
  Future<RouteResult?> getRoute({
    required RoutePoint origin,
    required RoutePoint destination,
    String? serverEndpoint,
  }) async {
    if (serverEndpoint == null || serverEndpoint.isEmpty) return null;

    final uri = Uri.parse(serverEndpoint).replace(queryParameters: {
      'originLat': origin.latitude.toString(),
      'originLng': origin.longitude.toString(),
      'destinationLat': destination.latitude.toString(),
      'destinationLng': destination.longitude.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rawPoints = (json['points'] as List? ?? const []);
    return RouteResult(
      points: rawPoints.map((p) => RoutePoint(
        (p['lat'] as num).toDouble(),
        (p['lng'] as num).toDouble(),
      )).toList(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
    );
  }
}
