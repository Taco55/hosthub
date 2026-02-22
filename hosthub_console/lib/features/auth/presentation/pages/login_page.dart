import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosthub_console/features/auth/application/bloc/auth_bloc.dart';
import 'package:hosthub_console/features/auth/presentation/pages/password_reset_page.dart';
import 'package:hosthub_console/features/auth/presentation/widgets/login_form.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';
import 'package:app_errors/app_errors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.initialMode = LoginFormMode.login});

  final LoginFormMode initialMode;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginFormMode _mode;

  LoginAutofillResolver? get _debugAutofillResolver {
    if (!kDebugMode) return null;
    const demoCredentials = <String, (String, String)>{
      'taco': ('taco.kind@gmail.com', '1234abcd'),
      'taco.': ('taco.kind@gmail.com', '1234abcd'),
      'demo1': ('taco.kind@gmail.com', '1234abcd'),
      'demo2': ('taco.kind+organize2@gmail.com', '1234abcd'),
    };
    return (input) {
      final record = demoCredentials[input];
      if (record == null) return null;
      final (email, password) = record;
      return (email: email, password: password);
    };
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode.isLogin ? LoginFormMode.register : LoginFormMode.login;
    });
  }

  Future<void> _handleSubmit(
    BuildContext context,
    String email,
    String password,
  ) async {
    context.read<AuthBloc>().add(AuthEvent.signInRequested(email, password));
  }

  Future<void> _handleRegister(
    BuildContext context,
    String email,
    String password,
  ) async {
    context.read<AuthBloc>().add(AuthEvent.signUpRequested(email, password));
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void didUpdateWidget(LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMode != widget.initialMode) {
      setState(() {
        _mode = widget.initialMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.error && current.domainError != null,
      listener: (context, state) async {
        final domainError = state.domainError;
        if (domainError == null) return;
        final appError = AppError.fromDomain(context, domainError);
        await showAppError(context, appError);
      },
      builder: (context, state) {
        final isBusy = state.status == AuthStatus.loading;
        final l10n = context.s;
        final description = _mode.isLogin
            ? context.s.loginDescription
            : context.s.createUserDescription;
        final primaryLabel = _mode.isLogin ? l10n.login : l10n.register;
        final appError = state.domainError == null
            ? null
            : AppError.fromDomain(context, state.domainError!);

        return LoginForm(
          title: "HostHub",
          mode: _mode,
          description: description,
          primaryButtonLabel: primaryLabel,
          isBusy: isBusy,
          appError: appError,
          emailAutofillResolver: _debugAutofillResolver,
          onSubmit: (email, password) => _mode.isLogin
              ? _handleSubmit(context, email, password)
              : _handleRegister(context, email, password),
          onForgotPassword: _mode.isLogin
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PasswordResetPage(),
                    ),
                  );
                }
              : null,
          onModeToggle: _toggleMode,
          showBusyOverlay: true,
          busyOverlayBuilder: (_) =>
              const ColoredBox(color: Colors.transparent),
        );
      },
    );
  }
}
