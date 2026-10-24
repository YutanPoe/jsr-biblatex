# jsr-biblatex

A biblatex style (`style=jsr`) for the *Shakaigaku Hyoron Style Guide* (3rd ed.), the style guide of the Japan Sociological Society's journal. It typesets author-year citations and reference lists for mixed Japanese and English bibliographies. It is a modified version of [biblatex-jpa](https://github.com/sbtseiji/biblatex-jpa) by Seiji Shibata (LPPL 1.3 or later). Requires LuaLaTeX (or XeLaTeX/upLaTeX), biblatex 3.19+ and biber 2.19+. The manual is in Japanese: [`manual/jsr-biblatex.pdf`](manual/jsr-biblatex.pdf).

社会学評論スタイルガイド（第3版）に準拠した biblatex スタイルです。和文と欧文の文献が混ざった文献リストと、割注の文献注（（著者名 出版年））を、スタイルガイドの書式で組みます。

> このスタイルは、スタイルガイドにそって個人が作成したものであり、日本社会学会が作成・配布するものではありません。このスタイルについて日本社会学会に問い合わせることのないようにしてください。また、できるかぎりスタイルガイドにそうように作成していますが、出力がそのまま受理されることを保証するものではありません。

## マニュアル

**[manual/jsr-biblatex.pdf](manual/jsr-biblatex.pdf)** に、使い方のすべてを書いています（bib の書き方、エントリ型ごとの書式と出力例、引用コマンド、オプション、スタイルガイドとの対応表、旧い書き方からの移行）。この README は入口だけです。

## インストール

次のファイルを、TeX が見つけられる場所に置きます：`jsr.bbx`、`jsr.cbx`、`jsr.dbx`、`lbx/` の中のすべての `*.lbx`（`japanese.lbx` を含む）。

```sh
# すべての文書で使う場合（TEXMFHOME に置く）
mkdir -p "$(kpsewhich -var-value=TEXMFHOME)/tex/latex/jsr-biblatex"
cp -R jsr.bbx jsr.cbx jsr.dbx lbx "$(kpsewhich -var-value=TEXMFHOME)/tex/latex/jsr-biblatex/"
mktexlsr "$(kpsewhich -var-value=TEXMFHOME)"
```

その文書だけで使うときは、`jsr.bbx`、`jsr.cbx`、`jsr.dbx`、`lbx/*.lbx` を文書のフォルダに平置きにします（`lbx/` の下は TeX が探さないため）。詳しくはマニュアルの 1.5 節。

## 使い方

```latex
\documentclass{jlreq}
\usepackage[american,japanese]{babel}
\usepackage[autostyle=true]{csquotes}
\usepackage[backend=biber,style=jsr]{biblatex}
\addbibresource{refs.bib}
\begin{document}
……である\parencite{aoki2015}。\textcite{aoki2015} によれば，……
\printbibliography
\end{document}
```

`lualatex` → `biber` → `lualatex` の順に実行します。

bib の各エントリは、単独で完結した正しい書誌として、biblatex の標準のフィールドで書きます（和文の著者には `sortname`、各エントリには `langid` を書きます）。

```bibtex
@book{aoki2015,
  author    = {青木,光},
  sortname  = {Aoki, Hikaru},
  date      = {2015},
  title     = {社会調査の方法},
  publisher = {架空書房},
  langid    = {japanese},
}
```

文献注には `\parencite`／`\textcite` を使います（`\footcite` は使いません）。オプションは `firstfull`（文献注の初出をフルネームで出す。既定 `true`）と `doi`（取得日がなくても DOI を出す。既定 `false`）です。エントリ型ごとの書き方（新聞は `entrysubtype`、訳書は `related`、報告書所収の論文は `crossref` など）は、マニュアルの第2章と第4章にあります。欧文タイトルの大文字化はデータ側の責任です。

## テスト

```sh
sh tests/run-tests.sh
```

スタイルガイドの例文に対する回帰テストです（`tests/README.md`）。必要なもの：lualatex、biber、python3。マニュアルは `sh manual/build.sh` で組版できます。

## ライセンスと謝辞

LaTeX Project Public License 1.3c 以降（`LICENSE`）。biblatex-jpa（芝田征司氏、LPPL 1.3 以降）を元にしています。ファイルの一部は biblatex-apa を元にしています。マニュアルの体裁は Philipp Lehman 氏の ltxdockit（LPPL 1.3）の環境を借りています。

Copyright (c) 2026 Takuya MASUDA
