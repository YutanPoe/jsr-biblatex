# 進捗

## 2026-10-24 フェーズA・B 完了（claude.ai 側で実施）
- 回帰テスト：全件一致（`OK: all cases match`）。
- 詳細は claude.ai プロジェクトの「jsr-biblatex-進捗-フェーズA.md」「jsr-biblatex-進捗-フェーズB.md」。
- 未解決：全角の閉じ丸カッコ「）」が行頭に来ることがある（フェーズCへ）。

## 2026-10-24 Claude Code への引き継ぎ・環境確認
- 環境：TeX Live 2026（LuaHBTeX 1.24.0）、biblatex 3.22、biber 2.23 (beta)。フェーズA・Bの確認時は TeX Live 2023（biblatex 3.19、biber 2.19）。
- biber 2.22（TinyTeX 同梱）は `Unicode/Collate/Locale/ja.pl can't be found` で止まり、組めなかった。cpan 版 2.23 (beta) `~/perl5/bin/biber` に替えて実行する（`PERL5LIB=$HOME/perl5/lib/perl5` と `PATH` の指定が要る）。
- テスト結果：`NG: 2 line(s)`。不一致は `langid = french` の Bourdieu 2件（論文題名がギュメ « »、コロンの前に空白）。
- 見立て：`checkLang` は `\ifcsundef{datefrench}` で「babel に未読み込みの言語は american で組む」としているが、今回は `guide.aux` の読み込み時に babel が german／french を取り込み、`datefrench` が定義済みになっている。原因（babel／biblatex／csquotes のどれが .aux に書くか）は未確認。
- 未解決：上記の修正方針（未定。ユーザーが検討中）。`tests/run-tests.sh` に biber の PATH 設定を足すかどうか。
- この状態のまま、フェーズA・Bをコミットした（TL2026 では未検証）。

## 2026-10-24 フェーズC-0：未読み込みの言語（french）の不一致を解消
- 原因：babel 26.11 が未読み込みの言語も `\select@language` の中で読み込むため、`checkLang` の `date<言語>` による判定が効かなくなった。さらに `checkLang` は biblatex の autolang より前に動くので、`\selectlanguage{american}` はあとから上書きされた。
- 対応：`jsr.bbx` に `\jsr@doclangs`（プリアンブル終了時の言語一覧）を追加し、一覧にない言語の項目は `langid` を消す。`tests/run-tests.sh` は環境変数 `BIBER` で biber の場所を指定できるようにした。
- テスト結果：`OK: all cases match`（TeX Live 2026、biblatex 3.22、biber 2.23 beta）。
- 実データ（`../test.tex`）：変更前後の差分は2件で、どちらも未読み込みの言語（Bourdieu 1989、Latour 2005）のコロン前の空白が消えただけ。意図した変更。
- 実データの比較は、手元に pdftotext がないため `tests/compare-real.sh` にした（`tests/textdump.lua` で組版後の行を書き出して比べる）。同じ差分が再現できることを確認した。
- 未解決：`\jsr@doclangs` に重複が入る（無害）。TeX Live 2023 / biblatex 3.19 での再確認はしていない。

## 2026-10-24 区切り1：空リストのバグ修正
- `docs/proposals/2026-10-24-fix-empty-lists.patch` を適用した（`\jsr@forlistcs`／`\jsr@dolistcs`）。a、b の付く文献が1つもない文書で、`\enddatalist` に `Missing \endcsname` が出る不具合の修正。
- `tests/noextra.tex`／`noextra.expected.txt` を追加し、`run-tests.sh` は guide と noextra の2文書を組むようにした。LaTeX のエラーもログで検出する。
- 確認：パッチなしで noextra が失敗する（エラー再現）。パッチ後は guide・noextra ともに全件一致。`compare-real.sh` は差分なし。

## 2026-10-24 区切り2：提案1 A（report）
- report ドライバ：先頭の名前を author → editor → institution の順に選ぶ。欧文でも type と number を出す。
- 報告書所収の論文（`@incollection` ＋ `crossref` で親の `@report`）：`\DeclareDataInheritance{report}{incollection,inbook}`、`report:parent` マクロ。ガイドの岩本 1997 と一致。
- lbx：american／english／british の `techreport` を `Technical Report`（略さない）にした。
- テスト：guide.bib／guide.tex／guide.expected.txt に、分担者あり（山本 1998）、親の報告書（碓井 1997）、所収論文（岩本 1993・1997）、欧文の技術報告書（Taylor 2005）、文献注2件（C61、C62）を追加。`run-tests.sh` は期待値にない行の数も表示する。
- 結果：guide・noextra ともに全件一致。`compare-real.sh` は差分なし（実データの出力は変わらない）。
- 未解決：欧文の報告書所収論文（crossref）の書式は、テストしていない。`type=onlinereport` はフェーズC 作業5で扱う。

## 2026-10-24 区切り3：提案2 の #1〜#5
- #1 和文の edition（第n版／文字）、#2 欧文の編書論文の edition、#3 book／incollection の URL と取得日（urldate があるときだけ）、#4 エントリ型の別名、#5 sortname の警告（sourcemap の印 `jsrnosortname`）を実装。
- テスト：guide.bib／guide.tex／guide.expected.txt に、野村（版・url のみ）、Cole（欧文の編書論文の版）、藤竹（電子書籍の取得日・URL）、清水（booklet）、Rivera（manual）を追加。結果：guide・noextra ともに全件一致。
- 実データ：`compare-real.sh`（test.tex）は差分なし。`../bib` の全エントリを `\nocite{*}` で組んだ変更前後の比較では、差分は意図した2種類のみ：(1) 中山 1933 の『モダン語新式辞典 改訂版』、(2) Saitama1956埼玉県議会史mv の urldate を持つ『埼玉県議会史』4件に（取得日，URL）が付いた。
- 未解決：sortname のない和文の文献が実データに5件ある（SaitamaHistory1991新編埼玉県史通史編7、Saitama1986埼玉県議会史12、Saitama1989埼玉県議会史13、Saitama1989埼玉県議会史13資料編、Saitama1989埼玉県議会史14）。bib の直しは了承を得てから行う。

## 2026-10-24 区切り4a：学位論文・学会報告（提案1 B・C）
- thesis：欧文の括弧をやめた。lbx の `mathesis`／`phdthesis` を、和文は略さず、欧文は MA thesis／PhD dissertation にした。
- 学会報告：`conference` マクロ（和文は eventtitle＋type、欧文は ASA 式）を作り、`@inproceedings`（booktitle なし）と `@unpublished` で使う。booktitle があれば編書論文と同じ形。`paperpresented` を全言語の lbx に追加。
- テスト：欧文の博士・修士論文、和文の博士論文、学会報告（type あり・なし）、@unpublished、欧文の学会報告（ASA）、予稿集の論文を追加。guide・noextra ともに全件一致。
- 実データ：`compare-real.sh` は差分なし。`../bib` 全エントリの比較では 1 件：test.bib の川口 2018（@inproceedings、booktitle＋eventtitle＋type=ポスター発表）が、予稿集の論文として『…報告要旨集』45-6．の形になり、type と eventtitle は出なくなった（決定どおり）。
- bib のブランチ：`../bib`（別リポジトリ）に作業ブランチ `jsr-phase-c` を切った。bib の書き直しはこのブランチで行い、確認後に main へマージする。

## 2026-10-24 区切り4b-1：DOI オプションと MRDF（提案2 A・E）
- `doi` オプション（既定 false。doi=true で取得日がなくても DOI を出す）。`@dataset` の専用ドライバ。`producer` を全言語の lbx に追加。
- テスト：guide に MRDF（和文・欧文）と DOI のある論文（和文・欧文、既定では DOI が出ないこと）を追加。`tests/doi.tex`／`doi.expected.txt` を追加（doi=true）。`run-tests.sh` は guide・noextra・doi の3文書を組む。結果：全件一致。
- 実データ：`compare-real.sh`、`../bib` 全エントリの比較ともに差分なし（実データに @dataset はなく、doi は既定のまま）。
- 決定事項からの変更：MRDF の提供機関は作成者と同じでも省かない（ガイドの例に合わせた）。

## 2026-10-24 区切り4b-2：電子書籍と単独の訳書（提案2 B・C）
- 電子書籍：`ebook:orig`（紙媒体の年・出版社）、`ebook:note`（末尾の括弧）。`eprintbook` は廃止。origpublisher があるとき [初版年] を出さない（bbx の originaldate、cbx の cite:origyear）。
- 単独の訳書：`translator/author/editor` を、添え物（`bbx:inattach`）か著者なしのときだけ訳者を先頭にするよう変更。`translator:after` で書名の後に訳者を出す。cbx は translator があれば （著者 原典の年=訳書の年）。
- sortname の警告：crossref／xref を持つ項目を対象外にした（実データの5件は誤検出だった）。
- テスト：電子書籍（和文の紙媒体情報つき、Kindle版、CD-ROM）、単独の訳書（和文・欧文）、文献注3件（C63〜C65）を追加。全件一致。
- 実データ：`compare-real.sh` は差分なし。`../bib` 全エントリの比較で、変更は意図したもののみ：Cho2015夢（単独訳書）が「張彧暋，2015，『…』山岡由美訳，朝日新聞出版．」に、note（電子書籍版、OCLC、Section）が末尾の括弧に。ほかに、行数が1行増えたため、ページ先頭の項目で同一著者のダッシュが出入りした（standard.bbx の \iffirstonpage の仕様。不具合ではない）。
- bib（ブランチ `jsr-phase-c`、未コミット）：books.bib の OCLC 等の note 2件と、Saitama1956埼玉県議会史mv の urldate を削除。main との比較で、これらの表示だけが消えることを確認した。副作用：その mvbook の親を単独で出すと、年が「2026」（urldate 由来）から n.d. になる（date={1956-} が年として解釈されていない）。

## 2026-10-24 区切り4b-3：新聞記事（提案2 D）
- 新聞・雑誌の判定を `entrysubtype` に（`type=newspaper`／`magazine` も互換で受け付ける）。版・地域版を `version` から `note` に。欧文の署名記事を ASA 式（月日、p.／pp.）に。
- テスト：entrysubtype の新聞（Asahi1998）、互換の type=newspaper（Mainichi1998）、版・地域版つき（Mainichi1999）、署名入りの和文・欧文（Nakaoka1975、Walsh1998・1999）、文献注4件（C66〜C69）。全件一致。
- bib（ブランチ `jsr-phase-c`、未コミット）：newspaper.bib、magazine.bib、test.bib の `type={newspaper/magazine}` 64件を `entrysubtype` に、`version` 44件を `note` に、空の `version={}` 4件を削除。旧スタイル＋main の bib と、新スタイル＋ブランチの bib で、新聞・雑誌の出力は完全に一致した。
- フェーズC 作業5 のうち、新聞の `type`／`issue`／`version` の転用は解消。`webpagetitle` と report の `type=onlinereport` は未着手。
- 未確認：magazine.bib の `Miyazato1929デイゼルエンヂン` ほか `type={}`（空）のエントリ（books.bib 1件、article.bib 4件、magazine.bib 1件）は、今のまま（通常の論文として出る）。

## 2026-10-24 フェーズC 作業5（残り）：webpagetitle と type=onlinereport
- 提案書 `docs/proposals/2026-10-24-webpagetitle-onlinereport.md` を残し、決定した（`titleaddon`、`@online`、旧形式は読み替え＋警告）。
- jsr.bbx：online ドライバでサイト名を titleaddon から出す。report ドライバから onlinereport と webpagetitle の分岐を削除。sourcemap で旧形式を読み替え（`\pertype{report}` で対象を絞る。`typesource` だけの step はエントリ型を空にするので使えない）。警告マクロ `jsr@chklegacy`。jsr.dbx：webpagetitle を削除、`jsrlegacy` を追加。
- テスト：guide.bib の webpagetitle を titleaddon に。旧形式（webpagetitle、onlinereport）の確認用に2件追加。全件一致。旧形式のとき `guide.log` に警告が出る。
- 実データ：`compare-real.sh` は差分なし。旧スタイル＋main の bib と新スタイル＋ブランチの bib、新スタイル＋main の bib（旧形式）と新スタイル＋ブランチの bib の、どちらも差分なし。旧形式の bib の警告は2件、書き直した bib は0件。
- bib（ブランチ `jsr-online`、未コミット）：others.bib の NDL2013本の万華鏡（webpagetitle→titleaddon）と UIC2018HighSpeedRail（@report＋onlinereport→@online）。

## 2026-10-24 フェーズC 作業1・2：\mkbibfparens の移動とハードコードの bibstring 化
- `\mkbibfparens`（全角丸かっこ）の定義を cbx から bbx に移した（bbx が cbx に依存しないように）。cbx は bbx の定義を使う。
- ハードコードを bibstring に：「取得」「Retrieved」→ `urlseen`（既存の文字列。非CJK の jsr.lbx で Retrieved に上書き）、「面」→ `newspaperpage`、「全」→ `totalprefix`、「巻」「vols.」→ `totalvolumes`、「刊」→ `origpublished`（新規。全言語の jsr.lbx に定義。和文以外は空、totalvolumes だけ vols.）。bbx と cbx の該当箇所を `\bibstring` に置き換えた。
- テスト：欧文の多巻本（3 vols.）を追加。全件一致。実データの出力は変わらない（compare-real、`../bib` 全エントリの比較ともに差分なし）。

## 2026-10-24 フェーズC 作業3：全角「）」が行頭に来る問題
- 再現しなかった。`../bib/test.bib` の Ashworth の訳書を行幅 26〜48 字で組み、また `../bib` の全エントリを 9 通りの行幅（30〜50 字）で組んで、行頭に閉じ括弧・句読点が来る行は 0 件。改行前のノード列では、「．」と「）」の間は `PEN(10000) KERN PEN(10000) KERN PEN(10000) GLUE GLUE` で、改行できる位置がない（禁則が効いている）。
- 以前の症状（行頭の「）．」）は、「）」の直前に改行可能な glue があったときの形。スタイルのコピーで「）」の直前に `\hskip0pt plus 1pt` を入れると、同じ症状が出ることを確かめた（負の対照）。
- 再発防止に回帰テスト `kinsoku` を追加（`kinsoku.tex`、`check-kinsoku.py`）。行幅 16〜49 字の箱に、guide.bib の全エントリの文献リストを繰り返し組み、行頭の閉じ括弧・句読点、行末の開き括弧がないことを確かめる。`run-tests.sh` に組み込んだ。

## 2026-10-24 フェーズC 作業4（途中）：ヘッダー・LICENSE とマニュアル
- ヘッダー・LICENSE：bbx／cbx／dbx／lbx に LPPL 1.3c の通知と著作権表示、版情報を `2026/10/24 v1.0` にそろえた。`LICENSE` を追加（通知のみ。全文は入れない）。
- マニュアル `manual/jsr-biblatex.tex`（日本語、27 ページ）と、組版した `manual/jsr-biblatex.pdf`：はじめに（要件、インストール）、使い方、オプション（`firstfull`、`doi`）、引用コマンド、bib の書き方（名前、`sortname`、並び順、発行元の省略）、エントリ型ごとのフィールド表と bib の例と実際に組んだ出力、旧形式からの移行、制約。
- 出力例の書誌は `manual/examples/*.bib`（架空の著者・書名のみ）。bib の中身は `fancyvrb` の `\VerbatimInput` でそのまま表示し、biber の sourcemap でファイルごとに `keywords` を付けて、節ごとに `\printbibliography[keyword=…]` で出し分ける。組版は `sh manual/build.sh`（`BIBER` 環境変数に対応）。
- `fvextra` は TinyTeX に入っていないため、標準の `fancyvrb` を使った（追加のパッケージは不要）。
- 確認：マニュアルは警告なしで組める。PDF を画像にして（macOS の PDFKit）、表と出力例のレイアウトを確かめた。
- 未了：README.md（GitHub 用）。

## 2026-10-24 マニュアルの改訂（レビューを受けて）と出自の明記
- 出自：`jsr.bbx`／`jsr.cbx`／`jsr.dbx` は、芝田征司氏の biblatex-jpa（日本心理学会風文献スタイル、LPPL 1.3 以降）を元にした改変版（元の `\ProvidesFile` の行が一致する）。ヘッダーと LICENSE に、元の作品と著作者を明記した（先に付けたヘッダーは biblatex-apa だけで不完全だった）。マニュアルに謝辞を追加。
- マニュアル：目次・参照を `hyperref` でクリックできるようにした（目次と参照は青字、URL と引用は黒）。表を、biblatex のマニュアルの `keymarglist` 風の、項目名を左の余白に出す一覧（`fieldlist` 環境。`jlreq` の `gutter=48mm`、`line_length=36zw`）に替えた。文体を biblatex-jpa のドキュメントにならって「，」「。」に統一し、冒頭に免責（日本社会学会が作成・配布するものではない）と謝辞を追加、例の見出しを「bib エントリ」「出力結果」にした。表紙と目次を別ページにした。
- 31 ページ。警告なし。PDF を画像にして確かめた。

## 2026-10-24 マニュアルの作り直し（区間2：第1〜3章）
- 土台（`manual/jsrdoc.sty`、`jsrdoc.lua`、`check.py`、`build.sh`）をコミットした（`a96a14a`）。書式の例は「ひな形→記入例（1エントリ）→出力」。出力は refsection ごとに実際に組む。bib の枠と出力は1つの箱に入れ、ページを分けない。
- 第1章（はじめに：免責、ライセンスと謝辞、要件、インストール、この文書の読み方）、第2章（データベースの手引き：エントリ型の選び方、`@article` と `@incollection` の違い、`crossref`、`related` と `crossref` の違い、エントリ型の一覧、フィールドの一覧、迷いやすい点）、第3章（利用者の手引き：組み込み、オプション、引用コマンド、文献リスト、警告）を書いた。迷いやすい点は左余白の「注意」で示す。
- 例の追加：`onocr2014`（`crossref` の所収論文）、`mori2020`（DOI だけがある論文。`doi=true` の出力は `\toggletrue{bbx:doi}` で切り替えて実際に組む）。`\bibexample*` は出力だけを出す。
- 版面：等幅フォントの倍率を 0.76 にした（長いコマンド名の項目名が左余白の 10mm 以内に入るため）。孤立行を禁止（`\@clubpenalty` も）。
- 23 ページ。検査はすべて合格。第4章（書式と例）、第5章（移行）以降は作成中。

## マニュアルの作り直し（区間3：第4章 書式と例）
- 第4章を書いた（4.1 書籍／4.2 多巻本／4.3 編書論文／4.4 雑誌論文／4.5 新聞・雑誌記事／4.6 翻訳書・再録・再刊／4.7 電子書籍／4.8 調査報告書・政府刊行物／4.9 学位論文・学会報告／4.10 ウェブ・データベース／4.11 コンピュータファイル）。各節はひな形 → 記入例 → 実際の出力。スタイルガイドの節番号は、回帰テストの注釈で裏づけがあるものだけ記した。
- `jsrdoc.sty` に `\bibexampleonly`（bib の枠だけ）を追加。署名のない新聞記事は文献リストに載らず出力が空になるため、文献注を地の文に実際に組んで示す。
- 出力と地の文の食い違いを直した（副題のつなぎは「——」、国立印刷局の出版社は自動で省かれる）。
- テスト：`manual/build.sh` 全項目合格（48ページ）。
- 未解決：第5章以降（ガイドとの対応表、移行、制約、内部の仕組み、更新履歴）。4.2 多巻本の巻つきの出力、4.3 以降の画像確認は区間4でまとめて行う。

## マニュアルの作り直し（区間4：第5〜8章と付録）
- 第5章「スタイルガイドとの対応」：ガイドの節 ↔ マニュアルの節 ↔ テストのケース（C01〜、注釈）の対応表（longtable）と、解釈で決めた点の一覧（`docs/DECISIONS.md` を指す）。ガイドの節番号は PDF の見出しと突き合わせた。
- 第6章「旧い書き方からの移行」（対応表、警告の読み方、書き換えの例）、第7章「制約と未解決の点」、第8章「内部の仕組み」（短く）、付録A「更新履歴」（v1.0）。第4章の末尾にあった移行の仮見出しは第6章に移した。
- 第4章の節番号の参照を、ガイドの見出しと合わせて直した（再録は和文 4.4(7)／欧文 4.2(8)、再刊は 4.2(7)、英訳は 4.2(6)）。
- `tests/guide.expected.txt` の注釈の節番号を直した（欧文の編書論文は 4.2(4)。期待値の本文は変えていない）。
- `jsrdoc.sty`：`longtable` を読み込む。
- 確認：`manual/build.sh` 全項目合格（55ページ）、`tests/run-tests.sh` 全件一致。p.34、41、49、52、55 を画像で確認した。
- 未解決：第7章に挙げた点（`date={1956-}`、欧文の報告書所収論文、TeX Live 2023 での再確認）。README、`CLAUDE.md` の更新、PDF のコミットは次の区間。

## マニュアルの作り直し（区間5：README、仕上げ）
- `README.md` を書いた（英語の概要、免責、マニュアルへの案内、インストール、最小の使用例、テスト、ライセンスと謝辞）。詳しい説明はマニュアルを指す。
- インストール手順を、まっさらな `TEXMFHOME`（`TEXMFLOCAL` も空にして、古い texmf-local の写しが読まれないようにした）で試した。TEXMFHOME に置く方法は通った。文書フォルダへの平置きは、`japanese.lbx` を置いていないと `Language 'japanese' not found` で止まることがわかり、マニュアル第1章と README を直した（`lbx/*.lbx` をすべて置く）。
- `CLAUDE.md` のフェーズC作業4を完了にし、マニュアルの記述を足した。`manual/jsr-biblatex.pdf` を組み直してコミットする。
- 確認：`manual/build.sh` 全項目合格、`tests/run-tests.sh` 全件一致。
- 未解決（第7章と同じ）：`date={1956-}`、欧文の報告書所収論文、TeX Live 2023 での再確認、texmf 側クローンと作業コピーの二重管理（フェーズC作業6）。要確認：著作権者名（Takuya MASUDA）、版（v1.0）、免責の文面、biblatex-jpa の作者への連絡。

## フェーズC 作業7：小さな未解決の解消（欧文の報告書所収論文、終了年のない範囲）
- `.gitignore`（`manual/.gitignore`）：一時ファイルは既に無視されていた。`*.fls`、`*.fdb_latexmk`、`*.synctex.gz`、`*.xdv`、`*.bak` を追加。
- **欧文の報告書所収論文**：テスト（guide の Lowe2003／Vance2003）を足して実際の出力を見たところ、「…, University of Fiction, Chicago: 12-30.」と、出版地の後に発行元がない形になっていた。`jsr.bbx` の `report:parent`／`incollection` を直し、「Chicago: University of Fiction, 12-30.」にした（`jsr@locdone` で出版地の重複出力を止める）。
- **終了年のない範囲**：「1956-」は「1956/」の誤記だった。`date={1956/}` は年の位置に「1956/」がそのまま出ていた（`labeldatesource` が空のため `\printlabeldateextra` が範囲全体を印刷する）。`jsr@printdateextra`（bbx、cbx から使用）で、終了年のフィールドが空のときは開始年と extradate だけを出すようにした。テスト C70 と文献リストの行を追加。a／b が付くこと、終了年のある範囲（1960/1970）が従来どおりなことは、別の小さな文書で確かめた（回帰テストには入れていない）。
- `../bib`：ブランチ `jsr-date-open-range` で `Saitama1956埼玉県議会史mv` の `date={1956-}` を `{1956/}` に直し、「埼玉県議会史編さん委員会編，1956，『埼玉県議会史』埼玉県議会．」と出ることを確かめた（main へのマージは確認後）。
- マニュアル：第2章に `1956/`、第4章に欧文の報告書所収論文と `1956/` の例を追加し、第7章の未解決から2件を外した。
- 確認：`tests/run-tests.sh` 全件一致、`manual/build.sh` 全項目合格。
- TeX Live 2023 での再確認：別の TeX Live をダウンロードして入れる必要があるため、行わないことにした（2026-10-24 ユーザー判断）。確認した版は TeX Live 2026（biblatex 3.22、biber 2.23 beta）のみ。
- texmf 側の写し（`~/Library/TinyTeX/texmf-local/tex/latex/jsr-biblatex`）：git の pull で更新できるので、当面はそのままにする（ユーザー判断）。

## フェーズC 作業6：texmf 側クローンの更新
- texmf-local の写しは git クローンで、push のあと pull して作業コピーと同じ内容（HEAD `8bdbcfb`、`jsr.bbx` の差分なし）になっていることを確認した。更新の手順を `CLAUDE.md`（作業6）に記録した。
