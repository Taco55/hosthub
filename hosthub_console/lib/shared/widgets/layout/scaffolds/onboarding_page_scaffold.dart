import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// A minimal scaffold tailored for onboarding/login flows.
class OnboardingPageScaffold extends StatelessWidget {
  const OnboardingPageScaffold({
    super.key,
    this.title,
    required this.body,
    required this.contentMaxWidth,
    this.primaryButtonLabel,
    this.onPrimaryPressed,
    this.primaryButtonEnabled = true,
    this.primaryButtonBusy = false,
    this.primaryButtonMaxWidth,
    this.bottomActions = const <Widget>[],
    this.floatingPrimaryButton = false,
  });

  final String? title;
  final Widget body;
  final double contentMaxWidth;
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final bool primaryButtonEnabled;
  final bool primaryButtonBusy;
  final double? primaryButtonMaxWidth;
  final List<Widget> bottomActions;
  final bool floatingPrimaryButton;

  Widget? get _primaryButton {
    if (primaryButtonLabel == null) return null;
    return StyledButton(
      enabled: primaryButtonEnabled,
      minHeight: 52,
      expand: true,
      title: primaryButtonLabel!,
      onPressed: primaryButtonEnabled ? onPrimaryPressed : null,
    );
  }

  Widget _wrapButton(Widget child) {
    if (primaryButtonMaxWidth == null) return child;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: primaryButtonMaxWidth!),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = _primaryButton;
    final columnChildren = <Widget>[
      if (title != null) ...[
        Text(
          title!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 32),
      ],
      body,
      if (!floatingPrimaryButton && button != null) ...[
        const SizedBox(height: 24),
        _wrapButton(button),
      ],
      if (bottomActions.isNotEmpty) ...[
        const SizedBox(height: 24),
        ...bottomActions,
      ],
    ];

    return PopScope(
      canPop: Navigator.of(context).canPop(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 32,
                left: 24,
                right: 24,
                bottom: 64,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: columnChildren,
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: floatingPrimaryButton && button != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _wrapButton(button),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
