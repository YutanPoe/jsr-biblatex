#!/bin/sh
# jsr-biblatex 回帰テスト
#   使い方: sh tests/run-tests.sh
#   必要なもの: lualatex, biber, python3
#   biber の場所は環境変数 BIBER で指定できる（既定は PATH 上の biber）。
#   このリポジトリの jsr.bbx / jsr.cbx / lbx を、texmf にあるものより優先して読み込む。
#   テスト文書は dash（同一著者のダッシュ），guide（スタイルガイドの例文）、noextra（a、b の付く文献がない文書）、doi（オプション doi=true）、kinsoku（禁則）、layout（空白の幅・空の項目）。
set -u
cd "$(dirname "$0")"
REPO="$(cd .. && pwd)"
export TEXINPUTS="$REPO//:"
# ログの折り返しで警告の照合が失敗しないよう，1 行の長さを広げる
export max_print_line=10000

status=0
for name in guide noextra doi dash; do
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

# 禁則の確認（行頭に閉じ括弧・句読点，行末に開き括弧が来る行がない）
name=kinsoku
rm -f "$name".lines.txt "$name".aux "$name".bbl "$name".bcf "$name".run.xml
lualatex -interaction=nonstopmode -halt-on-error "$name".tex >/dev/null 2>&1
"${BIBER:-biber}" --quiet "$name" >"$name".biber.log 2>&1 || { echo "$name: biber failed"; cat "$name".biber.log; exit 2; }
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1 || { echo "$name: lualatex failed (see tests/$name.log)"; exit 2; }
if python3 check-kinsoku.py "$name".lines.txt >"$name".diff; then
  echo "OK: $name: no kinsoku violations"
else
  echo "NG: $name: kinsoku violations (see tests/$name.diff)"; head -3 "$name".diff
  [ "$status" -eq 0 ] && status=1
fi

# 組版の確認（「，」の直後の空白の幅，文献リストの空の項目，署名のない記事。文字の比較では見えないもの）
name=layout
rm -f "$name".layout.txt "$name".aux "$name".bbl "$name".bcf "$name".run.xml
lualatex -interaction=nonstopmode -halt-on-error "$name".tex >/dev/null 2>&1
"${BIBER:-biber}" --quiet "$name" >"$name".biber.log 2>&1 || { echo "$name: biber failed"; cat "$name".biber.log; exit 2; }
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1 || { echo "$name: lualatex failed (see tests/$name.log)"; exit 2; }
if python3 check-layout.py "$name".layout.txt "$name".expected.txt >"$name".diff; then
  echo "OK: $name: no layout problems"
else
  echo "NG: $name: layout problems (see tests/$name.diff)"; head -3 "$name".diff
  [ "$status" -eq 0 ] && status=1
fi

# 警告の確認（layout.log に出るべき警告と，出てはいけない警告。bbx の警告は biblatex の Warning として出る）
#   layout.warnings.expected は「出るべき行（部分一致）」，先頭が ! の行は「出てはいけない行」
if [ -f "$name".warnings.expected ]; then
  warn_ng=0
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    case "$pat" in
      '!'*) if grep -qF -- "${pat#!}" "$name".log; then echo "NG: $name: unexpected warning: ${pat#!}"; warn_ng=1; fi ;;
      *)    if ! grep -qF -- "$pat" "$name".log; then echo "NG: $name: missing warning: $pat"; warn_ng=1; fi ;;
    esac
  done <"$name".warnings.expected
  if [ "$warn_ng" -eq 0 ]; then echo "OK: $name: warnings as expected"; else [ "$status" -eq 0 ] && status=1; fi
fi

[ "$status" -eq 0 ] && echo "OK: all cases match"
exit "$status"
