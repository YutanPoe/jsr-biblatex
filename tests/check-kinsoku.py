#!/usr/bin/env python3
"""禁則の確認：行頭に閉じ括弧・句読点、行末に開き括弧が来る行があれば、その行を出力して 1 で終わる。"""
import sys

HEAD = "）」』〕］｝〉》】，．、。：；？！"   # 行頭に来てはならない
TAIL = "（「『〔［｛〈《【"                 # 行末に来てはならない

bad = []
n = 0
for no, line in enumerate(open(sys.argv[1], encoding="utf-8"), 1):
    line = line.rstrip("\n").strip()
    if not line:
        continue
    n += 1
    if line[0] in HEAD:
        bad.append((no, "行頭", line))
    if line[-1] in TAIL:
        bad.append((no, "行末", line))
if n == 0:
    print("kinsoku: no lines to check")
    sys.exit(2)
for no, kind, line in bad:
    print(f"{kind}に禁則文字: {no} 行目: {line[:60]}")
sys.exit(1 if bad else 0)
