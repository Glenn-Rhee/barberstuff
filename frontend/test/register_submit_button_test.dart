import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/register_provider.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';

Color? _buttonColor(WidgetTester tester) {
  final AnimatedContainer container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(BoxButton),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return (container.decoration as BoxDecoration?)?.color;
}

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  late RegisterProvider provider;

  setUp(() {
    provider = RegisterProvider(AuthRepository(AuthRemoteDataSource(Dio())));
  });

  tearDown(() => provider.dispose());

  test('isComplete hanya true setelah semua field terisi', () {
    expect(provider.isComplete, isFalse);

    provider.nameController.text = 'Danar Mas';
    provider.phoneController.text = '081297447680';
    provider.emailController.text = 'danarmas@gmail.com';
    provider.passwordController.text = 'danarmas12345';
    expect(provider.isComplete, isFalse);

    provider.setDateOfBirth(DateTime(2008, 1, 1));
    expect(provider.isComplete, isFalse);

    provider.setGender('male');
    expect(provider.isComplete, isTrue);

    provider.emailController.text = '   ';
    expect(provider.isComplete, isFalse);
  });

  testWidgets('tombol abu-abu saat nonaktif, oranye saat aktif', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const BoxButton(label: 'Daftar', onPressed: null)),
    );
    expect(_buttonColor(tester), AppColor.disabled);

    await tester.pumpWidget(
      _host(BoxButton(label: 'Daftar', onPressed: () {})),
    );
    await tester.pumpAndSettle();
    expect(_buttonColor(tester), AppColor.orangeLight);
  });

  testWidgets('saat loading tombol nonaktif, label tetap, tanpa spinner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(BoxButton(label: 'Daftar', onPressed: () {}, isLoading: true)),
    );

    expect(_buttonColor(tester), AppColor.disabled);
    expect(find.text('Daftar'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
