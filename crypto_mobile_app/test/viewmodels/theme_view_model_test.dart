import 'package:crypto_mobile_app/core/app_constants.dart';
import 'package:crypto_mobile_app/viewmodels/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggles the global palette immediately', () {
    final viewModel = ThemeViewModel();
    addTearDown(() {
      viewModel.setLightMode(false);
      viewModel.dispose();
    });

    expect(viewModel.isLightMode, isFalse);
    expect(AppColors.canvas, const Color(0xFF0B1020));

    viewModel.toggleTheme();

    expect(viewModel.isLightMode, isTrue);
    expect(AppColors.canvas, const Color(0xFFF4F6FC));
    expect(AppColors.primaryText, const Color(0xFF171D2D));

    viewModel.toggleTheme();

    expect(viewModel.isLightMode, isFalse);
    expect(AppColors.canvas, const Color(0xFF0B1020));
  });
}
