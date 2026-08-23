-- 조회수
alter table sermon_notes add column if not exists view_count integer not null default 0;

create or replace function increment_sermon_note_views(p_id bigint)
returns void
language sql
security definer
set search_path = public
as $$
  update sermon_notes set view_count = view_count + 1 where id = p_id;
$$;

grant execute on function increment_sermon_note_views(bigint) to anon;

-- 삭제 (관리자만 UI에서 노출, 다른 admin 기능들과 동일하게 서버는 열어둠)
create policy "말씀노트 삭제 허용" on sermon_notes for delete using (true);
create policy "말씀노트 이미지 삭제 허용" on storage.objects for delete using (bucket_id = 'sermon-notes');

-- 댓글
create table if not exists sermon_note_comments (
  id bigint generated always as identity primary key,
  note_id bigint not null references sermon_notes(id) on delete cascade,
  author_name text not null check (char_length(author_name) between 1 and 30),
  content text not null check (char_length(content) between 1 and 500),
  created_at timestamptz not null default now()
);

alter table sermon_note_comments enable row level security;

create policy "말씀노트 댓글 누구나 읽기" on sermon_note_comments for select using (true);
create policy "말씀노트 댓글 누구나 작성" on sermon_note_comments for insert with check (true);
