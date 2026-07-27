-- A document's draft gets its own column, so saving stops unpublishing the page.
--
-- Until now a document had one `content` column plus a status: saving a draft
-- wrote the new copy into `content` and flipped `status` to 'draft'. The public
-- site only reads `status = 'published'`, so pressing Save took the live page
-- offline until the owner published again — and the published copy was gone
-- from the row entirely (only recoverable from cms_document_versions).
--
-- `draft_content` holds work in progress; `content` keeps whatever is live.
-- Publishing promotes the draft into `content` and clears it. `status` now only
-- answers "has this document ever been published", not "is someone editing it".

-- Re-runnable: `make apply-migrations` replays every file in this directory.
ALTER TABLE public.cms_documents
    ADD COLUMN IF NOT EXISTS draft_content jsonb;

COMMENT ON COLUMN public.cms_documents.draft_content IS
    'Unpublished work in progress. Null when there is none. The public site '
    'never reads this; publishing moves it into content and clears it.';

COMMENT ON COLUMN public.cms_documents.content IS
    'The published content. Editing does not touch it — see draft_content.';

-- Existing 'draft' rows carry their unpublished copy in `content`. Move it to
-- `draft_content` and put the last published version back in `content`, so the
-- pages those rows took offline are live again with what was last published.
-- A row that was never published has no version to restore: it keeps its
-- content and stays 'draft', which is the truth about it. Rows that already
-- have a draft were converted by an earlier run and are left alone.
UPDATE public.cms_documents AS d
SET
    draft_content = d.content,
    content = COALESCE(
        (
            SELECT v.content
            FROM public.cms_document_versions AS v
            WHERE v.document_id = d.id
            ORDER BY v.version DESC
            LIMIT 1
        ),
        d.content
    ),
    status = CASE
        WHEN EXISTS (
            SELECT 1
            FROM public.cms_document_versions AS v
            WHERE v.document_id = d.id
        ) THEN 'published'
        ELSE 'draft'
    END,
    published_at = CASE
        WHEN EXISTS (
            SELECT 1
            FROM public.cms_document_versions AS v
            WHERE v.document_id = d.id
        ) THEN COALESCE(d.published_at, now())
        ELSE d.published_at
    END
WHERE d.status = 'draft'
  AND d.draft_content IS NULL;
