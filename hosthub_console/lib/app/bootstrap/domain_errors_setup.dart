import 'package:app_errors/supabase_adapter.dart';

/// The core of the error flow, before anything converts an error: the
/// Supabase adapter, with Dio's adapter and carrier built in after it.
void configureDomainErrors() =>
    DomainErrors.configure(adapters: const [supabaseAdapter]);
