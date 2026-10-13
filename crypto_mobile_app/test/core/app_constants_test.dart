import 'package:crypto_mobile_app/core/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android uses the configured loopback API host', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(AppConstants.apiBaseUrl, 'http://127.0.0.1:3000/api');
  });
}
