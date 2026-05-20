import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  static final _base = Config.apiBase;
  static http.Client client = http.Client();

  static Future<Map<String, dynamic>> runScenario(int id) async {
    final res = await client.post(Uri.parse('$_base/run-scenario/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to run scenario: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>> getLogs(String planId) async {
    final res = await client.get(Uri.parse('$_base/logs/$planId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get logs');
  }

  static Future<Map<String, dynamic>> getStateBefore() async {
    final res = await client.get(Uri.parse('$_base/state/before'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get state before');
  }

  static Future<Map<String, dynamic>> getStateAfter(String planId) async {
    final res = await client.get(Uri.parse('$_base/state/after/$planId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get state after');
  }

  static Future<Map<String, dynamic>> approvePlan(String planId) async {
    final res = await client.post(
      Uri.parse('$_base/approve-plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'plan_id': planId}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to approve plan');
  }

  static Future<Map<String, dynamic>> rejectPlan(String planId) async {
    final res = await client.post(
      Uri.parse('$_base/reject-plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'plan_id': planId}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to reject plan');
  }
}
