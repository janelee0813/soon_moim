-- 공지 삭제 (관리자만 UI에서 노출, 다른 admin 기능들과 동일하게 서버는 열어둠)
create policy "공지 삭제 허용" on notice_posts for delete using (true);
