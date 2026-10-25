#!/usr/bin/env python3
"""組版の確認（layout テスト）：問題のある行があれば出力して 1 で終わる。
  1. 「== BIBLIOGRAPHY ==」（空白は無視）より後に，文字のない行（空の項目）がある
  2. 「，」の直後の空白（グルーの合計）が 0.5 全角（5pt）を超える。和文の読点の後に入る約物間グルーは
     0.5 全角までで，それを超えるのは通常の空白が余計に入っているとき（「————， 2014」）
  3. 期待値（引数の 2 番目のファイル。グルーを除いた文字列で比べる）にない文献リストの行がある，
     または期待値の行が出力にない"""
import re
import sys

ZW = 10.0            # 本文の全角幅（pt）
lines = [l.rstrip("\n") for l in open(sys.argv[1], encoding="utf-8")]
expected = [l.rstrip("\n") for l in open(sys.argv[2], encoding="utf-8")
            if l.strip() and not l.startswith("#")]
bad = []

try:
    start = next(i for i, l in enumerate(lines) if re.sub(r"<[^>]*>", "", l) == "==BIBLIOGRAPHY==")
except StopIteration:
    print("layout: no bibliography")
    sys.exit(2)

body = lines[start + 1:]
for i, l in enumerate(body, 1):
    if l == "<empty>":
        bad.append(f"文献リストに空の項目: {i} 番目の行")
    for m in re.finditer(r"，((?:<-?[\d.]+>)+)", l):
        w = sum(float(x) for x in re.findall(r"<(-?[\d.]+)>", m.group(1)))
        if w > 0.5 * ZW + 0.01:
            bad.append(f"「，」の後の空白が広すぎる（{w:.1f}pt）: {i} 番目の行: {re.sub(r'<[^>]*>', '', l)[:50]}")

# 文献注と文献リストの行（グルーを除いた文字列）が期待値と一致するか
plain = [re.sub(r"<[^>]*>", "", l) for l in lines]
for e in expected:
    if e not in plain:
        bad.append(f"期待する行がない: {e}")
# 期待値にない文献リストの行（署名のない記事が混ざる，など）
exp_bib = [e for e in expected if not re.match(r"C\d\d ", e)]
for p in plain[start + 1:]:
    if p and p not in exp_bib:
        bad.append(f"期待値にない文献リストの行: {p}")

for b in bad:
    print(b)
sys.exit(1 if bad else 0)
