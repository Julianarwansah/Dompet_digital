import 'package:flutter_test/flutter_test.dart';

import 'package:dompet_kampus_global/core/constants/app_constants.dart';

void main() {
  test('app constants are configured', () {
    expect(AppConstants.appName, 'Dompet Kampus Global');
    expect(AppConstants.apiVersion, '/v1');
  });
}
