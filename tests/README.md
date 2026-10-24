# 回帰テスト

社会学評論スタイルガイドの例文を `guide.bib` にまとめ、jsr スタイルで組版した結果を、ガイドどおりに書いた期待値 `guide.expected.txt` と行ごとに比べる。

## 実行

```sh
sh tests/run-tests.sh
```

- 必要なもの：lualatex、biber、python3
- このリポジトリの `jsr.bbx`／`jsr.cbx`／`lbx/` を、texmf にインストールしたものより優先して読み込む（`TEXINPUTS` で指定）。
- 結果は `OK` か `NG: n expected line(s) not matched` と表示される。差分は `tests/guide.diff` に出る（`-` が期待値、`+` が実際の出力）。

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
| `run-tests.sh` | 実行スクリプト |
| `textdump.lua`、`normalize.py` | 出力の取り出しと正規化 |

## 期待値を変えるとき

スタイルガイドの解釈を変えた場合や、新しいケースを追加した場合は、`guide.bib`／`guide.tex`／`guide.expected.txt` の 3 つをそろえて更新する。
