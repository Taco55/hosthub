import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/auth/presentation/widgets/env_version_badge.dart';
import 'package:hosthub_console/shared/l10n/l10n.dart';
import 'package:hosthub_console/shared/resources/resources.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

const double _kLoginFormMaxWidth = 420;

typedef LoginSubmitCallback =
    Future<void> Function(String email, String password);

typedef LoginAutofillResolver =
    ({String email, String password})? Function(String input);

enum LoginFormMode { login, register }

extension LoginFormModeX on LoginFormMode {
  bool get isLogin => this == LoginFormMode.login;

  String titleOf(S translations) =>
      isLogin ? translations.login : translations.register;

  String primaryLabelOf(S translations) =>
      isLogin ? translations.login : translations.register;

  String googleLabelOf(S translations) =>
      isLogin ? translations.loginWithGoogle : translations.registerWithGoogle;
}

/// Shared login form used across HostHub applications.
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    bool? isLogin,
    LoginFormMode mode = LoginFormMode.login,
    this.title,
    this.description,
    this.primaryButtonLabel,
    required this.onSubmit,
    this.isBusy = false,
    this.errorMessage,
    this.appError,
    this.onForgotPassword,
    this.forgotPasswordLabel,
    this.bottomActions = const <Widget>[],
    this.emailAutofillResolver,
    this.emailValidators,
    this.passwordValidators,
    this.onFormChanged,
    this.onModeToggle,
    this.onGoogleSignIn,
    this.googleSignInLabel,
    this.showBusyOverlay = false,
    this.busyOverlayBuilder,
  }) : mode = isLogin != null
           ? (isLogin ? LoginFormMode.login : LoginFormMode.register)
           : mode;

  final LoginFormMode mode;
  final String? title;
  final String? description;
  final String? primaryButtonLabel;
  final LoginSubmitCallback onSubmit;
  final bool isBusy;
  final String? errorMessage;
  final AppError? appError;
  final VoidCallback? onForgotPassword;
  final String? forgotPasswordLabel;
  final List<Widget> bottomActions;
  final LoginAutofillResolver? emailAutofillResolver;
  final List<FormFieldValidator<String>>? emailValidators;
  final List<FormFieldValidator<String>>? passwordValidators;
  final ValueChanged<bool>? onFormChanged;
  final VoidCallback? onModeToggle;
  final VoidCallback? onGoogleSignIn;
  final String? googleSignInLabel;
  final bool showBusyOverlay;
  final WidgetBuilder? busyOverlayBuilder;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _autoValidate = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final formState = _formKey.currentState;
    if (formState == null) return;
    final isValid = formState.validate();
    if (!isValid) {
      if (!_autoValidate) {
        setState(() {
          _autoValidate = true;
        });
        widget.onFormChanged?.call(false);
      }
      return;
    }

    widget.onFormChanged?.call(true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    widget.onSubmit(email, password);
  }

  void _handleEmailChanged(String value) {
    widget.onFormChanged?.call(false);
    final resolver = widget.emailAutofillResolver;
    if (resolver == null) return;
    final resolved = resolver(value.trim().toLowerCase());
    if (resolved == null) return;
    _emailController
      ..text = resolved.email
      ..selection = TextSelection.collapsed(offset: resolved.email.length);
    _passwordController.text = resolved.password;
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleText = widget.title ?? widget.mode.titleOf(context.s);
    final primaryButtonLabel =
        widget.primaryButtonLabel ?? widget.mode.primaryLabelOf(context.s);
    final emailHint = context.s.email;
    final passwordHint = context.s.password;

    final emailValidators =
        widget.emailValidators ??
        [
          (value) => FormBuilderValidators.required(
            errorText: context.s.requiredField,
          )(value?.trim()),
          (value) => FormBuilderValidators.email(
            errorText: context.s.enterValidEmail,
          )(value?.trim()),
        ];

    final passwordValidators =
        widget.passwordValidators ??
        [
          FormBuilderValidators.required(errorText: context.s.requiredField),
          FormBuilderValidators.minLength(
            6,
            errorText: context.s.enterMin6Characters,
          ),
        ];

    final forgotLabel = widget.onForgotPassword != null
        ? widget.forgotPasswordLabel ?? context.s.forgotPassword
        : null;
    final showInlineError =
        !AppConfig.current.authErrorsInDialog &&
        widget.appError != null &&
        !widget.isBusy;
    final resolvedError =
        widget.errorMessage ??
        (showInlineError ? widget.appError!.alert : null);

    final actionWidgets = <Widget>[];
    void addAction(Widget w) {
      if (actionWidgets.isNotEmpty) {
        actionWidgets.add(const SizedBox(height: 12));
      }
      actionWidgets.add(w);
    }

    if (widget.onModeToggle != null) {
      addAction(
        _ToggleText(
          isLogin: widget.mode.isLogin,
          isBusy: widget.isBusy,
          onTap: widget.onModeToggle!,
        ),
      );
    }

    for (final action in widget.bottomActions) {
      addAction(action);
    }

    if (widget.onGoogleSignIn != null) {
      addAction(
        _GoogleSignInButton(
          enabled: !widget.isBusy,
          label:
              widget.googleSignInLabel ?? widget.mode.googleLabelOf(context.s),
          onPressed: widget.onGoogleSignIn,
        ),
      );
    }

    final scaffold = OnboardingPageScaffold(
      title: titleText,
      contentMaxWidth: _kLoginFormMaxWidth,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kLoginFormMaxWidth),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.description != null) ...[
                  Text(widget.description!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: resolvedError == null
                      ? const SizedBox.shrink()
                      : Container(
                          key: const ValueKey('error'),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            resolvedError,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                ),
                StyledFormField(
                  name: 'email',
                  controller: _emailController,
                  placeholder: emailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enabled: !widget.isBusy,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  validators: emailValidators,
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: theme.appColors.onContrastBackgroundHard,
                  ),
                  onChanged: _handleEmailChanged,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                StyledFormField(
                  name: 'password',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  placeholder: passwordHint,
                  obscureText: true,
                  enablePasswordToggle: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  enabled: !widget.isBusy,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  validators: passwordValidators,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: theme.appColors.onContrastBackgroundHard,
                  ),
                  onChanged: (_) => widget.onFormChanged?.call(false),
                  onFieldSubmitted: (_) {
                    if (!widget.isBusy) _handleSubmit();
                  },
                ),
                if (forgotLabel != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: widget.isBusy ? null : widget.onForgotPassword,
                      child: Text(
                        forgotLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.appColors.activeButtonColor,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      primaryButtonLabel: primaryButtonLabel,
      onPrimaryPressed: widget.isBusy ? null : _handleSubmit,
      primaryButtonEnabled: !widget.isBusy,
      primaryButtonBusy: widget.isBusy,
      floatingPrimaryButton: false,
      primaryButtonMaxWidth: _kLoginFormMaxWidth,
      bottomActions: actionWidgets,
    );

    final result = !widget.showBusyOverlay
        ? scaffold
        : Stack(
            children: [
              scaffold,
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !widget.isBusy,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    opacity: widget.isBusy ? 1 : 0,
                    child:
                        widget.busyOverlayBuilder?.call(context) ??
                        const _DefaultBusyOverlay(),
                  ),
                ),
              ),
            ],
          );

    return Stack(
      children: [
        result,
        const Positioned(
          right: 16,
          bottom: 16,
          child: EnvVersionBadge(),
        ),
      ],
    );
  }
}

class _ToggleText extends StatelessWidget {
  const _ToggleText({
    required this.isLogin,
    required this.isBusy,
    required this.onTap,
  });

  final bool isLogin;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final translations = context.s;
    final baseText = isLogin
        ? translations.dontHaveAnAccount
        : translations.alreadyAnAccount;
    final actionText = isLogin ? translations.register : translations.login;

    final baseStyle = theme.textTheme.bodyMedium ?? theme.textTheme.bodySmall;
    final actionStyle = baseStyle?.copyWith(
      color: colors.activeButtonColor,
      fontWeight: FontWeight.w600,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: '$baseText '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: TextButton(
              onPressed: isBusy ? null : onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionText, style: actionStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final borderRadius = BorderRadius.circular(32);
    final borderColor = colors.activeButtonColor;
    final backgroundColor = theme.colorScheme.surface;
    final disabledColor = borderColor.withValues(alpha: 0.4);

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: enabled ? borderColor : disabledColor,
            width: 1.5,
          ),
        ),
        child: Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: StyledButton(
            enabled: enabled,
            expand: true,
            onPressed: enabled ? onPressed : null,
            minHeight: 54,
            cornerRadius: 32,
            backgroundColor: Colors.transparent,
            backgroundColorDisabled: Colors.transparent,
            enableShadow: false,
            titleWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: Image(
                      image: OrganizeImage.googleIcon,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: enabled ? borderColor : disabledColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
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

class _DefaultBusyOverlay extends StatelessWidget {
  const _DefaultBusyOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayColor = theme.colorScheme.surface.withValues(alpha: 0.6);
    return ColoredBox(
      color: overlayColor,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
