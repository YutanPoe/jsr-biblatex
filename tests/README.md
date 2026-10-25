# 回帰テスト

社会学評論スタイルガイドの例文を `guide.bib` にまとめ、jsr スタイルで組版した結果を、ガイドどおりに書いた期待値 `guide.expected.txt` と行ごとに比べる。

## 実行

```sh
sh tests/run-tests.sh
```

- 必要なもの：lualatex、biber、python3
- biber は PATH 上のものを使う。別の場所のものを使うときは環境変数 `BIBER` で指定する（例：cpan で入れた biber は `PERL5LIB=$HOME/perl5/lib/perl5 BIBER=$HOME/perl5/bin/biber sh tests/run-tests.sh`）。
- このリポジトリの `jsr.bbx`／`jsr.cbx`／`lbx/` を、texmf にインストールしたものより優先して読み込む（`TEXINPUTS` で指定）。
- テスト文書は5つ。`guide`（スタイルガイドの例文）、`noextra`（a、b の付く文献が1つもない文書。extradate の振り直しで未定義のリストを扱わないことを確かめる）、`doi`（オプション `doi=true`）、`kinsoku`（禁則。後述）、`layout`（文字の比較では見えない組版。後述）。
- 結果は文書ごとに `OK` か `NG: n expected line(s) not matched, m unexpected line(s)` と表示され、最後に全体の結果が出る。差分は `tests/<文書名>.diff` に出る（`-` が期待値、`+` が実際の出力）。LaTeX のエラーがあれば、ログの場所とともに表示する。

## 実データの変更前後比較

```sh
sh tests/compare-real.sh [REV]
```

- `../test.tex`（親フォルダ）を、REV（既定 `HEAD`）のスタイルと作業コピーのスタイルで組み、組版された各行の文字列を比べる。差分は `tests/real.diff` に出る（`<` が REV、`>` が作業コピー）。
- 出力を変える変更をしたあとに、意図した変更だけが差分に出ているかを確かめるために使う。回帰テストの代わりにはならない。
- 行単位の比較なので、改行位置が変わると後続の行も差分に出る。pdftotext は使わない。
- 必要なもの：lualatex、biber（`BIBER` で場所を指定できる）、git

## 仕組み

- `guide.tex` は紙面を横に極端に広くしてあるので、文献注 1 つ・文献 1 つがそれぞれ 1 行に組まれる。
- `textdump.lua` が、組版された各行の文字列を `guide.lines.txt` に書き出す（PDF からの抽出は使わない）。
- `normalize.py` が、和文文字の前後の空白（和欧間の自動スペースなど）を取り除き、期待値と実際の出力を同じ形にそろえる。期待値ファイルの `#` で始まる行は注釈として無視する。

## ファイル

| ファイル | 内容 |
|---|---|
| `guide.bib` | テスト用データ。各エントリは自己完結した書誌として書く |
| `guide.tex` | 文献注（C01〜）と文献リストを出力する文書 |
| `guide.expected.txt` | 期待値（スタイルガイドに準拠） |
| `noextra.tex`、`noextra.expected.txt` | a、b のない文書のテストと、その期待値 |
| `doi.tex`、`doi.expected.txt` | オプション `doi=true` のテストと、その期待値 |
| `layout.tex`、`layout.bib`、`layout.expected.txt`、`layoutdump.lua`、`check-layout.py` | 組版のテスト（文字の比較では見えないもの）。「，」の直後の空白が 0.5 全角以下であること（編書論文のダッシュ「————，2014」）、文献リストに文字のない行（空の項目）がないこと（署名のない新聞・雑誌記事は skipbib で外れる）、文献注と文献リストの行が期待値と一致すること |
| `kinsoku.tex`、`check-kinsoku.py` | 禁則のテスト（行幅を変えた箱に文献リストを繰り返し組み、行頭に閉じ括弧・句読点、行末に開き括弧が来る行がないことを確かめる） |
| `run-tests.sh` | 実行スクリプト |
| `compare-real.sh` | 実データ（`../test.tex`）の変更前後比較 |
| `textdump.lua`、`normalize.py` | 出力の取り出しと正規化 |

## 期待値を変えるとき

スタイルガイドの解釈を変えた場合や、新しいケースを追加した場合は、`guide.bib`／`guide.tex`／`guide.expected.txt` の 3 つをそろえて更新する。

## dash（同一著者のダッシュ）
- `dash.tex`／`dash.bib`／`dash.expected.txt`：1 ページ 3 行の小さな紙面に同一著者の 6 件を並べ、ページの先頭に来る項目でも「————」になることを確かめる。`bbx:dashcheck` の再定義を外すと、ページ先頭の項目が名前に戻って NG になる（確認済み）。
