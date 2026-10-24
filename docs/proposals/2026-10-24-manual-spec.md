# マニュアル作成要件（2026-10-24、claude.ai 側で設計）

対象：`manual/jsr-biblatex.tex`（PDF マニュアル）と `README.md`。
参考：biblatex のマニュアル（`../../02_bib-doc/biblatex/doc/latex/biblatex/biblatex.tex`。ltxdockit／btxdockit を使用）、原本 biblatex-jpa のマニュアル（https://github.com/sbtseiji/biblatex-jpa の `doc/jpa-style.tex`）。

## 0. 方針
- **体裁は biblatex のマニュアルにそろえる**：本文を中央に置き，項目名（フィールド名・オプション名・コマンド名）を左の余白に色付きで出す。色は biblatex と同じ。
- **書式の例は biblatex-jpa にならう**：エントリ型ごとに「記入用のひな形 → 記入例（bib）→ 出力」の3点を並べる。
- **出力例はすべて実際に組んだもの**：手書きの出力（「…」で省いた表など）は置かない。

## 1. 文書クラスと土台（実験で確認済み）
- **jlreq（oneside）＋ `\usepackage{btxdockit}`** にする。ltxdockit の環境は `ltxdockit.sty`／`btxdockit.sty`（パッケージ）に定義されており，jlreq の上で読み込める。LuaLaTeX・luatexja で，下の環境がすべて動き，listings の中の和文も出ることを確認した（2026-10-24，TeX Live 2023）。
- ltxdockit の**クラス**（`ltxdockit.cls`）は使わない。T1 fontenc・charter などを読み込み，和文組版と合わない。
- クラスが読み込む設定ファイル `ltxdockit.cfg` の書体設定は，パッケージでは読み込まれない。必要な行（下の §3）をプリアンブルに写す。
- 独自の定義は `manual/jsrdoc.sty` にまとめる（プリアンブルを本文から分ける）。ltxdockit のコードを写して改変する場合は，ファイル名を変え，元の著作権表示（Philipp Lehman，LPPL 1.3）を残す。

## 2. ページレイアウト
- A4，**片面（oneside）**，本文の版面を**左右中央**に置く（左右の余白を同じにする）。今の `gutter=48mm`（両面・のど側だけ広い）はやめる。
- 版面：幅 370pt（biblatex と同じ。jlreq では `line_length=37zw`，10pt），高さは 700pt 前後（`number_of_lines` で調整）。左右の余白は約 112pt（約 40mm）ずつ。
- 余白の項目名の幅：`\marglistwidth`＝左余白の 85%（ltxdockit の既定の式）。`\marglistsep`＝10pt。
  - biblatex のマニュアルは `\oddsidemargin` を 1cm 増やして本文を右に寄せているが，こちらは中央のままにする（左右対称が要件）。そのぶん項目名の欄は少し狭い（約 95pt）。
- 項目名が欄に収まらないとき（`booksubtitle` など）：左余白の中で**右寄せのまま折り返す**（`\parbox[t]{\marglistwidth}{\raggedleft …}`）。紙の端から 10mm 以内に文字を出さない。
- 複数の項目をまとめて説明するときは，biblatex と同じく**項目ごとに1行ずつ並べる**（今の `\labelnames` の tabular は廃止）。

## 3. 色・書体
- 色（ltxdockit と同じ値）：
  - `spot` = rgb(0, 0.2, 0.6)：見出し，余白の項目名，オプション名，表の見出し行，リンク
  - `boxframe` = gray 0.8，`boxfill` = rgb(0.95, 0.95, 0.99)：コード例の枠と地
- 書体（biblatex のマニュアルに近いもの）：
  - 欧文：Libertinus Serif／Libertinus Sans（biblatex の Linux Libertine／Biolinum の後継。TeX Live に入っている）
  - 等幅：JuliaMono（Scale 0.8，biblatex と同じ）。手元にない場合の代替を決めておく（例：Latin Modern Mono）
  - 和文：原ノ味明朝／原ノ味角ゴシック（`luatexja-preset` の `haranoaji`）
- `ltxdockit.cfg` から写す設定：`\marglistfont`＝`\spotcolor\sffamily\small`，`\optionlistfont`＝`\spotcolor\sffamily\displayverbfont`，`\ltxsyntaxlabelfont`＝`\spotcolor\displayverbfont`，`\changeloglabelfont`＝`\spotcolor\sffamily\bfseries`，`\margnotefont`＝`\sffamily\small`。
- 見出し：jlreq の `\ModifyHeading` で，ゴシック＋spot 色にする（biblatex は sans＋spot）。
- hyperref：`colorlinks`，`linkcolor=spot`，`urlcolor=spot`，しおり（bookmarks）を付ける。PDF の title／author／subject を設定する。

## 4. 環境とマークアップ（biblatex のマニュアルと同じ名前を使う）

| 用途 | 環境・命令 | 備考 |
|---|---|---|
| エントリ型の一覧 | `typelist`，`\typeitem{book}`，`\reqitem{…}`，`\optitem{…}` | 「Required fields:」「Optional fields:」を**「必須：」「任意：」に日本語化**する |
| フィールドの一覧 | `fieldlist`，`\fielditem{name}{datatype}`，`\listitem{name}{datatype}` | 「field (literal)」を「フィールド（literal）」「リスト（name）」に日本語化 |
| オプション | `optionlist`，`\boolitem[既定]{name}`，`\optitem[既定]{name}{値}`，`valuelist` | 「default:」を「既定：」に日本語化 |
| コマンド | `ltxsyntax`，`\cmditem{parencite}[prenote][postnote]{key}` | 引数は `\prm{…}`，任意引数は角括弧 |
| キーの一覧（relatedtype，entrysubtype，langid の値など） | `keymarglist` | |
| 一般の見出し付き一覧 | `marglist` | |
| bib・TeX のコード | `ltxexample`（listings。枠＝boxframe，地＝boxfill） | 和文の長い行の折り返し（`breaklines`）を確認する |
| 出力例 | 独自環境 `bibexample`（後述） | |
| 更新履歴 | `changelog` | 版ごと。付録に置く |
| 文中の表記 | `\bibfield{title}`，`\bibtype{book}`，`\cmd{parencite}`，`\opt{true}`，`\prm{key}`，`\sty{biblatex}`，`\file{jsr.bbx}` | `\kw`，`\labelnames` は廃止 |

- 日本語化は，`\reqitem` などを `jsrdoc.sty` で再定義して行う（ltxdockit 本体は変えない）。
- 表は booktabs。見出し行は spot 色・太字・sans（biblatex の `H` 列型）。

### 出力例（`bibexample`）
- 1つの例 ＝「ひな形」（記入枠。※で注意書き），「記入例」（examples/*.bib の実物），「出力」の3点。jpa の書き方にならう。
- ひな形と記入例は `ltxexample`，出力は枠なしで，文献リストと同じぶら下げ（2zw）で組む。左余白に「出力」と小さく色付きで出す（`marglist` の見出し）。
- 出力は今の方式（keywords で `\printbibliography` を出し分ける）を続ける。訳書の添え物・ダッシュ・a，b は文献リストの文脈でしか正しく出ないため，`\fullcite` は使わない。
- 記入例は架空の書誌に限る（今のまま）。

## 5. 構成
biblatex のマニュアル（1 Introduction／2 Database Guide／3 User Guide／4 Author Guide／Appendix）の章立てを借り，jsr に要らない「4 Author Guide（スタイル作者向け）」は「内部の仕組み」に縮める。

1. **はじめに**：概要，免責（日本社会学会とは無関係，受理の保証なし），ライセンスと謝辞（biblatex-jpa の派生物であること，LPPL），要件，インストール，動作を確かめた環境
2. **データベースの手引き**（bib の書き方）
   1. エントリ型（`typelist`。各型の必須・任意フィールド。jsr が専用の書式を持つ型と，別名で処理する型）
   2. フィールド（`fieldlist`。jsr で意味を持つものだけ。種類：literal／name／date など）
   3. 使い方の注意：`langid`，`sortname`，名前の書き方（和文・欧文・団体・カタカナ名），日付，`related`
3. **利用者の手引き**
   1. 読み込みとオプション（`optionlist`：`firstfull`，`doi`。スタイルが固定している biblatex のオプションの表）
   2. 引用コマンド（`ltxsyntax`：`\parencite`，`\textcite`，`\citeauthor`，`\parencites`，`\footcite` と `\cite` の扱い。後置きの `[78=86]`）
   3. 文献リスト（`\printbibliography`，見出し）
4. **書式と例**（エントリ型ごと。ガイドの節番号を見出しに添える。例：「4.4(8) 調査報告書」）
   - 書籍／多巻本／編書論文／雑誌論文／新聞・雑誌記事／翻訳書・再録・再刊／電子書籍／報告書・政府刊行物／学位論文・学会報告／ウェブページ・ブログ・データベース／コンピュータファイル
5. **スタイルガイドとの対応表**：ガイドの節 ↔ この文書の節 ↔ 回帰テストのケース番号（C01 など）。規定がなく解釈で決めた点には印を付け，`docs/DECISIONS.md` を指す
6. **旧い書き方からの移行**
7. **制約と既知の問題**（biblatex 内部への依存，エンジン，ページ先頭のダッシュ など）
8. **内部の仕組み**（原典を代表にする方式，extradate の振り直し。保守する人向けに短く）
- 付録：**更新履歴**（`changelog`）

## 6. README.md
- GitHub で最初に読まれる短い案内にする（マニュアルの縮約）：概要，免責，最小の使用例，インストール，マニュアル（PDF）への案内，ライセンスと謝辞。
- 詳しい説明は書かず，マニュアルの節を指す（二重管理を避ける）。

## 7. 著作権・ライセンス
- スタイルガイドの文章は引用しない（長い抜き書きをしない）。節番号と要約で示す。
- biblatex-jpa の文章を下敷きにした部分があれば，謝辞に明記する。
- ltxdockit のコードを写した場合は §1 のとおり。

## 8. 検収の基準（ビルドで自動確認できるものは `manual/build.sh` に入れる）
1. `sh manual/build.sh` が LuaLaTeX＋biber で通り，エラー 0。
2. Overfull \hbox が 1pt を超えない（ログで確認）。
3. **左右対称**：全ページで版面の左端と右端の余白が等しい（差 1pt 以内）。pdftotext -bbox などで，奇数ページと偶数ページの本文の左端が同じことを確かめる。
4. 余白の項目名が紙の端から 10mm 以上内側にある。
5. 出力例はすべて実際に組んだもの（手書きの出力がない）。各「出力」の行が，回帰テストの期待値と矛盾しない。
6. 目次・しおり・リンクが働く。リンクは spot 色。
7. フォントがすべて埋め込まれている（pdffonts）。

## 9. 決めること（ユーザーの判断）
1. 欧文の書体：Libertinus（biblatex のマニュアルに近い，推奨）か，ltxdockit の既定（Charter／Helvetica 系）か。
2. 等幅：JuliaMono を入れるか（biblatex と同じ。TeX Live に入っていない場合がある），代替で済ませるか。
3. マニュアルの言語：日本語のみ（推奨）か，英語の概要を付けるか（README に英語の短い説明を付ける，など）。
4. 第8章「内部の仕組み」を載せるか（CLAUDE.md と重なる）。
