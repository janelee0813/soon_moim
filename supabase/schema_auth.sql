-- 순원 마스터 테이블 (로그인용 4자리 비밀번호 포함)
create table if not exists members (
  id bigint generated always as identity primary key,
  name text not null,
  pin text unique check (pin ~ '^[0-9]{4}$'),
  role text not null default 'member' check (role in ('leader','member')),
  gender text check (gender in ('M','F')),
  avatar_url text,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- pin을 제외한 공개 뷰 (명단 표시용, 누구나 조회 가능)
create or replace view members_public as
  select id, name, role, gender, avatar_url, sort_order from members order by sort_order;

alter table members enable row level security;
-- members 테이블 자체는 anon 직접 접근 차단 (pin 보호). 조회는 members_public 뷰로만.

grant select on members_public to anon;

-- 비밀번호로 로그인: pin이 일치하는 순원의 id/name/role만 반환 (pin 자체는 노출 안 함)
create or replace function login_with_pin(p_pin text)
returns table(id bigint, name text, role text)
language sql
security definer
set search_path = public
as $$
  select id, name, role from members where pin = p_pin;
$$;

grant execute on function login_with_pin(text) to anon;

-- 관리자(리더)가 순원 비밀번호를 설정. 요청자의 pin이 리더 계정인지 서버에서 확인 후 변경
create or replace function admin_set_pin(p_admin_pin text, p_member_id bigint, p_new_pin text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  is_admin boolean;
begin
  select exists(select 1 from members where pin = p_admin_pin and role = 'leader') into is_admin;
  if not is_admin then
    return false;
  end if;
  if p_new_pin !~ '^[0-9]{4}$' then
    return false;
  end if;
  update members set pin = p_new_pin where id = p_member_id;
  return true;
end;
$$;

grant execute on function admin_set_pin(text, bigint, text) to anon;

-- 출석 (주일 단위, 순원별 1행)
create table if not exists attendance (
  id bigint generated always as identity primary key,
  member_id bigint not null references members(id) on delete cascade,
  service_date date not null,
  sunday_worship text not null default 'absent' check (sunday_worship in ('present','absent')),
  online_worship boolean not null default false,
  department_meeting text not null default 'absent' check (department_meeting in ('present','absent')),
  soon_meeting text not null default 'absent' check (soon_meeting in ('present','absent')),
  updated_at timestamptz not null default now(),
  unique (member_id, service_date)
);

-- 특이사항 (member_id가 null이면 순 전체 특이사항)
create table if not exists special_notes (
  id bigint generated always as identity primary key,
  member_id bigint references members(id) on delete cascade,
  note_date date not null default current_date,
  content text not null check (char_length(content) between 1 and 2000),
  created_at timestamptz not null default now()
);

-- 기도제목 (순원별 최신 1건을 업데이트하는 방식)
create table if not exists prayer_requests (
  member_id bigint primary key references members(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 1000),
  updated_at timestamptz not null default now()
);

alter table attendance enable row level security;
alter table special_notes enable row level security;
alter table prayer_requests enable row level security;

create policy "출석 누구나 읽기" on attendance for select using (true);
create policy "출석 누구나 기록" on attendance for insert with check (true);
create policy "출석 누구나 수정" on attendance for update using (true);

create policy "특이사항 누구나 읽기" on special_notes for select using (true);
create policy "특이사항 누구나 기록" on special_notes for insert with check (true);

create policy "기도제목 누구나 읽기" on prayer_requests for select using (true);
create policy "기도제목 누구나 기록" on prayer_requests for insert with check (true);
create policy "기도제목 누구나 수정" on prayer_requests for update using (true);

-- 순원 명단 시드 (이종환: 순장/관리자, 비밀번호 6523)
insert into members (name, pin, role, gender, avatar_url, sort_order) values
  ('이종환', '6523', 'leader', 'M', 'assets/members/leader.png', 0),
  ('권은주', null, 'member', 'F', null, 1),
  ('김경민', null, 'member', 'F', null, 2),
  ('김민지', null, 'member', 'F', null, 3),
  ('김상미', null, 'member', 'F', null, 4),
  ('김원태', null, 'member', 'M', null, 5),
  ('윤주혜', null, 'member', 'F', null, 6),
  ('이은빈', null, 'member', 'F', null, 7),
  ('홍영민', null, 'member', 'F', null, 8),
  ('이수정', null, 'member', 'F', null, 9),
  ('이화진', null, 'member', 'F', null, 10),
  ('김효진', null, 'member', 'F', null, 11)
on conflict do nothing;
