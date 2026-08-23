// ---- 세션 (비밀번호 기반 로그인, 로그인 정보는 localStorage에 보관) ----
var AUTH_KEY = 'soon_moim_session';

function getSession() {
  try {
    var raw = localStorage.getItem(AUTH_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch (e) {
    return null;
  }
}

function setSession(session) {
  localStorage.setItem(AUTH_KEY, JSON.stringify(session));
}

function clearSession() {
  localStorage.removeItem(AUTH_KEY);
}

function requireLogin() {
  var s = getSession();
  if (!s) {
    window.location.href = 'login';
    return null;
  }
  return s;
}

function requireLeader() {
  var s = requireLogin();
  if (s && s.role !== 'leader') {
    window.location.href = 'mypage';
    return null;
  }
  return s;
}

function mountAuthNav() {
  var el = document.getElementById('nav-auth');
  if (!el) return;
  var s = getSession();

  if (!s) {
    el.innerHTML = '<a href="login" class="nav-link">로그인</a>';
    return;
  }

  var html = '';
  if (s.role === 'leader') {
    html += '<a href="admin" class="nav-link">관리자</a>';
  }
  html += '<a href="mypage" class="nav-link">' + escapeHtml(s.name) + '님</a>';
  html += '<button type="button" id="logout-btn" class="nav-link">로그아웃</button>';
  el.innerHTML = html;

  var btn = document.getElementById('logout-btn');
  if (btn) {
    btn.addEventListener('click', function () {
      clearSession();
      window.location.href = 'index';
    });
  }
}

// ---- 공용 유틸 ----
function escapeHtml(str) {
  var div = document.createElement('div');
  div.textContent = str == null ? '' : String(str);
  return div.innerHTML;
}

function formatDate(iso) {
  var d = new Date(iso);
  var y = d.getFullYear();
  var m = String(d.getMonth() + 1).padStart(2, '0');
  var day = String(d.getDate()).padStart(2, '0');
  return y + '.' + m + '.' + day;
}

var KST_OFFSET_MS = 9 * 60 * 60 * 1000;

function getKstToday() {
  var kst = new Date(Date.now() + KST_OFFSET_MS);
  return { y: kst.getUTCFullYear(), m: kst.getUTCMonth(), d: kst.getUTCDate() };
}

// 이번 주(오늘 포함, 가장 최근이었거나 다가올) 주일 날짜를 'YYYY-MM-DD'로 반환
function getRecentSundayString() {
  var t = getKstToday();
  var base = new Date(Date.UTC(t.y, t.m, t.d));
  var day = base.getUTCDay(); // 0 = 일요일
  base.setUTCDate(base.getUTCDate() - day);
  var y = base.getUTCFullYear();
  var m = String(base.getUTCMonth() + 1).padStart(2, '0');
  var d = String(base.getUTCDate()).padStart(2, '0');
  return y + '-' + m + '-' + d;
}

// ---- 아바타 생성 (personas 스타일, 성별 참고) ----
var AVATAR_BG = 'f9e7cb';
var FEMALE_HAIR = ['long', 'bobCut', 'curly', 'pigtails', 'curlyBun', 'bobBangs', 'straightBun', 'extraLong', 'curlyHighTop'];
var MALE_HAIR = ['shortCombover', 'buzzcut', 'fade', 'cap', 'beanie', 'sideShave', 'shortComboverChops', 'balding'];

function personaAvatarUrl(seed, gender) {
  var hairSet = gender === 'M' ? MALE_HAIR : FEMALE_HAIR;
  var facialHairProbability = gender === 'M' ? 25 : 0;
  var params = 'seed=' + encodeURIComponent(seed) +
    '&backgroundColor=' + AVATAR_BG +
    '&facialHairProbability=' + facialHairProbability;
  hairSet.forEach(function (h) { params += '&hair=' + h; });
  return 'https://api.dicebear.com/7.x/personas/svg?' + params;
}

function memberAvatarUrl(member) {
  return member.avatar_url ? member.avatar_url : personaAvatarUrl(member.name + member.id, member.gender);
}

// ---- 기도제목 모아보기 (순원 마이페이지 / 관리자 페이지 공용) ----
function renderPrayerList(containerEl, members, prayers) {
  var byMember = {};
  prayers.forEach(function (p) { byMember[p.member_id] = p; });

  var html = members.map(function (m) {
    var p = byMember[m.id];
    return '<div class="flex gap-3 border-t border-border/60 pt-3 mt-3 first:mt-0 first:border-0 first:pt-0">' +
      '<img src="' + memberAvatarUrl(m) + '" alt="' + escapeHtml(m.name) + '" class="h-9 w-9 shrink-0 rounded-full object-cover" />' +
      '<div class="min-w-0 flex-1">' +
        '<div class="flex items-baseline justify-between gap-2">' +
          '<span class="text-sm font-semibold text-foreground/90">' + escapeHtml(m.name) + '</span>' +
          (p ? '<span class="shrink-0 text-[11px] text-muted-foreground">' + formatDate(p.updated_at) + '</span>' : '') +
        '</div>' +
        '<p class="mt-1 whitespace-pre-wrap text-sm leading-relaxed text-foreground/80">' +
          (p ? escapeHtml(p.content) : '<span class="text-muted-foreground">아직 등록된 기도제목이 없어요.</span>') +
        '</p>' +
      '</div>' +
    '</div>';
  }).join('');

  containerEl.innerHTML = html || '<p class="text-sm text-muted-foreground">순원 명단이 없습니다.</p>';
}

function loadAndRenderPrayerList(containerEl) {
  return Promise.all([
    sb.from('members_public').select('*'),
    sb.from('prayer_requests').select('*')
  ]).then(function (results) {
    var members = results[0].data || [];
    var prayers = results[1].data || [];
    renderPrayerList(containerEl, members, prayers);
  });
}

document.addEventListener('DOMContentLoaded', mountAuthNav);
