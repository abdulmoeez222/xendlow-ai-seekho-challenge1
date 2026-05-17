import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Scenario JSON Parsing Tests', () {
    test('scenario_1.json loads and has all required fields', () async {
      final jsonString = await rootBundle.loadString('assets/scenarios/scenario_1.json');
      final data = json.decode(jsonString);
      
      expect(data['id'], 1);
      expect(data['name'], isNotEmpty);
      expect(data['description'], isNotEmpty);
      expect(data['input_signals'], isA<List>());
      expect((data['input_signals'] as List), isNotEmpty);
    });

    test('scenario_2.json loads and has all required fields', () async {
      final jsonString = await rootBundle.loadString('assets/scenarios/scenario_2.json');
      final data = json.decode(jsonString);
      
      expect(data['id'], 2);
      expect(data['name'], isNotEmpty);
      expect(data['description'], isNotEmpty);
      expect(data['input_signals'], isA<List>());
      expect((data['input_signals'] as List), isNotEmpty);
    });

    test('scenario_3.json loads and has all required fields', () async {
      final jsonString = await rootBundle.loadString('assets/scenarios/scenario_3.json');
      final data = json.decode(jsonString);
      
      expect(data['id'], 3);
      expect(data['name'], isNotEmpty);
      expect(data['description'], isNotEmpty);
      expect(data['input_signals'], isA<List>());
      expect((data['input_signals'] as List), isNotEmpty);
    });
  });
}
