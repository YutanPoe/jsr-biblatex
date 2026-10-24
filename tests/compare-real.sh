#!/bin/sh
# jsr-biblatex 実データの変更前後比較
#   使い方: sh tests/compare-real.sh [REV]
#   ../test.tex を、REV（既定 HEAD）のスタイルと作業コピーのスタイルで組み、
#   組版された各行の文字列（textdump.lua）を比べる。差分は tests/real.diff に出る（< が REV、> が作業コピー）。
#   必要なもの: lualatex, biber（環境変数 BIBER で場所を指定できる）, git
#   pdftotext は使わない。行単位の比較なので、改行位置が変わると後続の行も差分に出る。
set -u
cd "$(dirname "$0")"
TESTS="$(pwd)"
REPO="$(cd .. && pwd)"
SRC="$(cd ../.. && pwd)"   # test.tex、preamble/、bib/ のある親フォルダ
REV="${1:-HEAD}"
WORK="$(mktemp -d)"
FILES="jsr.bbx jsr.cbx jsr.dbx lbx"

mkdir "$WORK/old-style" "$WORK/new-style"
(cd "$REPO" && git archive "$REV" $FILES) | tar -x -C "$WORK/old-style" || { echo "git archive failed ($REV)"; exit 2; }
(cd "$REPO" && cp -R $FILES "$WORK/new-style/")

build() {  # $1 = old | new
  dir="$WORK/$1"
  mkdir "$dir"
  cp -R "$SRC/preamble" "$SRC/bib" "$dir/"
  # textdump.lua は luatexbase を使うので，\documentclass より後（\begin{document} の直前）で読み込む
  sed "s|^\\\\begin{document}|\\\\directlua{dofile('$TESTS/textdump.lua')}\\\\begin{document}|" "$SRC/test.tex" >"$dir/test.tex"
  grep -q textdump "$dir/test.tex" || { echo "test.tex に \\begin{document} が見つからない"; exit 2; }
  (
    cd "$dir" || exit 2
    export TEXINPUTS="$WORK/$1-style//:"
    lualatex -interaction=nonstopmode test.tex >/dev/null 2>&1
    "${BIBER:-biber}" --quiet test >biber.log 2>&1 || { echo "biber failed ($1): $dir/biber.log"; exit 2; }
    lualatex -interaction=nonstopmode test.tex >/dev/null 2>&1
    lualatex -interaction=nonstopmode test.tex >/dev/null 2>&1
    [ -s test.lines.txt ] || { echo "lualatex failed ($1): $dir/test.log"; exit 2; }
  ) || exit 2
}

build old || exit 2
build new || exit 2

if diff "$WORK/old/test.lines.txt" "$WORK/new/test.lines.txt" >real.diff; then
  echo "差分なし（$REV と作業コピー）"
  rm -rf "$WORK"
  exit 0
else
  n=$(grep -c '^[<>]' real.diff)
  echo "差分 $n 行（$REV と作業コピー。tests/real.diff）  作業ディレクトリ: $WORK"
  exit 1
fi
