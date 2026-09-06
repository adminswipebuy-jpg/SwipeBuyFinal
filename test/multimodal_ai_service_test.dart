import 'package:flutter_test/flutter_test.dart';
import '../lib/services/multimodal_ai_service.dart';

void main() {
  test('service type can be instantiated', () {
    expect(MultimodalAiService(), isA<MultimodalAiService>());
  });
}
