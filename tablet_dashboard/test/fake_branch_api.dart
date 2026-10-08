import 'dart:typed_data';

import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch_draft.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/staff_account.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';

// Pengganti endpoint admin Mengelola Cabang di tes, sekaligus mencatat
// apa yang dikirim aplikasi
class FakeBranchApi implements BranchApi {
  final calls = <String>[];

  List<Branch> branchList = const [
    Branch(
      id: 'STORE-1',
      name: 'Barberstuff Cikutra',
      phone: '081234567890',
      address: 'Jl. Cikutra No. 123, Bandung',
      description: 'Barbershop modern untuk pelanggan premium',
      openHour: '09:00',
      closeHour: '21:00',
      latitude: -6.9,
      longitude: 107.63,
      type: BranchType.premium,
      totalService: 2,
      totalPackage: 1,
      totalCapster: 2,
      rating: 4.9,
      reviewCount: 12,
    ),
    Branch(
      id: 'STORE-2',
      name: 'Barberstuff Depok',
      address: 'Jl. Margonda Raya No. 1, Depok',
      openHour: '10:00',
      closeHour: '22:00',
      open: false,
    ),
  ];

  final capsterMap = <String, List<Capster>>{
    'STORE-1': const [
      Capster(id: 'CAP-1', name: 'Wahyu', rating: 4.9),
      Capster(id: 'CAP-2', name: 'Rizal', rating: 4.5, active: false),
    ],
  };

  final serviceMap = <String, List<ServiceItem>>{
    'STORE-1:service': const [
      ServiceItem(
        id: 'SVC-1',
        name: 'Cukur Rambut',
        price: 50000,
        description: 'Potong rambut sesuai gaya',
      ),
      ServiceItem(id: 'SVC-2', name: 'Keramas', price: 25000),
    ],
    'STORE-1:package': const [
      ServiceItem(
        id: 'PKG-1',
        name: 'Paket Fresh',
        price: 85000,
        description: 'Cukur Rambut + Keramas',
        type: ServiceType.package,
      ),
    ],
  };

  final accountMap = <String, List<StaffAccount>>{
    'STORE-1': const [
      StaffAccount(
        id: 'STF-9',
        name: 'Siti Aulia',
        email: 'siti@barberstuff.id',
        role: StaffRole.cashier,
      ),
    ],
  };

  // Isi untuk tiru backend yang menolak perubahan
  String? rejectWith;

  BranchDraft? createdDraft;
  Map<String, Object?>? lastBranchUpdate;

  void _check() {
    if (rejectWith != null) throw ApiException(rejectWith!, statusCode: 400);
  }

  @override
  Future<List<Branch>> branches() async {
    calls.add('branches');
    return branchList;
  }

  @override
  Future<Branch> branch(String id) async {
    calls.add('branch:$id');
    return branchList.firstWhere((b) => b.id == id);
  }

  @override
  Future<void> createBranch(
    BranchDraft draft, {
    required String bannerKey,
  }) async {
    calls.add('createBranch:$bannerKey');
    _check();
    createdDraft = draft;
    branchList = [
      ...branchList,
      Branch(
        id: 'STORE-${branchList.length + 1}',
        name: draft.name,
        address: draft.address,
        openHour: draft.openHour,
        closeHour: draft.closeHour,
      ),
    ];
  }

  @override
  Future<void> updateBranch(
    String id, {
    String? name,
    String? phone,
    String? description,
    String? address,
    String? bannerKey,
    String? openHour,
    String? closeHour,
    double? latitude,
    double? longitude,
    BranchType? type,
    bool? open,
  }) async {
    calls.add('updateBranch:$id');
    _check();
    lastBranchUpdate = {
      'name': ?name,
      'phone': ?phone,
      'description': ?description,
      'address': ?address,
      'openHour': ?openHour,
      'closeHour': ?closeHour,
      'type': ?type,
      'open': ?open,
    };
    branchList = [
      for (final b in branchList)
        if (b.id != id)
          b
        else
          Branch(
            id: b.id,
            name: name ?? b.name,
            phone: phone ?? b.phone,
            description: description ?? b.description,
            address: address ?? b.address,
            openHour: openHour ?? b.openHour,
            closeHour: closeHour ?? b.closeHour,
            latitude: latitude ?? b.latitude,
            longitude: longitude ?? b.longitude,
            type: type ?? b.type,
            open: open ?? b.open,
          ),
    ];
  }

  @override
  Future<void> deleteBranch(String id) async {
    calls.add('deleteBranch:$id');
    _check();
    branchList = [
      for (final b in branchList)
        if (b.id != id) b,
    ];
  }

  @override
  Future<List<Capster>> capsters(String storeId) async {
    calls.add('capsters:$storeId');
    return capsterMap[storeId] ?? const [];
  }

  @override
  Future<void> createCapster({
    required String storeId,
    required String name,
    String? imageKey,
  }) async {
    calls.add('createCapster:$name');
    _check();
    capsterMap[storeId] = [
      ...?capsterMap[storeId],
      Capster(id: 'CAP-NEW', name: name, rating: 5),
    ];
  }

  @override
  Future<void> updateCapster(
    String id, {
    String? name,
    bool? active,
    String? imageKey,
    String? storeId,
  }) async {
    calls.add('updateCapster:$id:${name ?? ''}:${active ?? ''}');
    _check();
    if (storeId != null) {
      calls.add('moveCapster:$id:$storeId');
      final moved = capsterMap.values
          .expand((l) => l)
          .firstWhere((c) => c.id == id);
      capsterMap.updateAll((_, list) => [...list.where((c) => c.id != id)]);
      capsterMap[storeId] = [...?capsterMap[storeId], moved];
      return;
    }
    capsterMap.updateAll(
      (_, list) => [
        for (final c in list)
          c.id == id
              ? Capster(
                  id: c.id,
                  name: name ?? c.name,
                  rating: c.rating,
                  active: active ?? c.active,
                )
              : c,
      ],
    );
  }

  @override
  Future<void> deleteCapster(String id) async {
    calls.add('deleteCapster:$id');
    _check();
    capsterMap.updateAll(
      (_, list) => [
        for (final c in list)
          if (c.id != id) c,
      ],
    );
  }

  @override
  Future<List<ServiceItem>> services(String storeId, ServiceType type) async {
    calls.add('services:$storeId:${type.api}');
    return serviceMap['$storeId:${type.api}'] ?? const [];
  }

  @override
  Future<void> createService({
    required String storeId,
    required ServiceType type,
    required String name,
    required int price,
    String? description,
  }) async {
    calls.add('createService:${type.api}:$name:$price:${description ?? ''}');
    _check();
    final key = '$storeId:${type.api}';
    serviceMap[key] = [
      ...?serviceMap[key],
      ServiceItem(
        id: 'NEW-${type.api}',
        name: name,
        price: price,
        description: description,
        type: type,
      ),
    ];
  }

  @override
  Future<void> updateService(
    String id, {
    String? name,
    int? price,
    String? description,
    bool? active,
  }) async {
    calls.add('updateService:$id:${price ?? ''}:${active ?? ''}');
    _check();
    serviceMap.updateAll(
      (_, list) => [
        for (final s in list)
          s.id == id
              ? ServiceItem(
                  id: s.id,
                  name: name ?? s.name,
                  price: price ?? s.price,
                  description: description ?? s.description,
                  type: s.type,
                  active: active ?? s.active,
                )
              : s,
      ],
    );
  }

  @override
  Future<void> deleteService(String id) async {
    calls.add('deleteService:$id');
    _check();
    serviceMap.updateAll(
      (_, list) => [
        for (final s in list)
          if (s.id != id) s,
      ],
    );
  }

  @override
  Future<List<StaffAccount>> accounts(String storeId) async {
    calls.add('accounts:$storeId');
    return accountMap[storeId] ?? const [];
  }

  @override
  Future<void> createAccount({
    required String storeId,
    required String name,
    required String email,
    required StaffRole role,
  }) async {
    calls.add('createAccount:${role.name}:$email');
    _check();
    accountMap[storeId] = [
      ...?accountMap[storeId],
      StaffAccount(id: 'STF-NEW', name: name, email: email, role: role),
    ];
  }

  @override
  Future<void> updateAccount(
    String id, {
    required String name,
    required String password,
  }) async {
    calls.add('updateAccount:$id:$name:$password');
    _check();
  }

  @override
  Future<void> deleteAccount(String id) async {
    calls.add('deleteAccount:$id');
    _check();
    accountMap.updateAll(
      (_, list) => [
        for (final a in list)
          if (a.id != id) a,
      ],
    );
  }

  @override
  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    calls.add('uploadImage:$fileName');
    return 'temp/2026/10/photo.jpg';
  }
}
