import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';

class SiteSummary {
  const SiteSummary({
    required this.id,
    required this.name,
    required this.defaultLocale,
    required this.locales,
    required this.timezone,
    required this.createdAt,
    this.contactEmail,
    this.emailFromName,
    this.lodgifyPropertyId,
    this.lodgifyRoomTypeId,
  });

  final String id;
  final String name;
  final String defaultLocale;
  final List<String> locales;
  final String timezone;
  final DateTime createdAt;

  // Per-site website config (see migration 20260723120000). Nullable: the public
  // site falls back to worker env when unset.
  final String? contactEmail;
  final String? emailFromName;
  final String? lodgifyPropertyId;
  final String? lodgifyRoomTypeId;

  factory SiteSummary.fromMap(Map<String, dynamic> map) {
    return SiteSummary(
      id: map['id'] as String,
      name: map['name'] as String,
      defaultLocale: map['default_locale'] as String,
      locales:
          (map['locales'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      timezone: map['timezone'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      contactEmail: map['contact_email'] as String?,
      emailFromName: map['email_from_name'] as String?,
      lodgifyPropertyId: map['lodgify_property_id'] as String?,
      lodgifyRoomTypeId: map['lodgify_room_type_id'] as String?,
    );
  }

  @override
  String toString() {
    return 'SiteSummary('
        'id: $id, '
        'name: $name, '
        'defaultLocale: $defaultLocale, '
        'locales: $locales, '
        'timezone: $timezone)';
  }
}

class ContentDocument {
  const ContentDocument({
    required this.id,
    required this.siteId,
    required this.contentType,
    required this.slug,
    required this.locale,
    required this.content,
    required this.status,
    required this.updatedAt,
    this.draftContent,
    this.publishedAt,
    this.updatedBy,
  });

  final String id;
  final String siteId;
  final String contentType;
  final String slug;
  final String locale;

  /// The published content — what the public site renders.
  final Map<String, dynamic> content;

  /// Unpublished work in progress, or null when there is none. Editors show
  /// this over [content]; publishing promotes it and clears it.
  final Map<String, dynamic>? draftContent;
  final String status;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final String? updatedBy;

  /// What an editor opens: the draft when there is one, else what is live.
  Map<String, dynamic> get editableContent => draftContent ?? content;

  /// Whether this document has saved changes that are not live yet.
  bool get hasDraft => draftContent != null;

  factory ContentDocument.fromMap(Map<String, dynamic> map) {
    return ContentDocument(
      id: map['id'] as String,
      siteId: map['site_id'] as String,
      contentType: map['content_type'] as String,
      slug: map['slug'] as String,
      locale: map['locale'] as String,
      content: Map<String, dynamic>.from(map['content'] as Map),
      draftContent: map['draft_content'] == null
          ? null
          : Map<String, dynamic>.from(map['draft_content'] as Map),
      status: map['status'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      publishedAt: map['published_at'] == null
          ? null
          : DateTime.parse(map['published_at'] as String),
      updatedBy: map['updated_by'] as String?,
    );
  }

  @override
  String toString() {
    return 'ContentDocument('
        'id: $id, '
        'siteId: $siteId, '
        'contentType: $contentType, '
        'slug: $slug, '
        'locale: $locale, '
        'status: $status, '
        'updatedAt: ${updatedAt.toIso8601String()}, '
        'contentKeys: ${content.keys.length})';
  }
}

class DocumentVersion {
  const DocumentVersion({
    required this.id,
    required this.documentId,
    required this.version,
    required this.content,
    required this.publishedAt,
    this.publishedBy,
  });

  final String id;
  final String documentId;
  final int version;
  final Map<String, dynamic> content;
  final DateTime publishedAt;
  final String? publishedBy;

  factory DocumentVersion.fromMap(Map<String, dynamic> map) {
    return DocumentVersion(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      version: map['version'] as int,
      content: Map<String, dynamic>.from(map['content'] as Map),
      publishedAt: DateTime.parse(map['published_at'] as String),
      publishedBy: map['published_by'] as String?,
    );
  }

  @override
  String toString() {
    return 'DocumentVersion('
        'id: $id, '
        'documentId: $documentId, '
        'version: $version, '
        'publishedAt: ${publishedAt.toIso8601String()})';
  }
}

class CmsRepository extends SupabaseRepository {
  CmsRepository({required SupabaseClient supabase}) : super(supabase);

  // ---------------------------------------------------------------------------
  // Sites
  // ---------------------------------------------------------------------------

  Future<List<SiteSummary>> fetchSites() async {
    try {
      final response = await supabase
          .from('sites')
          .select(
            'id, name, default_locale, locales, timezone, created_at, '
            'contact_email, email_from_name, lodgify_property_id, lodgify_room_type_id',
          )
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((row) => SiteSummary.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: const {'op': 'fetchSites'},
      );
    }
  }

  Future<SiteSummary?> fetchSite(String siteId) async {
    try {
      final response = await supabase
          .from('sites')
          .select(
            'id, name, default_locale, locales, timezone, created_at, '
            'contact_email, email_from_name, lodgify_property_id, lodgify_room_type_id',
          )
          .eq('id', siteId)
          .maybeSingle();
      if (response == null) return null;
      return SiteSummary.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchSite', 'siteId': siteId},
      );
    }
  }

  /// Update this site's per-site website config. Pass null to clear a value
  /// (the public site then falls back to the worker env default).
  Future<void> updateSiteSettings(
    String siteId, {
    String? contactEmail,
    String? emailFromName,
    String? lodgifyPropertyId,
    String? lodgifyRoomTypeId,
  }) async {
    try {
      await supabase
          .from('sites')
          .update({
            'contact_email': contactEmail,
            'email_from_name': emailFromName,
            'lodgify_property_id': lodgifyPropertyId,
            'lodgify_room_type_id': lodgifyRoomTypeId,
          })
          .eq('id', siteId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateSiteSettings', 'siteId': siteId},
      );
    }
  }

  /// Changes the site's source language. The locale must be one of the site's
  /// enabled locales; the website editor treats it as the language the owner
  /// authors in (all other locales derive from it).
  Future<void> updateSiteDefaultLocale(String siteId, String locale) async {
    try {
      await supabase
          .from('sites')
          .update({'default_locale': locale})
          .eq('id', siteId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateSiteDefaultLocale', 'siteId': siteId},
      );
    }
  }

  /// Replaces the site's enabled website languages (`sites.locales`).
  Future<void> updateSiteLocales(String siteId, List<String> locales) async {
    try {
      await supabase
          .from('sites')
          .update({'locales': locales})
          .eq('id', siteId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateSiteLocales', 'siteId': siteId},
      );
    }
  }

  /// Renames the site (the property display name on the public website).
  Future<void> updateSiteName(String siteId, String name) async {
    try {
      await supabase.from('sites').update({'name': name}).eq('id', siteId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateSiteName', 'siteId': siteId},
      );
    }
  }

  Future<void> createSite({
    required String name,
    required String defaultLocale,
    required List<String> locales,
    String timezone = 'Europe/Oslo',
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw DomainErrorCode.unauthorized.err(
        reason: DomainErrorReason.permissionDenied,
        message: 'No authenticated user available for site creation.',
        context: const {'op': 'createSite', 'user_id': null},
      );
    }
    try {
      final response = await supabase
          .from('sites')
          .insert({
            'owner_profile_id': userId,
            'name': name,
            'default_locale': defaultLocale,
            'locales': locales,
            'timezone': timezone,
          })
          .select('id')
          .single();

      // Auto-create owner membership
      await supabase.from('site_members').insert({
        'site_id': response['id'],
        'profile_id': userId,
        'role': 'owner',
      });
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'createSite', 'owner_profile_id': userId},
      );
    }
  }

  /// Returns the primary domain for a site, or null if none is configured.
  Future<String?> fetchPrimaryDomain(String siteId) async {
    try {
      final response = await supabase
          .from('site_domains')
          .select('domain')
          .eq('site_id', siteId)
          .eq('is_primary', true)
          .maybeSingle();
      return response?['domain'] as String?;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchPrimaryDomain', 'siteId': siteId},
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Documents
  // ---------------------------------------------------------------------------

  Future<List<ContentDocument>> fetchSiteDocuments({
    required String siteId,
    String? locale,
    String? contentType,
  }) async {
    try {
      var query = supabase.from('cms_documents').select().eq('site_id', siteId);
      if (locale != null) {
        query = query.eq('locale', locale);
      }
      if (contentType != null) {
        query = query.eq('content_type', contentType);
      }
      final response = await query
          .order('content_type')
          .order('slug')
          .order('locale');
      return (response as List<dynamic>)
          .map((row) => ContentDocument.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchSiteDocuments', 'siteId': siteId},
      );
    }
  }

  Future<ContentDocument?> fetchDocument(String documentId) async {
    try {
      final response = await supabase
          .from('cms_documents')
          .select()
          .eq('id', documentId)
          .maybeSingle();
      if (response == null) return null;
      return ContentDocument.fromMap(response);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchDocument', 'documentId': documentId},
      );
    }
  }

  Future<void> updateDocumentContent({
    required String documentId,
    required Map<String, dynamic> content,
  }) async {
    try {
      await supabase
          .from('cms_documents')
          .update({
            'content': content,
            'updated_by': supabase.auth.currentUser?.id,
          })
          .eq('id', documentId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'updateDocumentContent', 'documentId': documentId},
      );
    }
  }

  Future<void> setDocumentStatus({
    required String documentId,
    required String status,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_by': supabase.auth.currentUser?.id,
      };
      if (status == 'published') {
        updates['published_at'] = DateTime.now().toUtc().toIso8601String();
      }
      await supabase.from('cms_documents').update(updates).eq('id', documentId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'setDocumentStatus', 'documentId': documentId},
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Save / Publish / Versions
  // ---------------------------------------------------------------------------

  /// Saves content into the document's draft layer.
  ///
  /// The live page is untouched: saving is not publishing, and it is not
  /// unpublishing either. Writing the draft into `content` and flipping the
  /// status is what used to take a published page offline mid-edit.
  Future<void> saveDocumentDraft({
    required String documentId,
    required Map<String, dynamic> content,
  }) async {
    try {
      await supabase
          .from('cms_documents')
          .update({
            'draft_content': content,
            'updated_by': supabase.auth.currentUser?.id,
          })
          .eq('id', documentId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'saveDocumentDraft', 'documentId': documentId},
      );
    }
  }

  /// Publishes a document: creates a version snapshot, then promotes the
  /// content and clears the draft layer. The version number is auto-incremented
  /// by a database trigger.
  Future<void> publishDocument({
    required String documentId,
    required Map<String, dynamic> content,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    try {
      // 1. Create version snapshot
      await supabase.from('cms_document_versions').insert({
        'document_id': documentId,
        'version': 0, // trigger auto-increments
        'content': content,
        'published_by': userId,
      });

      // 2. Set document to published
      await supabase
          .from('cms_documents')
          .update({
            'content': content,
            'draft_content': null,
            'status': 'published',
            'published_at': DateTime.now().toUtc().toIso8601String(),
            'updated_by': userId,
          })
          .eq('id', documentId);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'publishDocument', 'documentId': documentId},
      );
    }
  }

  /// Fetches all published versions for a document, newest first.
  Future<List<DocumentVersion>> fetchDocumentVersions(String documentId) async {
    try {
      final response = await supabase
          .from('cms_document_versions')
          .select()
          .eq('document_id', documentId)
          .order('version', ascending: false);
      return (response as List<dynamic>)
          .map((row) => DocumentVersion.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'fetchDocumentVersions', 'documentId': documentId},
      );
    }
  }
}
