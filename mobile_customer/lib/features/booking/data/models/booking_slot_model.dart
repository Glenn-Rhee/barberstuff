import 'package:mobile_barberstuff/core/utils/json_value.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';

class SlotCapsterModel extends SlotCapster {
  const SlotCapsterModel({
    required super.id,
    required super.name,
    required super.avgRating,
    required super.imageUrl,
    required super.available,
  });

  factory SlotCapsterModel.fromEntity(SlotCapster capster) {
    return SlotCapsterModel(
      id: capster.id,
      name: capster.name,
      avgRating: capster.avgRating,
      imageUrl: capster.imageUrl,
      available: capster.available,
    );
  }

  factory SlotCapsterModel.fromJson(Map<String, dynamic> json) {
    return SlotCapsterModel(
      id: jsonText(json['id']),
      name: jsonText(json['name']),
      avgRating: jsonDouble(json['avg_rating']),
      imageUrl: jsonText(json['image_url']),
      available: json['available'] == true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'avg_rating': avgRating,
    'image_url': imageUrl,
    'available': available,
  };
}

class BookingSlotModel extends BookingSlot {
  const BookingSlotModel({
    required super.time,
    required super.available,
    required super.capsters,
  });

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      time: jsonText(json['time']),
      available: json['available'] == true,
      capsters: jsonList(json['capsters'], SlotCapsterModel.fromJson),
    );
  }
}

class StoreSlotsModel extends StoreSlots {
  const StoreSlotsModel({
    required super.idStore,
    required super.date,
    required super.slots,
  });

  factory StoreSlotsModel.fromJson(Map<String, dynamic> json) {
    return StoreSlotsModel(
      idStore: jsonText(json['id_store']),
      date:
          DateTime.tryParse(jsonText(json['date']))?.toLocal() ??
          DateTime.now(),
      slots: jsonList(json['slots'], BookingSlotModel.fromJson),
    );
  }
}
