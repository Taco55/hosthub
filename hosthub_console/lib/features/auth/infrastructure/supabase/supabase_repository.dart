import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app_errors/app_errors.dart';

/// Base helper for repositories that talk to Supabase directly.
abstract class SupabaseRepository {
  SupabaseRepository(this.supabase);

  final SupabaseClient supabase;

  String get currentUserId {
    final user = supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw DomainErrorCode.unauthorized.err(
        message: 'User not logged in',
        context: const {'supabase_user': null},
      );
    }
    return user.id;
  }

  Map<String, dynamic> ensureCreator(Map<String, dynamic> json) {
    final payload = Map<String, dynamic>.from(json);
    final createdBy = payload['created_by'];
    if (createdBy == null ||
        (createdBy is String && createdBy.isEmpty) ||
        (createdBy is Iterable && createdBy.isEmpty)) {
      payload['created_by'] = currentUserId;
    }
    return payload;
  }

  List<Map<String, dynamic>> ensureCreatorForList(
    Iterable<Map<String, dynamic>> rows,
  ) => rows.map(ensureCreator).toList();

  DomainError mapError(
    Object error,
    StackTrace stack, {
    DomainErrorReason? reason,
    Map<String, Object?> context = const {},
  }) {
    final base = DomainError.from(error, stack: stack)
        .ensureLogoutOnInvalidRefresh();
    final mergedContext = <String, Object?>{
      'repository': runtimeType.toString(),
      if (base.context != null) ...base.context!,
      ...context,
    };
    final resolvedReason = base.reason ?? reason;
    return base.copyWith(
      reason: resolvedReason,
      context: mergedContext.isEmpty ? base.context : mergedContext,
    );
  }

  Future<Map<String, dynamic>?> maybeSingle(
    String table, {
    String columns = '*',
    Map<String, dynamic>? eq,
    Map<String, List<dynamic>>? inFilter,
  }) async {
    dynamic query = supabase.from(table).select(columns);
    eq?.forEach((key, value) {
      query = query.eq(key, value);
    });
    inFilter?.forEach((key, values) {
      query = query.inFilter(key, values);
    });

    final result = await query.maybeSingle();
    return result == null ? null : Map<String, dynamic>.from(result);
  }

  Future<List<Map<String, dynamic>>> selectList(
    String table, {
    String columns = '*',
    Map<String, dynamic>? eq,
    Map<String, List<dynamic>>? inFilter,
    String? orderBy,
    bool ascending = true,
  }) async {
    dynamic query = supabase.from(table).select(columns);
    eq?.forEach((key, value) {
      query = query.eq(key, value);
    });
    inFilter?.forEach((key, values) {
      query = query.inFilter(key, values);
    });
    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    final data = await query;
    return (data as List).map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> insert(
    String table,
    Map<String, dynamic> json, {
    bool ensureCreatedBy = true,
  }) async {
    final payload = ensureCreatedBy
        ? ensureCreator(json)
        : Map<String, dynamic>.from(json);
    await supabase.from(table).insert(payload);
  }

  Future<void> insertMany(
    String table,
    List<Map<String, dynamic>> rows, {
    bool ensureCreatedBy = true,
  }) async {
    if (rows.isEmpty) return;
    final payload = ensureCreatedBy
        ? ensureCreatorForList(rows)
        : rows.map((row) => Map<String, dynamic>.from(row)).toList();
    await supabase.from(table).insert(payload);
  }

  Future<void> upsert(
    String table,
    Map<String, dynamic> json, {
    bool ensureCreatedBy = true,
    String? onConflict,
  }) async {
    final payload = ensureCreatedBy
        ? ensureCreator(json)
        : Map<String, dynamic>.from(json);
    await supabase.from(table).upsert(payload, onConflict: onConflict);
  }

  Future<void> upsertMany(
    String table,
    List<Map<String, dynamic>> rows, {
    bool ensureCreatedBy = true,
    String? onConflict,
  }) async {
    if (rows.isEmpty) return;
    final payload = ensureCreatedBy
        ? ensureCreatorForList(rows)
        : rows.map((row) => Map<String, dynamic>.from(row)).toList();
    await supabase.from(table).upsert(payload, onConflict: onConflict);
  }

  Future<void> deleteWhere(String table, Map<String, dynamic> eq) async {
    var query = supabase.from(table).delete();
    eq.forEach((key, value) {
      query = query.eq(key, value);
    });
    await query;
  }

  Future<void> deleteIn(
    String table,
    String column,
    Iterable<dynamic> values,
  ) async {
    final list = values.toList();
    if (list.isEmpty) return;
    await supabase.from(table).delete().inFilter(column, list);
  }
}
