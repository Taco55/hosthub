-- INSERT
create policy "Authenticated users may upload to their lists"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'uploads'
  AND exists (
    select 1 from public.list_access
    where list_access.profile_id = auth.uid()
    and list_access.list_id = (storage.foldername(name))[1]::uuid
  )
);

-- SELECT
create policy "Authenticated users may view files from lists they have access to"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'uploads'
  AND exists (
    select 1 from public.list_access
    where list_access.profile_id = auth.uid()
    and list_access.list_id = (storage.foldername(name))[1]::uuid
  )
);

-- DELETE
create policy "Authenticated users may delete files from lists they have access to"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'uploads'
  AND exists (
    select 1 from public.list_access
    where list_access.profile_id = auth.uid()
    and list_access.list_id = (storage.foldername(name))[1]::uuid
  )
);