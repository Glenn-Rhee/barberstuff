import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/validators.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/avatar_picker.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/avatar_source_sheet.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/provider/personal_info_provider.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/labeled_field.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:provider/provider.dart';

class PersonalInfoArgs {
  const PersonalInfoArgs({required this.profile});

  final CustomerProfile profile;
}

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key, required this.args});

  final PersonalInfoArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PersonalInfoProvider>(
      create: (_) => PersonalInfoProvider(args.profile),
      child: const _PersonalInfoView(),
    );
  }
}

class _PersonalInfoView extends StatelessWidget {
  const _PersonalInfoView();

  static const double _gap = 18;

  void _save(BuildContext context, PersonalInfoProvider p) {
    FocusScope.of(context).unfocus();
    if (!p.validate()) return;
    showComingSoonDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Validators validators = Validators(l10n);
    final PersonalInfoProvider p = context.watch<PersonalInfoProvider>();

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: AppColor.ink),
        title: Text(
          l10n.personalInfoTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: p.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: <Widget>[
              _PhotoRow(provider: p),
              const SizedBox(height: 24),

              LabeledField(
                label: l10n.registerNameLabel,
                iconPath: AppAssets.userProfile,
                controller: p.nameController,
                keyboardType: TextInputType.name,
                validator: (String? v) =>
                    validators.required(v, label: l10n.registerNameLabel),
              ),
              const SizedBox(height: _gap),

              LabeledField(
                label: l10n.registerEmailLabel,
                iconPath: AppAssets.mailIcon,
                controller: p.emailController,
                enabled: false,
                helper: l10n.personalInfoEmailLocked,
              ),
              const SizedBox(height: _gap),

              LabeledField(
                label: l10n.registerBirthDateLabel,
                iconPath: AppAssets.birthDateIcon,
                controller: p.birthDateController,
                enabled: false,
                helper: l10n.personalInfoBirthDateLocked,
              ),
              const SizedBox(height: _gap),

              LabeledField(
                label: l10n.registerPhoneLabel,
                iconPath: AppAssets.phoneIcon,
                controller: p.phoneController,
                keyboardType: TextInputType.phone,
                validator: validators.phoneNumber,
              ),
              const SizedBox(height: 24),

              _PasswordCard(email: p.profile.email),
              const SizedBox(height: 32),

              BoxButton(
                label: l10n.personalInfoSave,
                onPressed: p.isDirty ? () => _save(context, p) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.provider});

  final PersonalInfoProvider provider;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AvatarPicker(
          imageUrl: provider.imageUrl,
          imageFile: provider.imageFile,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Material(
                color: AppColor.orangeDashboard,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => editAvatar(context, provider),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          AppAssets.uploadIcon,
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                          color: AppColor.orangeDark,
                          filterQuality: FilterQuality.medium,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.personalInfoChangePhoto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.titleSmall.copyWith(
                              color: AppColor.orangeDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.personalInfoPhotoFormat,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.inkFaint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.customKeyProfileInfo.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.keyIcon,
                    width: 25,
                    height: 25,
                    fit: BoxFit.contain,
                    color: AppColor.customKeyProfileInfo2,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.personalInfoPasswordTitle,
                      style: AppTextStyle.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.personalInfoPasswordSubtitle,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColor.orangeDashboard.withValues(alpha: 0.45),
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoute.forgotPassword, arguments: email),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    l10n.personalInfoPasswordAction,
                    style: AppTextStyle.titleSmall.copyWith(
                      color: AppColor.orangeDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
