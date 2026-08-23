-- 공지 게시글 작성자 저장 및 로그인한 사람 누구나 글쓰기 허용
alter table notice_posts add column if not exists member_id bigint references members(id);

create policy "공지 로그인한 사람 작성" on notice_posts for insert with check (true);
