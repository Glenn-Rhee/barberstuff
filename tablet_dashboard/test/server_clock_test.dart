import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tablet_dashboard/core/network/server_clock.dart';
import 'package:tablet_dashboard/features/home/shell/presentation/widgets/clock_drift_banner.dart';

void main() {
  // Header Date server yang selisih [offset] dari jam tablet
  String headerAt(Duration offset) =>
      HttpDate.format(DateTime.now().add(offset));

  test('tanpa respons server pakai jam tablet', () {
    final clock = ServerClock();
    expect(clock.offset, Duration.zero);
    expect(clock.drifted, isFalse);
    expect(clock.now().difference(DateTime.now()).inSeconds.abs(), lessThan(1));
  });

  test('jam tablet ketinggalan: now() ikut jam server', () {
    final clock = ServerClock();
    var notified = 0;
    clock.addListener(() => notified++);

    clock.sync(headerAt(const Duration(minutes: 90)));

    expect(clock.drifted, isTrue);
    expect(notified, 1);
    final ahead = clock.now().difference(DateTime.now());
    expect(ahead.inSeconds, inInclusiveRange(89 * 60, 90 * 60));
  });

  test('selisih detik karena jaringan diabaikan', () {
    final clock = ServerClock();
    var notified = 0;
    clock.addListener(() => notified++);

    clock.sync(headerAt(Duration.zero));
    clock.sync(headerAt(const Duration(seconds: 1)));

    expect(clock.offset, Duration.zero);
    expect(notified, 0);
  });

  test('header kosong / rusak diabaikan', () {
    final clock = ServerClock()
      ..sync(null)
      ..sync('bukan tanggal');
    expect(clock.offset, Duration.zero);
  });

  test('lama selisih di banner', () {
    expect(ClockDriftBanner.lengthOf(const Duration(minutes: 3)), '3 menit');
    expect(
      ClockDriftBanner.lengthOf(const Duration(hours: -1, minutes: -5)),
      '1 jam 5 menit',
    );
    expect(ClockDriftBanner.lengthOf(const Duration(hours: 22)), '22 jam');
    expect(
      ClockDriftBanner.lengthOf(const Duration(minutes: 59, seconds: 59)),
      '1 jam',
    );
  });
}
