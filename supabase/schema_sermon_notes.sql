-- 말씀노트 이미지 저장용 공개 버킷
insert into storage.buckets (id, name, public)
values ('sermon-notes', 'sermon-notes', true)
on conflict (id) do nothing;

create policy "말씀노트 이미지 업로드 허용" on storage.objects
  for insert with check (bucket_id = 'sermon-notes');

-- 말씀노트 게시글 (이미지 경로를 배열로 저장)
create table if not exists sermon_notes (
  id bigint generated always as identity primary key,
  member_id bigint references members(id),
  title text not null check (char_length(title) between 1 and 200),
  caption text check (char_length(caption) <= 2000),
  image_paths text[] not null check (array_length(image_paths, 1) between 1 and 10),
  created_at timestamptz not null default now()
);

alter table sermon_notes enable row level security;

create policy "말씀노트 누구나 읽기" on sermon_notes for select using (true);
create policy "말씀노트 로그인한 사람 작성" on sermon_notes for insert with check (true);
