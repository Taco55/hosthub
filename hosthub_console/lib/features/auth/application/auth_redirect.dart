import 'package:hosthub_console/features/auth/application/bloc/auth_bloc.dart';

typedef AuthRedirect = String? Function(AuthRedirectRequest request);

class AuthRedirectRequest {
  const AuthRedirectRequest({
    required this.sourceUri,
    required this.normalizedPath,
    required this.queryParameters,
    required this.authState,
    required this.hasCompletedOnboarding,
    required this.baseUri,
    required this.isFirstLogin,
  });

  final Uri sourceUri;
  final String normalizedPath;
  final Map<String, String> queryParameters;
  final AuthState authState;
  final bool? hasCompletedOnboarding;
  final Uri baseUri;
  final bool isFirstLogin;
}

String? _sanitizeRedirectTarget(String? rawTarget) {
  if (rawTarget == null || rawTarget.isEmpty) return null;

  String decoded;
  try {
    decoded = Uri.decodeComponent(rawTarget);
  } on FormatException {
    return null;
  }

  if (!decoded.startsWith('/')) return null;
  if (decoded.startsWith('//')) return null;

  final candidate = Uri.tryParse(decoded);
  if (candidate == null) return null;
  if (candidate.hasScheme || candidate.hasAuthority) return null;

  return candidate.toString();
}

AuthRedirect buildAuthRedirect() {
  const onboardingRootPath = '/onboarding';
  const onboardingPaths = {
    '/',
    onboardingRootPath,
    '/onboarding/signIn',
    '/onboarding/signIn/password',
    '/onboarding/signIn/sent',
    '/onboarding/signUp',
    '/onboarding/confirm',
  };

  const onboardingPreviewPath = '/onboarding/preview';
  const listPreparationPath = '/listPreparation';

  String? redirectUnauthenticated(
    AuthState authState,
    String path,
    bool? hasCompletedOnboarding,
  ) {
    if (hasCompletedOnboarding == null) return null;
    if (authState.step == AuthenticatorStep.loadingProfile) return null;

    if (path == onboardingPreviewPath) return null;

    final step = authState.step;
    final isOnboardingPath =
        path == onboardingRootPath || path.startsWith('$onboardingRootPath/');

    if ((step == AuthenticatorStep.confirmSignUp ||
            step == AuthenticatorStep.confirmSignInOtp) &&
        (path == '/onboarding/signIn' ||
            path == '/onboarding/signIn/password' ||
            path == '/onboarding/signIn/sent')) {
      return null;
    }

    return switch (step) {
      AuthenticatorStep.confirmSignUp =>
        path == '/onboarding/confirm' ? null : '/onboarding/confirm',
      AuthenticatorStep.confirmSignInOtp =>
        path == '/onboarding/signIn/sent' ? null : '/onboarding/signIn/sent',
      AuthenticatorStep.signUp =>
        path == '/onboarding/signUp' ? null : '/onboarding/signUp',
      AuthenticatorStep.signIn => isOnboardingPath ? null : onboardingRootPath,
      AuthenticatorStep.onboarding ||
      _ => isOnboardingPath ? null : onboardingRootPath,
    };
  }

  return (request) {
    final path = request.normalizedPath;
    final authState = request.authState;

    if (authState.status == AuthStatus.unauthenticated) {
      return redirectUnauthenticated(
        authState,
        path,
        request.hasCompletedOnboarding,
      );
    }

    if (authState.step == AuthenticatorStep.loadingProfile) return null;

    if (authState.status == AuthStatus.authenticated &&
        authState.step == AuthenticatorStep.done) {
      if (request.isFirstLogin) {
        if (path == listPreparationPath) {
          return null;
        }
        return listPreparationPath;
      }

      if (path == listPreparationPath) {
        return '/home';
      }

      // Redirect authenticated users away from onboarding or root to /home
      if (onboardingPaths.contains(path)) {
        final target = _sanitizeRedirectTarget(
          request.queryParameters['redirect'],
        );
        if (target != null && target != path) {
          return target;
        }
        return '/home';
      }
    }

    // All other cases: no redirect
    return null;
  };
}
