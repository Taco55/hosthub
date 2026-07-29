// supabase/functions/_shared/auth_email_templates.ts
//
// The five transactional auth mails, moved here from the console's
// assets/email_templates/*.html.
//
// They live server-side because the credential they carry must not travel
// through the client: the function that renders them is the same one that mints
// the link and hands it to Resend, so an "action_link" never appears in any
// response. Copy is Dutch, matching the templates they came from.
//
// Placeholders are {{name}}, {{greeting_line}}, {{action_link}},
// {{action_section}}, {{otp}}, {{otp_section}}, {{env_banner}},
// {{support_email}} and {{year}} — see renderAuthEmail in ./auth_email.ts.

export type AuthEmailTemplateId =
  | "loginOtp"
  | "signUpConfirmation"
  | "userCreated"
  | "passwordReset"
  | "siteInvitation"

export const AUTH_EMAIL_TEMPLATES: Record<AuthEmailTemplateId, string> = {
  loginOtp: String.raw`<!DOCTYPE html>
<html lang="nl">
  <head>
    <meta charset="UTF-8" />
    <title>Log in bij HostHub</title>
  </head>
  <body style="margin:0;padding:0;background-color:#f6f6f6;font-family:Arial,Helvetica,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#f6f6f6">
      <tr>
        <td align="center" style="padding:24px 12px;">
          <table width="600" cellpadding="0" cellspacing="0" border="0" style="background-color:#ffffff;border-radius:12px;padding:32px;box-shadow:0 2px 10px rgba(0,0,0,0.04);">
            <tr>
              <td style="text-align:center;">
                <img src="cid:logo-image" alt="HostHub logo" style="max-width:120px;margin-bottom:20px;" />
                <h2 style="color:#1c1c1c;font-size:24px;margin:0 0 12px 0;">Log direct in</h2>
                {{env_banner}}
                <p style="color:#1c1c1c;font-size:16px;line-height:1.6;margin:0 0 12px 0;">
                  We hebben een inlogcode voor je HostHub-account aangemaakt.
                </p>
                {{action_section}}
                {{otp_section}}
                <hr style="border:none;border-top:1px solid #ededed;margin:32px 0;" />
                <p style="color:#94a3b8;font-size:12px;line-height:1.4;margin:0;">
                  Hulp nodig? Mail ons via
                  <a href="mailto:{{support_email}}" style="color:#1c5d99;text-decoration:none;">{{support_email}}</a>.
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
`,
  signUpConfirmation: String.raw`<!DOCTYPE html>
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
`,
  userCreated: String.raw`<!DOCTYPE html>
<html lang="nl">
  <head>
    <meta charset="UTF-8" />
    <title>Welkom bij HostHub</title>
  </head>
  <body style="margin:0;padding:0;background-color:#f6f6f6;font-family:Arial,Helvetica,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#f6f6f6">
      <tr>
        <td align="center" style="padding:24px 12px;">
          <table width="600" cellpadding="0" cellspacing="0" border="0" style="background-color:#ffffff;border-radius:12px;padding:32px;box-shadow:0 2px 10px rgba(0,0,0,0.04);">
            <tr>
              <td>
                <img src="cid:logo-image" alt="HostHub logo" style="max-width:140px;margin-bottom:24px;" />
                <h2 style="color:#1c1c1c;font-size:26px;margin:0 0 16px 0;">Welkom bij HostHub</h2>
                {{env_banner}}
                <p style="color:#1c1c1c;font-size:16px;line-height:1.5;margin:0 0 12px 0;">{{greeting_line}}</p>
                <p style="color:#1c1c1c;font-size:16px;line-height:1.6;margin:0 0 12px 0;">
                  Er is een HostHub-account voor je aangemaakt. Met dit account krijg je toegang tot HostHub en kun je direct aan de slag.
                </p>
                <p style="color:#1c1c1c;font-size:16px;line-height:1.6;margin:0 0 12px 0;">
                  Stel je wachtwoord in via de knop hieronder. Je kunt daarna direct inloggen.
                </p>
                {{action_section}}
                {{otp_section}}
                <hr style="border:none;border-top:1px solid #ededed;margin:32px 0;" />
                <p style="color:#6b7280;font-size:14px;line-height:1.6;margin:0 0 12px 0;">
                  Vragen of hulp nodig? Stuur ons een bericht via
                  <a href="mailto:{{support_email}}" style="color:#1c5d99;text-decoration:none;">{{support_email}}</a>.
                </p>
                <p style="color:#94a3b8;font-size:12px;line-height:1.4;margin:24px 0 0 0;">
                  Deze e-mail is automatisch verstuurd omdat er een HostHub-account voor je is aangemaakt.
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
`,
  passwordReset: String.raw`<!DOCTYPE html>
<html lang="nl">
  <head>
    <meta charset="UTF-8" />
    <title>Wachtwoord resetten</title>
  </head>
  <body style="margin:0;padding:0;background-color:#f6f6f6;font-family:Arial,Helvetica,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#f6f6f6">
      <tr>
        <td align="center" style="padding:24px 12px;">
          <table width="600" cellpadding="0" cellspacing="0" border="0" style="background-color:#ffffff;border-radius:12px;padding:32px;box-shadow:0 2px 10px rgba(0,0,0,0.04);">
            <tr>
              <td style="text-align:center;">
                <img src="cid:logo-image" alt="HostHub logo" style="max-width:120px;margin-bottom:20px;" />
                <h2 style="color:#1c1c1c;font-size:24px;margin:0 0 12px 0;">Wachtwoord resetten</h2>
                {{env_banner}}
                <p style="color:#1c1c1c;font-size:16px;line-height:1.6;margin:0 0 12px 0;">
                  We hebben een verzoek ontvangen om het wachtwoord van je HostHub-account opnieuw in te stellen.
                </p>
                {{action_section}}
                {{otp_section}}
                <hr style="border:none;border-top:1px solid #ededed;margin:32px 0;" />
                <p style="color:#94a3b8;font-size:12px;line-height:1.4;margin:0;">
                  Heb je dit niet zelf aangevraagd? Dan kun je deze e-mail negeren. Je kunt ons bereiken via
                  <a href="mailto:{{support_email}}" style="color:#1c5d99;text-decoration:none;">{{support_email}}</a>.
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
`,
  siteInvitation: String.raw`<!DOCTYPE html>
<html lang="nl">
  <head>
    <meta charset="UTF-8" />
    <title>Uitnodiging voor HostHub</title>
  </head>
  <body style="margin:0;padding:0;background-color:#f6f6f6;font-family:Arial,Helvetica,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#f6f6f6">
      <tr>
        <td align="center" style="padding:24px 12px;">
          <table width="600" cellpadding="0" cellspacing="0" border="0" style="background-color:#ffffff;border-radius:12px;padding:32px;box-shadow:0 2px 10px rgba(0,0,0,0.04);">
            <tr>
              <td>
                <img src="cid:logo-image" alt="HostHub logo" style="max-width:140px;margin-bottom:24px;" />
                <h2 style="color:#1c1c1c;font-size:26px;margin:0 0 16px 0;">Je bent uitgenodigd</h2>
                {{env_banner}}
                <p style="color:#1c1c1c;font-size:16px;line-height:1.5;margin:0 0 12px 0;">{{greeting_line}}</p>
                <p style="color:#1c1c1c;font-size:16px;line-height:1.6;margin:0 0 12px 0;">
                  Je bent uitgenodigd om samen te werken op HostHub. Met deze uitnodiging krijg je toegang tot het beheer van een site en de bijbehorende content.
                </p>
                {{action_section}}
                {{otp_section}}
                <hr style="border:none;border-top:1px solid #ededed;margin:32px 0;" />
                <p style="color:#6b7280;font-size:14px;line-height:1.6;margin:0 0 12px 0;">
                  Vragen of hulp nodig? Stuur ons een bericht via
                  <a href="mailto:{{support_email}}" style="color:#1c5d99;text-decoration:none;">{{support_email}}</a>.
                </p>
                <p style="color:#94a3b8;font-size:12px;line-height:1.4;margin:24px 0 0 0;">
                  Deze e-mail is automatisch verstuurd omdat iemand je heeft uitgenodigd voor HostHub.
                </p>
              </td>
            </tr>
          </table>
          <p style="font-size:12px;color:#94a3b8;margin:24px 0 0 0;">&copy; {{year}} HostHub. Alle rechten voorbehouden.</p>
        </td>
      </tr>
    </table>
  </body>
</html>
`,
};
