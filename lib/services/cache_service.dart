import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Servicio muy simple de cache local usando SharedPreferences.
/// Usado para mantener datos offline mínimos (últimas citas, usuario reciente).
class CacheService {
  static const _kLastFetchedAppointments = 'cache:last_fetched_appointments';

  static Future<void> saveLastFetchedAppointments(
    List<Map<String, dynamic>> rows,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(rows);
    await prefs.setString(_kLastFetchedAppointments, json);
  }

  static Future<List<Map<String, dynamic>>>
  readLastFetchedAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kLastFetchedAppointments);
    if (s == null || s.isEmpty) return [];
    try {
      final parsed = jsonDecode(s) as List;
      return parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
