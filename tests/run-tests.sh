#!/bin/sh
# jsr-biblatex 回帰テスト
#   使い方: sh tests/run-tests.sh
#   必要なもの: lualatex, biber, python3
#   biber の場所は環境変数 BIBER で指定できる（既定は PATH 上の biber）。
#   このリポジトリの jsr.bbx / jsr.cbx / lbx を、texmf にあるものより優先して読み込む。
set -u
cd "$(dirname "$0")"
REPO="$(cd .. && pwd)"
export TEXINPUTS="$REPO//:"

name=guide
rm -f "$name".lines.txt "$name".aux "$name".bbl "$name".bcf "$name".run.xml
lualatex -interaction=nonstopmode -halt-on-error "$name".tex >/dev/null 2>&1
"${BIBER:-biber}" --quiet "$name" >"$name".biber.log 2>&1 || { echo "biber failed"; cat "$name".biber.log; exit 2; }
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1 || { echo "lualatex failed (see $name.log)"; exit 2; }

python3 normalize.py "$name".lines.txt >"$name".actual.txt
python3 normalize.py "$name".expected.txt >"$name".expected.norm.txt

if diff -u "$name".expected.norm.txt "$name".actual.txt >"$name".diff; then
  echo "OK: all cases match"
  exit 0
else
  fails=$(grep -c '^-[^-]' "$name".diff)
  echo "NG: $fails expected line(s) not matched (see tests/$name.diff)"
  exit 1
fi
