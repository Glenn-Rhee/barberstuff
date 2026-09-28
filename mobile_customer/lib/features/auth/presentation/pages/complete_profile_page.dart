import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/image_upload_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/validators.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/complete_profile_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_dropdown_field.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_field_decoration.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_text_field.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/avatar_picker.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/avatar_source_sheet.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class CompleteProfileArgs {
  const CompleteProfileArgs({
    required this.name,
    required this.email,
    required this.tempToken,
    this.imageUrl,
  });

  final String name;
  final String email;
  final String tempToken;
  final String? imageUrl;
}

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key, required this.args});

  final CompleteProfileArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CompleteProfileProvider>(
      create: (BuildContext ctx) => CompleteProfileProvider(
        ctx.read<AuthRepository>(),
        ctx.read<AppSession>(),
        ctx.read<ImageUploadService>(),
        ctx.read<ProfileRepository>(),
        name: args.name,
        email: args.email,
        tempToken: args.tempToken,
        imageUrl: args.imageUrl,
      ),
      child: const _CompleteProfileView(),
    );
  }
}

class _CompleteProfileView extends StatelessWidget {
  const _CompleteProfileView();

  static const double _gapSection = 28;

  Future<void> _pickDate(
    BuildContext context,
    CompleteProfileProvider p,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: p.dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) p.setDateOfBirth(picked);
  }

  Future<void> _submit(BuildContext context, CompleteProfileProvider p) async {
    FocusScope.of(context).unfocus();
    final bool ok = await p.submit();
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    if (ok) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoute.home, (Route<dynamic> r) => false);
    } else if (p.error != null) {
      AppToast.show(context, message: p.error!.message(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Validators validators = Validators(l10n);
    final CompleteProfileProvider p = context.watch<CompleteProfileProvider>();

    return LoadingOverlay(
      isVisible: p.isLoading,
      child: Scaffold(
        backgroundColor: AppColor.surface,
        appBar: AppBar(
          backgroundColor: AppColor.surface,
          elevation: 0,
          titleSpacing: 0,
          leading: const BackButton(color: AppColor.ink),
          title: Text(
            l10n.completeProfileTitle,
            style: AppTextStyle.titleLarge,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Form(
              key: p.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: AvatarPicker(
                      imageUrl: p.imageUrl,
                      imageFile: p.imageFile,
                      onEdit: () => editAvatar(context, p),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.completeProfileSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColor.inkFaint,
                    ),
                  ),
                  const SizedBox(height: _gapSection),

                  AppTextField(
                    hint: l10n.registerNameLabel,
                    controller: p.nameController,
                    keyboardType: TextInputType.name,
                    validator: (String? v) =>
                        validators.required(v, label: l10n.registerNameLabel),
                  ),
                  const SizedBox(height: AppField.gap),

                  AppTextField(
                    hint: l10n.registerEmailLabel,
                    iconPath: AppAssets.mailIcon,
                    controller: p.emailController,
                    enabled: false,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: AppColor.inkFaint,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.completeProfileEmailLocked,
                          style: AppTextStyle.bodySmall.copyWith(
                            color: AppColor.inkFaint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppField.gap),

                  AppTextField(
                    hint: l10n.registerBirthDateLabel,
                    iconPath: AppAssets.birthDateIcon,
                    controller: p.birthDateController,
                    readOnly: true,
                    onTap: () => _pickDate(context, p),
                    validator: (String? v) => validators.required(
                      v,
                      label: l10n.registerBirthDateLabel,
                    ),
                  ),
                  const SizedBox(height: AppField.gap),

                  AppTextField(
                    hint: l10n.registerPhoneLabel,
                    iconPath: AppAssets.phoneIcon,
                    controller: p.phoneController,
                    keyboardType: TextInputType.phone,
                    validator: validators.phoneNumber,
                  ),
                  const SizedBox(height: AppField.gap),

                  AppDropdownField<String>(
                    hint: l10n.registerGenderLabel,
                    value: p.gender,
                    onChanged: p.setGender,
                    validator: (String? v) =>
                        validators.required(v, label: l10n.registerGenderLabel),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'male',
                        child: Text(l10n.genderMale),
                      ),
                      DropdownMenuItem<String>(
                        value: 'female',
                        child: Text(l10n.genderFemale),
                      ),
                    ],
                  ),
                  const SizedBox(height: _gapSection),

                  BoxButton(
                    label: l10n.completeProfileSubmit,
                    isLoading: p.isLoading,
                    onPressed: p.isLoading || !p.isComplete
                        ? null
                        : () => _submit(context, p),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
