-- 공지 게시글
create table if not exists notice_posts (
  id bigint generated always as identity primary key,
  title text not null check (char_length(title) between 1 and 200),
  content text not null check (char_length(content) between 1 and 5000),
  created_at timestamptz not null default now()
);

-- 댓글 (로그인 없이 이름만 입력해서 작성)
create table if not exists notice_comments (
  id bigint generated always as identity primary key,
  post_id bigint not null references notice_posts(id) on delete cascade,
  author_name text not null check (char_length(author_name) between 1 and 30),
  content text not null check (char_length(content) between 1 and 500),
  created_at timestamptz not null default now()
);

-- 좋아요 (브라우저별 익명 visitor_id로 중복 방지)
create table if not exists notice_likes (
  id bigint generated always as identity primary key,
  post_id bigint not null references notice_posts(id) on delete cascade,
  visitor_id text not null check (char_length(visitor_id) between 8 and 100),
  created_at timestamptz not null default now(),
  unique (post_id, visitor_id)
);

alter table notice_posts enable row level security;
alter table notice_comments enable row level security;
alter table notice_likes enable row level security;

create policy "공지 누구나 읽기" on notice_posts for select using (true);

create policy "댓글 누구나 읽기" on notice_comments for select using (true);
create policy "댓글 누구나 작성" on notice_comments for insert with check (true);

create policy "좋아요 누구나 읽기" on notice_likes for select using (true);
create policy "좋아요 누구나 추가" on notice_likes for insert with check (true);
create policy "좋아요 누구나 취소" on notice_likes for delete using (true);

-- 예시 공지
insert into notice_posts (title, content) values
  ('첫 공지입니다', '이종환 순 홈페이지에 오신 것을 환영합니다! 이 게시판에서 댓글과 좋아요를 남겨보세요.');
