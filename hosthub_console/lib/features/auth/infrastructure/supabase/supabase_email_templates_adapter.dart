import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';

import 'package:hosthub_console/features/auth/domain/models/email_template_config.dart';
import 'package:hosthub_console/features/auth/domain/ports/email_templates_port.dart';
import 'package:app_errors/app_errors.dart';

const Map<String, String> _emailTemplateFallbacks = {
  'assets/email_templates/sign_up_confirmation.html': '''
<!DOCTYPE html>
<html lang="nl">
  <head>
    <meta charset="UTF-8" />
    <title>Bevestig je e-mailadres</title>
  </head>
  <body style="margin:0;padding:0;background-color:#f6f6f6;font-family:Arial,Helvetica,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#f6f6f6">
      <tr>
        <td align="center" style="padding:24px 12px;">
          <table width="600" cellpadding="0" cellspacing="0" border="0" style="background-color:#ffffff;border-radius:12px;padding:32px;box-shadow:0 2px 10px rgba(0,0,0,0.04);">
            <tr>
              <td>
                <img src="cid:logo-image" alt="HostHub logo" style="max-width:140px;margin-bottom:24px;" />
                <h2 style="color:#1c1c1c;font-size:26px;margin:0 0 16px 0;">Bevestig je e-mailadres</h2>
                {{env_banner}}
                <p style="color:#1c1c1c;font-size:16px;line-height:1.6;margin:0 0 12px 0;">{{greeting_line}}</p>
                <p style="color:#1c1c1c;font-size:16px;line-height:1.6;margin:0 0 12px 0;">
                  Bedankt voor je aanmelding bij HostHub. Bevestig je e-mailadres om je account te activeren.
                </p>
                {{action_section}}
                {{otp_section}}
                <hr style="border:none;border-top:1px solid #ededed;margin:32px 0;" />
                <p style="color:#6b7280;font-size:14px;line-height:1.6;margin:0 0 12px 0;">
                  Vragen of hulp nodig? Stuur ons een bericht via
                  <a href="mailto:{{support_email}}" style="color:#1c5d99;text-decoration:none;">{{support_email}}</a>.
                </p>
                <p style="color:#94a3b8;font-size:12px;line-height:1.4;margin:24px 0 0 0;">
                  Deze e-mail is automatisch verstuurd omdat er een account is aangemaakt met dit e-mailadres.
                </p>
              </td>
            </tr>
          </table>
          <p style="font-size:12px;color:#94a3b8;margin:24px 0 0 0;">© {{year}} HostHub. Alle rechten voorbehouden.</p>
        </td>
      </tr>
    </table>
  </body>
</html>
''',
};

class SupabaseEmailTemplatesAdapter implements EmailTemplatesPort {
  SupabaseEmailTemplatesAdapter({
    required SupabaseClient client,
    EmailTemplateConfig? templateConfig,
    AssetBundle? bundle,
  }) : _client = client,
       _templateConfig = templateConfig,
       _bundle = bundle ?? rootBundle;

  final SupabaseClient _client;
  final EmailTemplateConfig? _templateConfig;
  final AssetBundle _bundle;
  final Map<String, String> _templateCache = {};

  Future<void> sendLoginOtpEmail(
    String to, {
    String? actionLink,
    String? name,
    String? otp,
  }) async {
    await _sendTemplatedEmail(
      to: to,
      subject: 'Log in bij HostHub',
      templatePath: 'assets/email_templates/login_otp.html',
      actionLink: actionLink,
      name: name,
      otp: otp,
      context: 'sendLoginOtpEmail',
      copy: const EmailTemplateCopy(
        actionIntro:
            'Log direct in via de knop hieronder. De link opent HostHub automatisch.',
        actionButtonLabel: 'Open HostHub',
        actionFallback:
            'Werkt de knop niet? Kopieer dan deze link en plak hem in je browser:',
        otpIntroWithAction:
            'Lukt het niet via de knop? Gebruik dan onderstaande code:',
        otpIntroWithoutAction: 'Gebruik onderstaande code om in te loggen:',
      ),
    );
  }

  Future<void> sendSignUpConfirmationEmail(
    String to, {
    String? actionLink,
    String? name,
    String? otp,
  }) async {
    await _sendTemplatedEmail(
      to: to,
      subject: 'Bevestig je e-mailadres',
      templatePath: 'assets/email_templates/sign_up_confirmation.html',
      actionLink: actionLink,
      name: name,
      otp: otp,
      context: 'sendSignUpConfirmationEmail',
      copy: const EmailTemplateCopy(
        actionIntro:
            'Bevestig je e-mailadres via de knop hieronder. De link opent HostHub automatisch.',
        actionButtonLabel: 'Bevestig e-mailadres',
        actionFallback:
            'Werkt de knop niet? Kopieer dan deze link en plak hem in je browser:',
        otpIntroWithAction:
            'Werkt de knop niet? Gebruik dan onderstaande code om je account te bevestigen:',
        otpIntroWithoutAction:
            'Gebruik onderstaande code om je account te bevestigen:',
      ),
    );
  }

  Future<void> sendUserCreatedEmail(
    String to, {
    String? actionLink,
    String? name,
    String? otp,
  }) async {
    await _sendTemplatedEmail(
      to: to,
      subject: 'Welkom bij HostHub',
      templatePath: 'assets/email_templates/user_created.html',
      actionLink: actionLink,
      name: name,
      otp: otp,
      context: 'sendUserCreatedEmail',
    );
  }

  Future<void> sendPasswordResetEmail(
    String to,
    String? actionLink, {
    String? name,
    String? otp,
  }) async {
    await _sendTemplatedEmail(
      to: to,
      subject: 'Wachtwoord resetten',
      templatePath: 'assets/email_templates/password_reset.html',
      actionLink: actionLink,
      name: name,
      otp: otp,
      context: 'sendPasswordResetEmail',
    );
  }

  Future<void> sendSiteInvitationEmail(
    String to, {
    String? actionLink,
    String? otp,
    String? siteName,
    bool isNewUser = true,
  }) async {
    final buttonLabel =
        isNewUser ? 'Account aanmaken' : 'Open HostHub';
    final actionIntro = isNewUser
        ? 'Maak je account aan via de knop hieronder om toegang te krijgen.'
        : 'Klik op de knop hieronder om direct naar HostHub te gaan.';

    await _sendTemplatedEmail(
      to: to,
      subject: 'Je bent uitgenodigd voor ${siteName ?? 'een site'} op HostHub',
      templatePath: 'assets/email_templates/site_invitation.html',
      actionLink: actionLink,
      otp: otp,
      context: 'sendSiteInvitationEmail',
      copy: EmailTemplateCopy(
        actionIntro: actionIntro,
        actionButtonLabel: buttonLabel,
        actionFallback:
            'Werkt de knop niet? Kopieer dan deze link en plak hem in je browser:',
        otpIntroWithAction:
            'Lukt het niet via de knop? Gebruik dan onderstaande code:',
        otpIntroWithoutAction:
            'Gebruik onderstaande code om in te loggen:',
      ),
    );
  }

  Future<void> _sendTemplatedEmail({
    required String context,
    required String to,
    required String subject,
    required String templatePath,
    String? actionLink,
    String? otp,
    String? name,
    EmailTemplateCopy copy = const EmailTemplateCopy(),
  }) async {
    try {
      final html = await _loadHtmlTemplate(
        templatePath,
        actionLink: actionLink,
        name: name,
        otp: otp,
        copy: copy,
      );

      final subjectWithPrefix = _prefixSubject(subject);

      await _sendEmailViaFunction(
        to: to,
        subject: subjectWithPrefix,
        html: html,
        context: context,
      );
    } catch (error, stack) {
      final mergedContext = <String, Object?>{};
      if (error is DomainError && error.context != null) {
        mergedContext.addAll(error.context!);
      }
      mergedContext['email_context'] = context;
      mergedContext['template_path'] = templatePath;
      throw DomainError.of(
        DomainErrorCode.serverError,
        reason: DomainErrorReason.emailSendFailed,
        message: '$context: unexpected email failure – ${error.toString()}',
        cause: error,
        stack: stack,
        context: mergedContext,
      );
    }
  }

  Future<String> _loadHtmlTemplate(
    String path, {
    String? actionLink,
    String? name,
    String? otp,
    EmailTemplateCopy copy = const EmailTemplateCopy(),
  }) async {
    try {
      final template = await _loadTemplateSource(path);
      final trimmedActionLink = actionLink?.trim() ?? '';
      final hasActionLink = trimmedActionLink.isNotEmpty;
      final trimmedOtp = otp?.trim() ?? '';

      final replacements = <String, String>{
        'name': name?.trim() ?? '',
        'greeting_line': _buildGreeting(name),
        'action_link': trimmedActionLink,
        'action_section': hasActionLink
            ? _buildActionSection(trimmedActionLink, copy)
            : '',
        'otp': trimmedOtp,
        'otp_section': _buildOtpSection(
          trimmedOtp,
          hasActionLink: hasActionLink,
          copy: copy,
        ),
        'env_banner': _buildEnvironmentBanner(),
        'support_email': AppConfig.current.supportEmail,
        'year': DateTime.now().year.toString(),
      };

      return _renderTemplate(template, replacements);
    } catch (error) {
      throw DomainError.of(
        DomainErrorCode.serverError,
        message: '_loadHtmlTemplate: failed to load or parse $path',
        cause: error,
        context: {'template_path': path},
      );
    }
  }

  Future<String> _loadTemplateSource(String path) async {
    final cached = _templateCache[path];
    if (cached != null) return cached;
    try {
      final contents = await _bundle.loadString(path);
      _templateCache[path] = contents;
      return contents;
    } on FlutterError catch (error) {
      final fallback = _emailTemplateFallbacks[path];
      if (fallback != null) {
        developer.log(
          'Email template asset missing, using in-memory fallback.',
          name: 'SupabaseEmailTemplatesAdapter',
          error: error,
        );
        _templateCache[path] = fallback;
        return fallback;
      }
      rethrow;
    }
  }

  String _renderTemplate(String template, Map<String, String> replacements) {
    var result = template;
    for (final entry in replacements.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }
    return result;
  }

  String _prefixSubject(String subject) {
    final label = _templateConfig?.envLabel?.trim();
    if (label == null || label.isEmpty) return subject;
    return '[$label] $subject';
  }

  String _buildGreeting(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Hallo!';
    }
    return 'Hallo $trimmed,';
  }

  String _buildEnvironmentBanner() {
    final envLabel = _templateConfig?.envLabel?.trim();
    if (envLabel == null || envLabel.isEmpty) return '';
    return '<div style="display:inline-block;margin:6px 0 14px 0;padding:6px 10px;background:#fffae6;color:#663c00;border:1px solid #ffe58f;border-radius:4px;font-size:12px;font-weight:700;">$envLabel</div>';
  }

  String _buildActionSection(String actionLink, EmailTemplateCopy copy) {
    final intro =
        copy.actionIntro ??
        'Klik op onderstaande knop om je wachtwoord in te stellen.';
    final buttonLabel = copy.actionButtonLabel ?? 'Wachtwoord instellen';
    final fallback =
        copy.actionFallback ??
        'Werkt de knop niet? Kopieer dan deze link en plak hem in je browser:';
    return '''
<p style="font-size:0.95rem;color:#444;margin-top:20px">$intro</p>
<p style="margin-top:16px;">
  <a href="$actionLink" style="display:inline-block;padding:12px 22px;background-color:#1c5d99;color:#ffffff;text-decoration:none;border-radius:6px;font-weight:600;">
    $buttonLabel
  </a>
</p>
<p style="font-size:0.85rem;color:#666;margin-top:10px;">
  $fallback<br />
  <a href="$actionLink">$actionLink</a>
</p>
''';
  }

  String _buildOtpSection(
    String otp, {
    required bool hasActionLink,
    required EmailTemplateCopy copy,
  }) {
    final trimmed = otp.trim();
    if (trimmed.isEmpty) return '';

    final intro = hasActionLink
        ? (copy.otpIntroWithAction ??
              'Lukt het niet via de knop? Gebruik dan onderstaande code:')
        : (copy.otpIntroWithoutAction ??
              'Gebruik onderstaande code om je wachtwoord in te stellen:');

    return '''
<p style="font-size:0.95rem;color:#444;margin-top:24px;">$intro</p>
<p style="font-size:1.3rem;font-weight:700;letter-spacing:2px;margin:12px 0;color:#222;">$trimmed</p>
''';
  }

  Future<void> _sendEmailViaFunction({
    required String to,
    required String subject,
    required String html,
    required String context,
  }) async {
    final response = await _client.functions.invoke(
      'send_email',
      body: {'to': to, 'subject': subject, 'html': html},
    );

    if (response.status != 200) {
      throw DomainError.of(
        DomainErrorCode.serverError,
        message: '$context: Supabase function failed (${response.status})',
        cause: response.data,
        context: {'function': 'send_email', 'status': response.status},
      );
    }
  }
}

class EmailTemplateCopy {
  const EmailTemplateCopy({
    this.actionIntro,
    this.actionButtonLabel,
    this.actionFallback,
    this.otpIntroWithAction,
    this.otpIntroWithoutAction,
  });

  final String? actionIntro;
  final String? actionButtonLabel;
  final String? actionFallback;
  final String? otpIntroWithAction;
  final String? otpIntroWithoutAction;
}
