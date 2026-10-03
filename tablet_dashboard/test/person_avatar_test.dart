import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';

void main() {
  Future<void> pumpAvatar(WidgetTester tester, String? photo) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PersonAvatar(name: 'Budi Doremi', photo: photo, size: 64),
          ),
        ),
      ),
    );
  }

  testWidgets('tanpa foto tampil inisial', (tester) async {
    await pumpAvatar(tester, null);
    expect(find.text('BD'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('foto dari API dipakai, inisial selama dimuat / gagal', (
    tester,
  ) async {
    // Di tes semua request HTTP dibalas 400, jadi foto pasti gagal dimuat
    await pumpAvatar(tester, 'https://cdn.example.com/uploads/budi.jpg');
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as NetworkImage).url,
      'https://cdn.example.com/uploads/budi.jpg',
    );
    expect(find.text('BD'), findsOneWidget); // masih dimuat

    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.text('BD'), findsOneWidget); // gagal, balik ke inisial
  });
}
