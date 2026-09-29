import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/features/home/presentation/pages/home_page.dart';

void main() {
  bool next(bool wasCollapsed, double offset) =>
      HomePage.headerCollapsed(wasCollapsed: wasCollapsed, offset: offset);

  test('header ciut setelah digulir melewati ambang', () {
    expect(next(false, 0), isFalse);
    expect(next(false, HomePage.collapseThreshold), isFalse);
    expect(next(false, HomePage.collapseThreshold + 1), isTrue);
  });

  test('gulir balik ke atas di tengah halaman tidak memunculkan header', () {
    // Posisi yang sama, apa pun arah gulirnya atau saat jari berhenti.
    expect(next(true, 800), isTrue);
    expect(next(true, 40), isTrue);
    expect(next(true, 1), isTrue);
  });

  test('header terbuka lagi hanya saat sampai di puncak', () {
    expect(next(true, 0), isFalse);
    // Pantulan iOS di atas puncak.
    expect(next(true, -20), isFalse);
  });
}
