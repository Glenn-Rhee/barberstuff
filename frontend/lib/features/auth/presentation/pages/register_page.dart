import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/validators.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/register_provider.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_dropdown_field.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_field_decoration.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/app_text_field.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/avatar_picker.dart';
import 'package:mobile_barberstuff/features/auth/presentation/widgets/password_toggle.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';
import 'package:mobile_barberstuff/shared/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterProvider>(
      create: (BuildContext ctx) =>
          RegisterProvider(ctx.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  static const double _gapSection = 28;

  Future<void> _pickDate(BuildContext context, RegisterProvider p) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: p.dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) p.setDateOfBirth(picked);
  }

  Future<void> _submit(BuildContext context, RegisterProvider p) async {
    FocusScope.of(context).unfocus();
    final bool ok = await p.submit();
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    if (ok && p.result != null && p.lastRequest != null) {
      AppToast.show(
        context,
        message: l10n.registerOtpSentMessage,
        type: AppToastType.success,
      );
      Navigator.of(context).pushNamed(
        AppRoute.verifyOtp,
        arguments: VerifyOtpArgs(
          userId: p.result!.id,
          registerRequest: p.lastRequest!,
        ),
      );
    } else if (p.error != null) {
      AppToast.show(context, message: p.error!.message(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Validators validators = Validators(l10n);
    final RegisterProvider p = context.watch<RegisterProvider>();

    return LoadingOverlay(
      isVisible: p.isLoading,
      child: Scaffold(
        backgroundColor: AppColor.surface,
        appBar: AppBar(
          backgroundColor: AppColor.surface,
          elevation: 0,
          titleSpacing: 0,
          leading: const BackButton(color: AppColor.ink),
          title: Text(l10n.registerHeadline, style: AppTextStyle.titleLarge),
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
                      onEdit: () => showComingSoonDialog(context),
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
                    keyboardType: TextInputType.emailAddress,
                    validator: validators.email,
                  ),
                  const SizedBox(height: AppField.gap),

                  AppTextField(
                    hint: l10n.registerPasswordLabel,
                    iconPath: AppAssets.lockIcon,
                    controller: p.passwordController,
                    obscureText: p.obscurePassword,
                    validator: validators.password,
                    suffixIcon: PasswordToggle(
                      obscured: p.obscurePassword,
                      onPressed: p.toggleObscurePassword,
                    ),
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
                    label: l10n.registerSubmitButton,
                    isLoading: p.isLoading,
                    onPressed: p.isLoading || !p.isComplete
                        ? null
                        : () => _submit(context, p),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        l10n.registerHaveAccountQuestion,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColor.inkFaint,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(AppRoute.login),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Text(
                            l10n.registerLoginAction,
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: AppColor.orangeLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
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
