import 'package:tablet_dashboard/core/services/media/photo_picker.dart';
import 'package:tablet_dashboard/features/admin/branch_account/domain/entities/staff_account.dart';
import 'package:tablet_dashboard/features/admin/branch_list/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch_list/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/employee_list/domain/entities/employee.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/capster.dart';
import 'package:tablet_dashboard/shared/provider/local_list_controller.dart';

enum EmployeeStatusFilter {
  all('Semua Status', null),
  active('Aktif', true),
  inactive('Tidak Aktif', false);

  const EmployeeStatusFilter(this.label, this.value);

  final String label;

  // Status aktif yang dicari, null = semua
  final bool? value;
}

enum EmployeeRoleFilter {
  all('Semua Jabatan', null),
  capster('Capster', EmployeeRole.capster),
  cashier('Kasir', EmployeeRole.cashier),
  mitra('Mitra', EmployeeRole.mitra);

  const EmployeeRoleFilter(this.label, this.role);

  final String label;
  final EmployeeRole? role;
}

// Semua karyawan dari semua cabang. Backend wajib id_store untuk
// /capster dan /staff, jadi dimuat per cabang
class EmployeeListController extends LocalListController<Employee> {
  EmployeeListController(this._api) : super(pageSize: 5);

  final BranchApi _api;

  List<Branch> branches = const [];

  // null = semua cabang
  String? branchId;
  EmployeeRoleFilter roleFilter = EmployeeRoleFilter.all;
  EmployeeStatusFilter status = EmployeeStatusFilter.all;

  int get activeCount => all.where((e) => e.active).length;
  int get inactiveCount => all.length - activeCount;

  // Kasir / mitra maks. 1 per cabang
  bool taken(String branchId, EmployeeRole role) =>
      role != EmployeeRole.capster &&
      all.any((e) => e.branch.id == branchId && e.role == role);

  @override
  Future<List<Employee>> fetch() async {
    final branches = await _api.branches();
    final perBranch = await Future.wait([
      for (final branch in branches) _employeesOf(branch),
    ]);
    this.branches = branches;
    return [for (final list in perBranch) ...list];
  }

  Future<List<Employee>> _employeesOf(Branch branch) async {
    final results = await Future.wait<List<Object>>([
      _api.capsters(branch.id),
      _api.accounts(branch.id),
    ]);
    return [
      for (final capster in results[0].cast<Capster>())
        Employee.fromCapster(capster, branch),
      for (final account in results[1].cast<StaffAccount>())
        if (account.role != null) Employee.fromAccount(account, branch),
    ];
  }

  @override
  bool accepts(Employee employee, String keyword) =>
      (keyword.isEmpty ||
          employee.name.toLowerCase().contains(keyword) ||
          (employee.email?.toLowerCase().contains(keyword) ?? false)) &&
      (branchId == null || employee.branch.id == branchId) &&
      (roleFilter.role == null || employee.role == roleFilter.role) &&
      (status.value == null || employee.active == status.value);

  @override
  int compare(Employee a, Employee b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  void setBranch(String? value) => change(() => branchId = value);
  void setRole(EmployeeRoleFilter value) => change(() => roleFilter = value);
  void setStatus(EmployeeStatusFilter value) => change(() => status = value);

  // Capster baru selalu aktif (aturan backend)
  Future<String?> createCapster({
    required String branchId,
    required String name,
    PickedPhoto? photo,
  }) => mutate(() async {
    await _api.createCapster(
      storeId: branchId,
      name: name,
      imageKey: photo == null
          ? null
          : await _api.uploadImage(photo.bytes, photo.fileName),
    );
  });

  // Password awal = password default staff dari server
  Future<String?> createAccount({
    required String branchId,
    required String name,
    required String email,
    required EmployeeRole role,
  }) => mutate(
    () => _api.createAccount(
      storeId: branchId,
      name: name,
      email: email,
      role: role.staffRole!,
    ),
  );

  // Field null = tidak diubah, [branchId] diisi = pindah cabang
  Future<String?> updateCapster(
    Employee employee, {
    String? name,
    bool? active,
    String? branchId,
  }) => mutate(
    () => _api.updateCapster(
      employee.id,
      name: name,
      active: active,
      storeId: branchId,
    ),
  );

  // Backend selalu minta password baru saat akun diubah
  Future<String?> updateAccount(
    Employee employee, {
    required String name,
    required String password,
  }) => mutate(
    () => _api.updateAccount(employee.id, name: name, password: password),
  );

  Future<String?> delete(Employee employee) => mutate(
    () => employee.isCapster
        ? _api.deleteCapster(employee.id)
        : _api.deleteAccount(employee.id),
  );
}
