import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/constants/app_duration.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/models/onboarding_content.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/widgets/onboarding_action.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/widgets/onboarding_indicator.dart';
import 'package:mobile_barberstuff/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  late List<OnboardingContent> _items;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _items = OnboardingContent.items(AppLocalizations.of(context));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLastSlide => _index == _items.length - 1;

  void _handleAction() {
    if (_isLastSlide) {
      Navigator.of(context).pushReplacementNamed(AppRoute.chooseLogin);
      return;
    }

    _controller.nextPage(
      duration: AppDuration.slideChange,
      curve: Curves.easeOutCubic,
    );
  }

  double _offsetFor(int index) {
    if (!_controller.hasClients || !_controller.position.haveDimensions) {
      return (_index - index).toDouble();
    }
    return (_controller.page ?? _index.toDouble()) - index;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColor.surface,
        body: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (int index) => setState(() => _index = index),
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? child) {
                      return OnboardingSlide(
                        content: _items[index],
                        offset: _offsetFor(index),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            OnboardingIndicator(length: _items.length, activeIndex: _index),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                child: OnboardingAction(
                  isExpanded: _isLastSlide,
                  label: AppLocalizations.of(context).onboardingStart,
                  onPressed: _handleAction,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
