import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/staff_account.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/local_list_controller.dart';
import 'package:tablet_dashboard/features/auth/domain/entities/staff_profile.dart';

enum AccountRoleFilter {
  all('Semua Role', null),
  cashier('Kasir', StaffRole.cashier),
  mitra('Mitra', StaffRole.mitra);

  const AccountRoleFilter(this.label, this.role);

  final String label;
  final StaffRole? role;
}

// Tab Role Akun, maks 2 akun per cabang: 1 kasir + 1 mitra
class AccountListController extends LocalListController<StaffAccount> {
  AccountListController(this._api, this.storeId) : super(pageSize: 5);

  static const maxAccounts = 2;

  // Role yang boleh dibuat admin untuk cabang
  static const roles = [StaffRole.cashier, StaffRole.mitra];

  final BranchApi _api;
  final String storeId;

  AccountRoleFilter filter = AccountRoleFilter.all;

  bool get full => all.length >= maxAccounts;

  bool taken(StaffRole role) => all.any((a) => a.role == role);

  @override
  Future<List<StaffAccount>> fetch() => _api.accounts(storeId);

  // Filter nama / email backend tidak jalan benar, jadi dicari di tablet
  @override
  bool accepts(StaffAccount account, String keyword) =>
      (filter.role == null || account.role == filter.role) &&
      (keyword.isEmpty ||
          account.name.toLowerCase().contains(keyword) ||
          account.email.toLowerCase().contains(keyword));

  @override
  int compare(StaffAccount a, StaffAccount b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  void setFilter(AccountRoleFilter value) => change(() => filter = value);

  Future<String?> create({
    required String name,
    required String email,
    required StaffRole role,
  }) => mutate(
    () => _api.createAccount(
      storeId: storeId,
      name: name,
      email: email,
      role: role,
    ),
  );

  Future<String?> update(
    StaffAccount account, {
    required String name,
    required String password,
  }) => mutate(
    () => _api.updateAccount(account.id, name: name, password: password),
  );

  Future<String?> delete(StaffAccount account) =>
      mutate(() => _api.deleteAccount(account.id));
}
