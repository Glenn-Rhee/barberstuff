import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail_model.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';

StoreDetail _detail(String open, String close) {
  return StoreDetailModel.fromJson(<String, dynamic>{
    'id': 'store-1',
    'name': 'Kemang Raya',
    'open_hour': open,
    'close_hour': close,
  });
}

void main() {
  test('penanda UTC diabaikan, bukan digeser ke zona perangkat', () {
    final StoreDetail detail = _detail(
      '2026-09-09T10:00:00Z',
      '2026-09-09T21:00:00Z',
    );

    expect(detail.openHour!.hour, 10);
    expect(detail.openHour!.minute, 0);
    expect(detail.closeHour!.hour, 21);
  });

  test('offset zona waktu juga dibaca sebagai jam dinding', () {
    final StoreDetail detail = _detail(
      '2026-09-09T09:00:00+07:00',
      '2026-09-09T22:00:00+07:00',
    );

    expect(detail.openHour!.hour, 9);
    expect(detail.closeHour!.hour, 22);
  });

  test('format postgres tanpa penanda zona tetap terbaca', () {
    final StoreDetail detail = _detail(
      '2026-09-09 10:00:00',
      '2026-09-09 21:00:00',
    );

    expect(detail.openHour!.hour, 10);
    expect(detail.closeHour!.hour, 21);
  });

  test('jam kosong atau bukan string menghasilkan null, bukan lempar', () {
    expect(_detail('', '').openHour, isNull);

    final StoreDetail missing = StoreDetailModel.fromJson(<String, dynamic>{
      'id': 'store-1',
      'name': 'Kemang Raya',
      'open_hour': null,
      'close_hour': null,
    });
    expect(missing.openHour, isNull);
    expect(missing.closeHour, isNull);
  });
}
