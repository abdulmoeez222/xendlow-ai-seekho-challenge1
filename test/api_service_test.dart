import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:insight_engine/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    test('runScenario returns data on 200', () async {
      ApiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'plan_id': '123'}), 200);
      });

      final res = await ApiService.runScenario(1);
      expect(res['plan_id'], '123');
    });

    test('runScenario throws on non-200', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Error', 500);
      });

      expect(() => ApiService.runScenario(1), throwsException);
    });

    test('getLogs returns data on 200', () async {
      ApiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'status': 'running'}), 200);
      });

      final res = await ApiService.getLogs('123');
      expect(res['status'], 'running');
    });

    test('getStateBefore returns data on 200', () async {
      ApiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'margin': 15}), 200);
      });

      final res = await ApiService.getStateBefore();
      expect(res['margin'], 15);
    });

    test('getStateAfter returns data on 200', () async {
      ApiService.client = MockClient((request) async {
        return http.Response(jsonEncode({'margin': 18}), 200);
      });

      final res = await ApiService.getStateAfter('123');
      expect(res['margin'], 18);
    });
  });
}
