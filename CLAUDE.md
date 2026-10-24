# jsr-biblatex：Claude Code 向けの引き継ぎ

社会学評論スタイルガイド（第3版）に準拠した biblatex スタイル（`style=jsr`）。
フェーズA（バグ修正）とフェーズB（仕様への対応）は完了している。現在はフェーズC（構造・保守性）。

## 進め方
このリポジトリの作業（判断・実装・テスト・コミット）は Claude Code で行う。
claude.ai のプロジェクト「社会学評論スタイルガイド準拠biblatex作成」は、フェーズの節目の振り返りと記録に使う（そちらの文書はここからは読めない。必要な決定事項は `docs/DECISIONS.md` に写してある）。

### モデルの使い分け
- 起動は `claude --model opusplan`（または `/model opusplan`）。計画モードでは Opus、実行では Sonnet になる。
- **判断が要る作業は計画モードで始める。** 対象：スタイルガイドに規定がない点、bib の書き方が変わる点、文献リスト・文献注の出力が変わる点、設計の変更。Opus が選択肢と推奨を示し、ユーザーの承認を得てから実行に移る。
- 承認された方針の実装・テスト・定型的な修正は、実行モード（Sonnet）で行う。
- 判断の内容が大きいとき（複数の選択肢を比べる、bib の書き方を変える）は、計画を `docs/proposals/YYYY-MM-DD-<題>.md` に残す。

### 記録
- 決まったことは `docs/DECISIONS.md` に日付つきで追記する。
- 作業の区切りごとに `docs/PROGRESS.md` に「何をしたか・テスト結果・未解決」を短く追記する。フェーズの終わりに、ユーザーがこれを claude.ai 側に貼って振り返る。

### その他のルール
- 詳細な作業に入る前に、これから行う作業を提示する。
- コミットは区切りごとに、ユーザーの了承を得てから行う。コミットメッセージは日本語でよい。push はユーザーが指示したときだけ。
- 社会学評論スタイルガイドの PDF は `../../02_bib-doc/社会学評論スタイルガイド.pdf` にある（3章 引用、4章 文献）。仕様の根拠はこれを読んで確かめる。**著作物なので、PDF やその抜き書きをリポジトリに入れない。** 同じフォルダに biblatex.pdf（マニュアル）、biblatex-apa、biblatex-asa もある。

## ファイル
- `jsr.bbx`（文献リスト）、`jsr.cbx`（文献注）、`jsr.dbx`（データモデルの追加：jsrsortrole など）、`lbx/`（言語ごとの文字列）
- `tests/`：回帰テスト（`tests/README.md`）
- 作業確認用の文書は親フォルダにある：`../test.tex`（`../preamble/`、`../bib/*.bib`）。bib には文書側マクロ `\jq` が入っているので、`\nocite{*}` で組むと `\jq` の未定義エラーが出る（スタイルとは無関係。test.tex のプリアンブルでは定義済み）。

## テスト
```sh
sh tests/run-tests.sh      # OK: all cases match ／ NG: n line(s) … （差分は tests/guide.diff）
```
- 必要なもの：lualatex、biber、python3。リポジトリの bbx/cbx/lbx を `TEXINPUTS` で優先して読む。
- 変更のたびに実行する。出力を変える変更をしたら、`tests/guide.bib`／`guide.tex`／`guide.expected.txt` の3つをそろえて更新する（期待値はスタイルガイドに準拠させる。実際の出力に合わせて期待値を書き換えない）。
- 実データでの確認：`../test.tex` を変更前後で組み、pdftotext の差分が意図した変更だけか確かめる。
- フェーズBまでは TeX Live 2023（biblatex 3.19、biber 2.19）で確認した。手元の版が違う場合は最初にテストを流して結果を記録する。

## 実装上の注意（フェーズBで入った仕組み）
- **原典を代表にする方式**：訳書・再録（related ＋ relatedtype=translationof／reprintof）は単独の項目にせず、原典の項目に添える。原典が引用されていなければ biber の複製（clone）が代表になる。
  - `\DeclareStyleSourcemap`（relatedoptions、jsrsortrole）、`\AtDataInput`（`\jsr@datainput`）、`\pretocmd\blx@bbl@enddlist`（`\jsr@finishlist`：添え物を印刷リストから除き、extradate を振り直す）、`jsr:work`／`\jsr@printattach`／`jsr:attachbody`。
  - biblatex の内部名（`blx@dlist@entry@…`、`blx@data@…`、`\blx@bbl@enddlist`）に依存している。biblatex の更新で壊れたら、まずここを疑う。
- `\savebox` の中で `\printnames` を使うとき（発行元の判定、カタカナ名の判定）は、`\jsr@savepunct`／`\jsr@restorepunct` で句読点の状態を退避する。しないと保留中の区切りが消える。
- ループで `\do` を使い回すと入れ子で壊れる。新しいループには専用のハンドラ（`\forcsvlist\jsr@…@i`）を使う。
- カタカナ名の判定は Unicode 前提（LuaTeX／XeTeX／upTeX）。

## bib の方針
bib の各エントリは、単独で完結した正しい書誌として biblatex 標準のデータモデルで書く。原典と共通する項目の省略や整形はスタイル側で行う。bib を jsr 固有の仕組みに依存させない（`skipbib` や `sortyear` を書かせない）。

## フェーズCの作業（優先順の目安）
1. `\mkbibfparens`（cbx で定義、bbx で使用）を bbx に移す。
2. ハードコードの bibstring 化：「取得」「Retrieved」「面」「全」「巻」「vols.」。
3. 全角の閉じ丸カッコ「）」が行頭に来る問題（`../bib/test.bib` の Ashworth の訳書。`\nobreak` では直らなかった。luatexja の禁則とノードの並びを調べる）。
4. ヘッダーの版情報、README（使い方、オプション `firstfull`、`\parencite[78=86]{訳書}`、欧文タイトルの大文字化はデータ側の責任、エンジンの前提）。
5. **要判断（提案書を書く）**：独自フィールド `webpagetitle` と report の `type=onlinereport`、新聞の `type`/`issue`/`version` の転用を、標準フィールドに置き換える案。bib の書き方が変わる。
6. texmf 側クローンと作業コピーの二重管理（latexmkrc か `TEXINPUTS`）。
7. 未収録のテスト：4.5.1 電子書籍、4.5.4.2 MRDF。
