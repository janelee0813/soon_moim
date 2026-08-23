-- 점검 중 발견: image_paths가 빈 배열('{}')이면 array_length가 NULL이 되어
-- 기존 체크 제약(between 1 and 10)을 실제로는 통과해버리는 허점이 있어 보정
alter table sermon_notes drop constraint if exists sermon_notes_image_paths_check;
alter table sermon_notes add constraint sermon_notes_image_paths_check
  check (coalesce(array_length(image_paths, 1), 0) between 1 and 10);
