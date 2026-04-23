-- HU-6: Soporte de foto de mascotas (bucket pet-photos)

insert into storage.buckets (id, name, public)
values ('pet-photos', 'pet-photos', true)
on conflict (id) do nothing;

drop policy if exists pet_photos_public_read on storage.objects;
create policy pet_photos_public_read
on storage.objects
for select
using (bucket_id = 'pet-photos');

drop policy if exists pet_photos_insert_own on storage.objects;
create policy pet_photos_insert_own
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'pet-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists pet_photos_update_own on storage.objects;
create policy pet_photos_update_own
on storage.objects
for update
to authenticated
using (
  bucket_id = 'pet-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'pet-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists pet_photos_delete_own on storage.objects;
create policy pet_photos_delete_own
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'pet-photos'
  and auth.uid()::text = (storage.foldername(name))[1]
);
