/// Satu aksi bisnis. Provider memanggil use case, bukan repository, supaya
/// aturan bisnis punya satu tempat dan layar tidak tahu asal datanya.
abstract interface class UseCase<T, P> {
  Future<T> call(P params);
}

/// Use case untuk data lokal yang harus sudah ada sebelum frame pertama,
/// misalnya pilihan yang tersimpan di perangkat.
abstract interface class SyncUseCase<T, P> {
  T call(P params);
}

/// Parameter untuk use case yang tidak butuh input.
class NoParams {
  const NoParams();
}
