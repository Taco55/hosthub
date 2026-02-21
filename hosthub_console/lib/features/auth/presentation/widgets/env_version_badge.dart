import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:hosthub_console/core/core.dart';

class EnvVersionBadge extends StatefulWidget {
  const EnvVersionBadge({super.key});

  @override
  State<EnvVersionBadge> createState() => _EnvVersionBadgeState();
}

class _EnvVersionBadgeState extends State<EnvVersionBadge> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final env = AppConfig.current.environment;
    if (env.isPrd) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final envLabel = env.shortName;
    final versionLabel = _version != null ? 'v$_version' : '';
    final label = [envLabel, versionLabel].where((s) => s.isNotEmpty).join(' ');

    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
