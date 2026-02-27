import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class ContentDocumentsPage extends StatefulWidget {
  const ContentDocumentsPage({super.key});

  @override
  State<ContentDocumentsPage> createState() => _ContentDocumentsPageState();
}

class _ContentDocumentsPageState extends State<ContentDocumentsPage> {
  late Future<List<ContentDocument>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    final repo = context.read<CmsRepository>();
    // Fetch all documents without a site filter – this page is unused in the
    // current router but kept for backwards compatibility.
    _documentsFuture = repo.fetchSiteDocuments(siteId: '');
  }

  @override
  Widget build(BuildContext context) {
    return ConsolePageScaffold(
      title: context.s.contentDocumentsTitle,
      description: context.s.contentDocumentsDescription,
      leftChild: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _buildDocumentList(),
      ),
    );
  }

  Widget _buildDocumentList() {
    return FutureBuilder<List<ContentDocument>>(
      future: _documentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              context.s.contentDocumentsLoadFailed(snapshot.error.toString()),
            ),
          );
        }
        final documents = snapshot.data ?? [];
        if (documents.isEmpty) {
          return Center(child: Text(context.s.contentDocumentsEmpty));
        }
        return ListView.separated(
          itemCount: documents.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = documents[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(doc.locale.toUpperCase()),
              ),
              title: Text('${doc.contentType} / ${doc.slug}'),
              subtitle: Text(
                context.s.contentDocumentsUpdated(
                  doc.status,
                  doc.updatedAt.toLocal().toString(),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: doc.publishedAt == null
                  ? null
                  : Text(
                      context.s.contentDocumentsPublished(
                        doc.publishedAt!.toLocal().toString(),
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
