#!/usr/bin/env python3
"""マニュアルの検収の自動確認。

使い方: python3 check.py <jobname>   （<jobname>.log と <jobname>.pdf を読む）
確認する項目:
  1. LaTeX のエラーがない
  2. Overfull \\hbox が 1pt を超えない
  3. 版面が左右対称（奇数ページと偶数ページの余白が等しく，左右の余白の差が 1pt 以内）
  4. 内容が紙の端から 10mm 以上内側にある（左右とも。余白の項目名を含む）
  5. 目次・しおり・リンクがある
  6. フォントがすべて埋め込まれている
"""
import re
import sys

MM = 72.27 / 25.4   # 1mm = 2.845pt（TeX のポイント）
name = sys.argv[1]
log = open(name + ".log", encoding="utf-8", errors="ignore").read()
pdf = open(name + ".pdf", "rb").read().decode("latin-1")

fails = []
def check(ok, label, detail=""):
    print(("OK: " if ok else "NG: ") + label + (" " + detail if detail and not ok else ""))
    if not ok:
        fails.append(label)

# 1. エラー
errs = re.findall(r"^!.*$", log, re.M)
check(not errs, "LaTeX のエラー 0", "; ".join(errs[:3]))

# 2. Overfull
over = [(float(m.group(1)), m.group(0)) for m in re.finditer(r"Overfull \\hbox \(([0-9.]+)pt too wide\)[^\n]*", log)]
big = [t for v, t in over if v > 1.0]
check(not big, "Overfull \\hbox は 1pt 以下（全 %d 件）" % len(over), "; ".join(big[:3]))

# 3. 左右対称
geo = re.findall(r"JSRGEO paperwidth=([0-9.\-]+) textwidth=([0-9.\-]+) oddside=([0-9.\-]+) evenside=([0-9.\-]+) marglistwidth=([0-9.\-]+)", log)
if not geo:
    check(False, "版面の情報（JSRGEO）がログにある")
    paper = text = odd = even = None
else:
    paper, text, odd, even, mw = map(float, geo[-1])
    right = paper - text - odd
    check(abs(odd - even) <= 1.0, "奇数ページと偶数ページの左余白が等しい（左 %.1fpt／%.1fpt）" % (odd, even))
    check(abs(odd - right) <= 1.0, "左右の余白が等しい（左 %.1fpt，右 %.1fpt）" % (odd, right))

# 4. 紙の端から 10mm
pages = [(int(a), float(b), float(c)) for a, b, c in re.findall(r"JSRCHK page=(\d+) xmin=([0-9.\-]+) xmax=([0-9.\-]+)", log)]
if not pages:
    check(False, "ページごとの内容の範囲（JSRCHK）がログにある")
elif paper is not None:
    # 同じページの記録が複数あるときは最後のもの
    last = {}
    for p, a, b in pages:
        last[p] = (a, b)
    lim = 10 * MM
    bad = ["p.%d (左 %.1fpt, 右 %.1fpt)" % (p, a, paper - b) for p, (a, b) in sorted(last.items()) if a < lim - 0.01 or paper - b < lim - 0.01]
    check(not bad, "内容が紙の端から 10mm 以上内側（全 %d ページ。最小の左 %.1fmm，右 %.1fmm）" % (
        len(last), min(a for a, b in last.values()) / MM, min(paper - b for a, b in last.values()) / MM), "; ".join(bad[:5]))

# 4b. 原稿の検査：\cmditem の行の後ろに説明が続かない（説明は空行のあとの別の段落にする）
import glob
bad = []
for path in ["%s.tex" % name] + sorted(glob.glob("chapters/*.tex")):
    for no, line in enumerate(open(path, encoding="utf-8"), 1):
        m = re.match(r"\s*\\cmditem\{[^{}]*\}((?:\[[^\]]*\])*)((?:\{[^{}]*\})*)(.*)$", line)
        if m and m.group(3).strip() and not m.group(3).strip().startswith("%"):
            bad.append("%s:%d" % (path, no))
check(not bad, "\\cmditem の行の後ろに文字が続かない", ", ".join(bad[:5]))

# 4c. 段落頭の字下げがない
ind = re.findall(r"JSRGEO .*? parindent=([0-9.\-]+)", log)
check(bool(ind) and abs(float(ind[-1])) < 0.01, "段落頭の字下げがない（\\parindent=%spt）" % (ind[-1] if ind else "?"))

# 4d. 例の抜き出しに失敗したキーがない
miss = re.findall(r"JSRERR example key not found: (\S+)", log)
check(not miss, "例のキーがすべて見つかる", ", ".join(miss))

# 5. 目次・しおり・リンク
check("/Type /Outlines" in pdf, "しおり（Outlines）がある")
links = len(re.findall(r"/Subtype /Link", pdf))
check(links > 0, "リンク注釈がある（%d 件）" % links)
toc = log.count("\\contentsline") if "\\contentsline" in log else None
check(open(name + ".toc", encoding="utf-8", errors="ignore").read().count("\\contentsline") > 0, "目次（.toc）がある")

# 6. フォントの埋め込み
descs = re.findall(r"/Type /FontDescriptor.*?>>", pdf, re.S)
noemb = [d for d in descs if "/FontFile" not in d]
check(descs and not noemb, "フォントがすべて埋め込まれている（%d 件）" % len(descs), "%d 件が埋め込まれていない" % len(noemb))

print("検収: %s" % ("すべて合格" if not fails else "不合格 %d 件" % len(fails)))
sys.exit(1 if fails else 0)
