#!/bin/sh
# jsr-biblatex 回帰テスト
#   使い方: sh tests/run-tests.sh
#   必要なもの: lualatex, biber, python3
#   biber の場所は環境変数 BIBER で指定できる（既定は PATH 上の biber）。
#   このリポジトリの jsr.bbx / jsr.cbx / lbx を、texmf にあるものより優先して読み込む。
#   テスト文書は guide（スタイルガイドの例文）と noextra（a、b の付く文献がない文書）。
set -u
cd "$(dirname "$0")"
REPO="$(cd .. && pwd)"
export TEXINPUTS="$REPO//:"

status=0
for name in guide noextra; do
  rm -f "$name".lines.txt "$name".aux "$name".bbl "$name".bcf "$name".run.xml
  lualatex -interaction=nonstopmode -halt-on-error "$name".tex >/dev/null 2>&1
  "${BIBER:-biber}" --quiet "$name" >"$name".biber.log 2>&1 || { echo "$name: biber failed"; cat "$name".biber.log; exit 2; }
  lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1
  lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1 || { echo "$name: lualatex failed (see tests/$name.log)"; exit 2; }
  [ -s "$name".lines.txt ] || { echo "$name: no output (see tests/$name.log)"; exit 2; }
  # LaTeX のエラー（nonstopmode では組版が最後まで進むので，ログで検出する）
  if grep -q '^!' "$name".log; then
    echo "$name: LaTeX error (see tests/$name.log)"; grep -m3 '^!' "$name".log; status=2; continue
  fi

  python3 normalize.py "$name".lines.txt >"$name".actual.txt
  python3 normalize.py "$name".expected.txt >"$name".expected.norm.txt

  if diff -u "$name".expected.norm.txt "$name".actual.txt >"$name".diff; then
    echo "OK: $name: all cases match"
  else
    missing=$(grep -c '^-[^-]' "$name".diff)
    extra=$(grep -c '^+[^+]' "$name".diff)
    echo "NG: $name: $missing expected line(s) not matched, $extra unexpected line(s) (see tests/$name.diff)"
    [ "$status" -eq 0 ] && status=1
  fi
done
[ "$status" -eq 0 ] && echo "OK: all cases match"
exit "$status"
