import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';

extension ReviewDraftModel on ReviewDraft {
  /// Body `POST /rating/`. Pesan hanya diterima backend di rating toko.
  Map<String, dynamic> toRatingBody({
    required String bookingId,
    required String capsterId,
    required String staffId,
    required String storeId,
  }) {
    final String note = message.trim();

    return <String, dynamic>{
      'id_booking': bookingId,
      'rating': <String, dynamic>{
        if (capsterId.isNotEmpty)
          'capster': <String, dynamic>{'id': capsterId, 'score': capster},
        if (staffId.isNotEmpty)
          'staff': <String, dynamic>{'id': staffId, 'score': cashier},
        if (storeId.isNotEmpty)
          'store': <String, dynamic>{
            'id': storeId,
            'score': store,
            if (note.isNotEmpty) 'message': note,
          },
      },
    };
  }
}
