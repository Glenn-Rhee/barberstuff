// Nominal dari API bisa "120000" atau 120000, selain itu dianggap 0
int parseAmount(Object? value) => switch (value) {
  num() => value.round(),
  String() => (num.tryParse(value) ?? 0).round(),
  _ => 0,
};
