import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'support/booking_test_providers.dart';
import 'support/fake_booking_repository.dart';
import 'support/fake_store_repository.dart';

void main() {
  test('booking dari detail cabang melewati langkah pilih cabang', () async {
    final AppCache cache = await FakeBookingRepository.emptyCache();
    final BookingFlowProvider p = fakeBookingFlow(
      cache,
      store: FakeStoreRepository.sampleStore,
    );
    addTearDown(p.dispose);

    expect(p.store?.id, FakeStoreRepository.sampleStore.id);
    expect(p.stepCount, 4);

    p.setAgreed(true);
    await p.next();

    expect(p.step, BookingStep.schedule);
    expect(p.stepNumber, 1);
    expect(p.slots, isNotEmpty);

    expect(p.back(), isTrue);
    expect(p.step, BookingStep.terms);
  });

  test('tanpa cabang bawaan, alur tetap lewat pilih cabang', () async {
    final AppCache cache = await FakeBookingRepository.emptyCache();
    final BookingFlowProvider p = fakeBookingFlow(cache);
    addTearDown(p.dispose);

    expect(p.stepCount, 5);

    p.setAgreed(true);
    await p.next();

    expect(p.step, BookingStep.branch);
    expect(p.stepNumber, 1);
  });
}
