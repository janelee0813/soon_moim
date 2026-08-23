-- 출석체크 시 아무것도 선택하지 않은 상태(미체크)를 허용하도록 변경
-- (방학 등으로 특정 주/항목을 체크하지 않는 경우, 기본값이 '불참'으로 잡히던 문제 수정)
alter table attendance
  alter column sunday_worship drop not null,
  alter column sunday_worship drop default,
  alter column department_meeting drop not null,
  alter column department_meeting drop default,
  alter column soon_meeting drop not null,
  alter column soon_meeting drop default;
