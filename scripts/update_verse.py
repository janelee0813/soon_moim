import json
import re
import sys
import urllib.request
from datetime import datetime, timezone, timedelta

KST = timezone(timedelta(hours=9))
BASE_URL = "https://www.woorichurch.org/modu/ov/ov_meditation.asp"


def fetch_html(date_str):
    url = f"{BASE_URL}?ov_date={date_str}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=20) as res:
        return res.read().decode("utf-8", errors="replace")


def parse_verse(html_src):
    import html as html_mod

    ref_m = re.search(r"오늘의 한 구절\s*:\s*(.*?)</p>", html_src)
    if not ref_m:
        return None
    reference = html_mod.unescape(ref_m.group(1)).strip()

    block_m = re.search(
        r'<h4 class="tit">오늘의 한 구절</h4>\s*<div class="cont"[^>]*>(.*?)</div>',
        html_src,
        re.S,
    )
    if not block_m:
        return None

    v_m = re.search(
        r"\[개역개정\]\s*<br\s*/?>(.*?)<br\s*/?>\s*<br\s*/?>\s*\[",
        block_m.group(1),
        re.S,
    )
    if not v_m:
        return None

    raw = re.sub(r"<br\s*/?>", " ", v_m.group(1))
    raw = re.sub(r"\s+", " ", raw).strip()
    text = html_mod.unescape(raw)

    if not reference or not text:
        return None

    return reference, text


def main():
    today = datetime.now(KST).strftime("%Y-%m-%d")

    try:
        src = fetch_html(today)
    except Exception as e:
        print(f"페이지 요청 실패: {e}", file=sys.stderr)
        sys.exit(1)

    parsed = parse_verse(src)
    if parsed is None:
        print("한 구절 파싱 실패 (페이지 구조 변경 가능성)", file=sys.stderr)
        sys.exit(1)

    reference, text = parsed

    data = {
        "date": today,
        "reference": reference,
        "text": text,
        "sourceUrl": f"{BASE_URL}?ov_date={today}",
        "fetchedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    }

    with open("data/verse.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

    print(f"업데이트 완료: {reference} / {text}")


if __name__ == "__main__":
    main()
