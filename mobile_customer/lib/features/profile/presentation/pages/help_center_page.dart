import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/core/utils/validators.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/presentation/widgets/labeled_field.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/coming_soon_dialog.dart';

class HelpCenterArgs {
  const HelpCenterArgs({required this.profile});

  final CustomerProfile profile;
}

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key, required this.args});

  final HelpCenterArgs args;

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  static const double _gap = 18;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final TextEditingController _problem = TextEditingController();

  @override
  void initState() {
    super.initState();
    final CustomerProfile profile = widget.args.profile;
    _name = TextEditingController(text: profile.name);
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phoneNumber);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _problem.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    showComingSoonDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Validators validators = Validators(l10n);

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: AppColor.ink),
        title: Text(
          l10n.helpTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: <Widget>[
              Text(l10n.helpHeadline, style: AppTextStyle.titleMedium),
              const SizedBox(height: 6),
              Text(
                l10n.helpSubtitle,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.inkFaint,
                ),
              ),
              const SizedBox(height: 22),

              LabeledField(
                label: l10n.helpNameLabel,
                iconPath: AppAssets.userProfile,
                controller: _name,
                keyboardType: TextInputType.name,
                validator: (String? v) =>
                    validators.required(v, label: l10n.helpNameLabel),
              ),
              const SizedBox(height: _gap),

              LabeledField(
                label: l10n.registerEmailLabel,
                iconPath: AppAssets.mailIcon,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: validators.email,
              ),
              const SizedBox(height: _gap),

              LabeledField(
                label: l10n.registerPhoneLabel,
                iconPath: AppAssets.phoneIcon,
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: validators.phoneNumber,
              ),
              const SizedBox(height: _gap),

              LabeledField(
                label: l10n.helpProblemLabel,
                controller: _problem,
                hintText: l10n.helpProblemHint,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (String? v) =>
                    validators.required(v, label: l10n.helpProblemLabel),
              ),
              const SizedBox(height: 28),

              BoxButton(label: l10n.helpSubmit, radius: 12, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
