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

---

## 追補（2026-10-24）：モックアップ（手順1）の評価と，biblatex.pdf の表記に合わせた修正

モックアップ（`manual/chapters/smoke.tex`）を biblatex.pdf（3.22。p. 13 エントリ型，p. 38 bib の例，p. 109 引用コマンド，p. 166 フィールド）と見比べた。

### A. biblatex.pdf の表記（調べた結果）
1. **段落**：段落頭の字下げはない。段落の間は少し空ける。
2. **コマンド**（`ltxsyntax`）：書式の行（`\parencite[⟨prenote⟩][⟨postnote⟩]{⟨key⟩}`）は，コマンド名が左の余白から始まり，引数が本文側へ続く。変種は行を重ねる（`\parencite`／`\Parencite`）。**説明は空行のあとの別の段落**で，本文の左端から始まる。原稿では `\cmditem` の行のあとに必ず空行を置いている（biblatex.tex 4591-4594 行）。
3. **フィールド・エントリ型**：項目名を左の余白に出し，1行目に「field (string)」，説明は次の段落（本文の左端から。字下げなし）。エントリ型は説明の後に「Required fields:」「Optional fields:」を段落として並べ，間を少し空ける。
4. **コード例には余白の見出しを付けない。** 地の文で導き（「…such as:」），枠に入れ，続く地の文で結果を述べる（「This entry will be printed as «…»」）。見出しの代わりに文章がつなぐ。
5. **枠は2種類**：
   - **bib の例**：`lstlisting[style=bibtex]`。白地，細い黒の枠，本文の幅いっぱい。
   - **LaTeX の例**：`ltxexample`。薄い青の地（boxfill），灰色の枠（boxframe）。
   - 地の色で「bib か LaTeX か」を見分けられる。

### B. モックアップの問題と修正方針

| # | 問題 | 修正 |
|---|---|---|
| B1 | `\parencite` の説明が書式と同じ行に続く | 原稿の約束：`\cmditem` の行のあとに空行を置く（biblatex と同じ）。`build.sh` の検査で「`\cmditem` の行の後ろに文字が続く」原稿を警告する |
| B2 | 段落頭が1字下がる。fieldlist の説明も下がって見える | `\parindent=0pt`，`\parskip=.5\baselineskip plus .1\baselineskip`。リストの中も `\listparindent=0pt`。jlreq の行送りとずれないか（行取り）を確認する |
| B3 | 1.2 の「ひな形」の見出しが節見出しの横に並ぶ | 書式の例では `marglist` を使わない（節見出しの直後にリストの見出しが来ると，見出しの行に並んでしまう） |
| B4 | 記入例が bib ファイル全体（約1ページ）で，出力と離れる。ファイル先頭の `% 名前の書き方` まで出る | **1つの例＝1エントリ**（訳書など，まとめて1項目になるものは関係するエントリだけ）。bib ファイルからキーを指定してそのエントリだけを抜き出して表示する（`jsrdoc.lua` で抜き出す） |
| B5 | 出力を `marglist` の中で組んだため，1件目が見出しの行に乗り，2件目以降が字下げされる | 出力はリスト環境に入れない。文献リストと同じぶら下げ（2zw）で，本文の左端から組む |
| B6 | bib の例が LaTeX の例と同じ薄い青の地 | bib は白地・細い黒枠（`style=bibtex` 相当），LaTeX は `ltxexample`（薄い青の地）に分ける |

### C. 書式の例（`bibexample`）の組み方（改訂）
各エントリ型の節は，次の順に組む。

1. **説明**（地の文）と，その型で使うフィールドの `fieldlist`。
2. **ひな形**：地の文で導く（「記入のひな形は次のとおりです：」）→ bib の枠。
   - 記入する箇所は `⟨書名⟩` のように，`\prm` と同じ山括弧＋イタリックで示す（listings の `moredelim` で `<…>` を変換）。
   - 注意書き（`※ …`）は等幅でない本文書体・灰色にして，記入する文字と見分ける。
3. **例**（ケースごとに繰り返す）：
   - 地の文で導く（「共著の場合：」「訳者がいる場合：」）。
   - **bib の枠**（そのケースのエントリだけ）。
   - **出力**：枠の直後に，本文の左端から，文献リストと同じぶら下げ（2zw）・`\small` で組む。出力であることは，左に spot 色の細い縦線（2pt）と左余白の小さな「出力」の文字で示す。「出力」の文字は，出力の1行目のベースラインにそろえる（`\llap` で置く。リスト環境は使わない）。
   - 必要なら，出力の後に地の文で注記する（「書名と副題は——でつながります」）。
4. 文献注の例は，表（コマンド／出力）にまとめる（今の草稿の形を続ける。表も実際に組んだ出力）。

コマンド案：
```
\bibexample{aoki2015}               % 1エントリ：bib の枠＋出力
\bibexample{fromm1941,fromm1951}    % 関係するエントリをまとめて：bib の枠（並べる）＋出力（1項目）
\begin{bibtemplate} … \end{bibtemplate}   % ひな形（地の文で導いてから置く）
```
- 出力は `\printbibliography` を，キーで絞る `\defbibcheck`（指定したキーと，その複製（clonesourcekey）だけを通す）で出す。keywords による出し分けは，ファイル単位なので使わない。
- 枠と出力のあいだは `\smallskip`，例と例のあいだは `\medskip`。枠と出力が別のページに分かれないようにする（`\nopagebreak`，または全体を `minipage` に入れずに `\needspace`）。

### D. 検収の基準に追加
8. `\cmditem` の行の後ろに説明が続く原稿がない（`build.sh` で検査）。
9. 本文・リストの中で段落頭の字下げがない。
10. 書式の例で，bib の枠とその出力が同じページにある。
11. 「出力」の文字が，出力の1行目のベースラインとそろっている（差 1pt 以内）。

### E. 試作で確かめたこと（2026-10-24，`docs/proposals/2026-10-24-manual-proto.tex`）
上の C を試作で確かめた。組み方は試作に合わせる（C と食い違う点は E を優先）。

1. **出力の絞り込みは refsection で行う。** 例ごとに `\begin{refsection}\nocite{<keys>}\printbibliography[heading=none]\end{refsection}`。
   - `\defbibcheck` で entrykey を比べる方式は動かなかった（`check=` を付けると Empty bibliography になり，チェックも呼ばれなかった）。
   - refsection だと，訳書だけを指定した例（`\bibexample{hale1985}`）でも，原典の複製が代表になって実際と同じ形で出る。jsr の仕組みは refsection ごとに働くので，そのまま使える。
   - キーを比べる場合，biblatex の entrykey は detokenize されている（catcode 12）。文字列として比べるときは `\detokenize` をそろえる。
2. **「出力」の文字**は，`begentry` を一時的に再定義し，最初の項目で `\marginpar`（`\reversemarginpar`，幅＝`\marglistwidth`，間隔＝`\marglistsep`）として置く。1行目のベースラインにそろう。
3. **段落の間隔（`\parskip`）は listings の各行に入ってしまう**（枠の中の行間が空く）。listings の中だけ 0 にする：`\lst@AddToHook{EveryPar}{\parskip\z@skip}`（`Init` だけでは足りない）。
4. 1エントリの抜き出しは Lua で行う（`2026-10-24-manual-proto-ex.lua`）。`@type{key,` から，行頭の `}` まで。
5. ひな形の記入箇所 `<…>` は，listings の `moredelim=[s][\itshape\rmfamily]{<}{>}` でイタリックにした（山括弧は残る）。`※` 以降は `moredelim=[l][\color{gray}\rmfamily\footnotesize]{※}`。
6. 残った課題：
   - `\cmditem` を2行重ねると，行の間が詰まりすぎる（`\parskip=0` と ltxsyntax の組み合わせ）。biblatex.pdf（p. 109）と同じ行送りにする。
   - bib の枠と出力が別のページに分かれることがある（D-10 の検収で確かめる）。
