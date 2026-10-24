#!/bin/sh
# jsr-biblatex マニュアルの組版と検査
#   使い方: sh manual/build.sh
#   必要なもの: lualatex, biber（環境変数 BIBER で場所を指定できる）, python3
#   TeX のパッケージ: ltxdockit, listings, zref, libertinus-otf, libertinus-fonts（juliamono は任意。なければ Latin Modern Mono）
#   このリポジトリの jsr.bbx / jsr.cbx / jsr.dbx / lbx を、texmf にあるものより優先して読み込む。
set -u
cd "$(dirname "$0")"
REPO="$(cd .. && pwd)"
export TEXINPUTS="$REPO//:"
# ログの折り返し（既定は 79 字。TeX Live 2023 は JSRGEO などの行が割れる）で check.py が読み違えないように，折り返さない
export max_print_line=100000
name=jsr-biblatex

# 足りないパッケージ・フォントの検出
missing=""
for f in btxdockit.sty ltxdockit.sty listings.sty zref-xr.sty libertinus-otf.sty; do
  kpsewhich "$f" >/dev/null 2>&1 || missing="$missing $f"
done
kpsewhich -format="opentype fonts" LibertinusSerif-Regular.otf >/dev/null 2>&1 || missing="$missing LibertinusSerif-Regular.otf"
if [ -n "$missing" ]; then
  echo "足りないファイル:$missing"
  echo "次のコマンドで入れてください:"
  echo "  tlmgr install ltxdockit listings zref libertinus-otf libertinus-fonts juliamono"
  exit 2
fi
kpsewhich JuliaMono-Regular.ttf >/dev/null 2>&1 || echo "注意: JuliaMono が見つかりません（Latin Modern Mono で組みます。tlmgr install juliamono）"

lualatex -interaction=nonstopmode -halt-on-error "$name".tex >/dev/null 2>&1 || { echo "lualatex failed (see manual/$name.log)"; grep -m3 -A4 '^!' "$name".log; exit 2; }
"${BIBER:-biber}" --quiet "$name" >"$name".biber.log 2>&1 || { echo "biber failed"; cat "$name".biber.log; exit 2; }
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1
lualatex -interaction=nonstopmode "$name".tex >/dev/null 2>&1 || { echo "lualatex failed (see manual/$name.log)"; exit 2; }

python3 check.py "$name"
