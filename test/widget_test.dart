import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthcare_admin/main.dart';

void main() {
  testWidgets('Healthcare admin dashboard starts successfully',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HealthcareAdminApp());

    expect(find.text('MediCare'), findsOneWidget);
    expect(find.text('Total Bookings'), findsOneWidget);
  });
}
