# 決定事項（ユーザー確認済み）

claude.ai のプロジェクト文書「jsr-biblatex-課題整理.md」から写したもの。新しい決定はここに日付つきで追記する。

## 文献リスト
- **原典の二重掲載（B-1）**：訳書・再録が引用されたら、原典は単独の項目に出さず、原典の項目に訳書・再録を添える。原典だけが引用されたら単独で出す。
- **同じ原典の再録と翻訳をともに引用した場合は1項目にまとめる**（2026-10-24）。添え物は年順。
- **再刊と再録**：原典が書籍でタイトル・サブタイトルが同じなら「[初版年] 手元の版年」（ガイド 4.2(7)）。原典が論文、またはタイトルが変わった再刊は「（再録：…）／Reprinted in:」（4.4(7)／4.2(8)）。原典と同じ著者・タイトルは省き、著者を省いたら編者を先頭に出す。
- **並び順**：同一著者は単著→単独編書→共著→共編書、各カテゴリ内は年順（原典の年 origdate を優先）。
- **a、b**：同一著者の同一カテゴリーの同一年度だけに付ける（`小田 1991` と `小田編 1991` には付けない）。訳書は原典の年で判定。
- **ページ範囲**：半角ハイフン、重複する位は省略（102-4）。
- **発行元の自動省略**：著者・編者・機関名と同じ、または国立印刷局のとき省く。
- **series（B-3）**：和文だけ書名の前に出す（『講座社会学 12 環境』）。欧文では出さない。
- **雑誌論文の publisher（B-4）**：欧文では出さず、和文では出す。
- **新聞・雑誌の日付（B-5）**：文献リストは `1958年8月10日朝刊`。文献注は `1998.11.3`。
- **ブログの記事作成日（B-8）**：date に日まであれば出す。
- **カタカナ外国人名（B-9）**：「名・姓」、リストの区切りは全角スラッシュ（杉本良夫／ロス・マオア）。文献注にも適用。
- **欧文タイトルの大文字化（B-14）**：データ側の責任。自動化しない。

## 文献注
- **初出はフルネーム**（`firstfull`、既定 ON）：人物単位で判定。共著は名前リスト全体で1単位。割注（parencite）は言及に数えない。
- **3名以上**：割注も本文中の引用も「ほか」「et al.」（B-10）。
- **原書と訳書の両方のページ（B-12）**：`\parencite[78=86]{訳書}` →（Goffman 1961a: 78=1984: 86）。
- 著者のいない報告書の割注は機関名。

## 言語の扱い
- **2026-10-24 未読み込みの言語の判定（C-0）**：`langid` が文書に読み込まれていない言語（french など）の欧文は american で組む。方針は従来どおり。判定方式を替えた。
  - 従来は `date<言語>` の有無で判定していた。新しい babel（26.11）は、未読み込みの言語も `\select@language` の中で読み込むため、この判定が効かなくなった。
  - 現在は、プリアンブル終了時の言語一覧（`\jsr@doclangs`。babel の `\bbl@loaded`／`\bbl@ini@loaded`、polyglossia の `\xpg@bloaded`）に `langid` があるかで判定する。
  - 一覧にない言語の項目は `langid` を消す。`checkLang` は biblatex の autolang（`\blx@beglang`）より前に動くので、`\selectlanguage` だけでは、あとから `langid` の言語に上書きされるため。

## 2026-10-24 追加（提案書 report-thesis-presentation／misc-review への回答）
提案書：`docs/proposals/2026-10-24-report-thesis-presentation.md`（以下「提案1」）、`docs/proposals/2026-10-24-misc-review.md`（以下「提案2」）。

### 学位論文・学会報告（提案1 の B・C）
- 欧文の博士論文（type=phdthesis）は **PhD dissertation**（ASA）。括弧は付けない：Doe, Jane, 2012, “Title,” PhD dissertation, University of …
- 和文の学会報告で type を書かなかったときは **「報告原稿」を補わない**（「題」第94回日本社会学会大会．）。type を書いたときだけ eventtitle の後に続ける。
- 欧文の学会報告は **ASA 式**：Roe, Ann, 2015, “A Test Paper,” Paper presented at the Annual Meeting of the American Sociological Association, August 22, Chicago, IL.

### 提案2 の A〜F
- **A. DOI**：**オプションで出せるようにする**（例：`doi=true`。既定は false＝取得日がある場合だけ「（取得日，https://doi.org/…）」を出す今の動作）。オプション名と、取得日がないときの書式は実装時に提案する。
- **B. 電子書籍**：紙版の刊行年・出版社は `origdate`＋`origpublisher`（＋`origlocation`）で表し、『タイトル』（2005，日本放送出版協会刊）の形にする。`origpublisher` があるときは再刊の [初版年] 形式にしない。フォーマット（Kindle版、Available on CD-ROM only）は **`note`** に書き、末尾の括弧に出す（今の「note＝紙版の情報」の運用は改める）。
- **C. 原典のエントリがない訳書**（translator あり、related なし）：**著者を先頭**にし、訳者は書名の後に置く（ベック，U.，1998，『危険社会』東廉・伊藤美登里監訳，法政大学出版局．）。origdate があれば文献注は **（ベック 1986=1998）**。README で原典のエントリを作って related でつなぐ書き方を推奨する。
- **D. 新聞記事**：新聞・雑誌の判定は標準の `entrysubtype`（newspaper／magazine）で行い、`type=newspaper` も互換のため当面受け付ける。朝刊・夕刊は `issue`、版・地域版（第14版、全国版、○○県版）は **`note`**。欧文の署名記事は ASA 式で、ページの前に **p. を付ける**：Smith, Tom, 1998, “Test News,” The New York Times, November 3, p. A1.
- **E. コンピュータファイル（MRDF）**：`@dataset` に専用ドライバ。データ形式＝`type`（MRDF）、提供機関＝**`publisher`**（作成者と同じなら発行元の自動省略の仕組みを使う）、入手先＝**`howpublished`**。
- **F. \footcite**：**今のまま**（biblatex の既定）。README で \parencite／\textcite を使うよう案内する。

## 報告書（提案1 A、2026-10-24 実装）
- **先頭の名前**：author → editor（「編」を付ける）→ institution の順。editor を先頭に出したときは、研究機関名（institution）を課題名・種類・番号の後に出す。institution を先頭に出したときは、後ろで繰り返さない。
- **欧文の種類と番号**：`Technical Report TR-12`（type と number を空白でつなぐ）。type が bibstring のキー（techreport）のときは、略さず `Technical Report` と出す（american／english／british の jsr.lbx で上書き）。
- **報告書所収の論文**：`@incollection` に `crossref` で親の `@report` を指す。親の title／subtitle は booktitle／booksubtitle として引き継ぐ（`\DeclareDataInheritance` は bbx に書く。dbx の読み込み時には使えない）。親から引き継いだ institution があるときだけ、書名の後に type、（number）、institution を出す。

## 判断不要の修正（提案2 #1〜#5、2026-10-24 実装）
- **#1 和文書籍の edition**：書名の中、書名の後に半角スペースで区切る。数字なら「第n版」（`prenumber`＋数字＋`edition` の bibstring）、文字ならそのまま：『社会学入門 第2版』『社会学入門 新版』。多巻本は書名の後（巻の前）。奥付どおりに「2版」などと出したいときは、edition に文字で書く。
- **#2 欧文の編書論文の edition**：所収書名の後に `2nd ed.`。
- **#3 book／incollection の URL と取得日**：末尾に（取得日，URL）。urldate があるときだけ出す（url だけの書誌 URL は出さない）。
- **#4 ドライバのないエントリ型**：booklet／manual／reference／proceedings／bookinbook→book、inreference／suppbook／suppcollection→incollection、mvreference／mvproceedings→mvbook、software／patent／dataset→article（dataset は提案2 E で専用ドライバに替える）、unpublished→inproceedings（提案1 C で専用ドライバに替える）。
- **#5 sortname の書き忘れ**：和文（CJK）で著者・編者がいるのに sortname がない文献は、組版時に警告を出す（`jsr: entry '…' has no sortname`）。sortname は bbl に出力されないので、sourcemap で印のフィールド `jsrnosortname`（jsr.dbx で宣言）を付けて検出する。

## 学位論文・学会報告（提案1 B・C、2026-10-24 実装）
- **学位論文**：type が bibstring のキーなら lbx の文字列で出す。和文は「修士論文」「博士論文」（略さない）。欧文は `MA thesis`／`PhD dissertation`。欧文は括弧を付けない：Doe, Jane, 2012, “Title,” PhD dissertation, University of …。type に文字で書く運用（「2019年度修士論文」）は従来どおり。
- **学会報告**（`@inproceedings` の booktitle なし、`@unpublished`）：
  - 和文：「題」eventtitle＋type。type を書いたときだけ eventtitle の後に続ける。
  - 欧文（ASA）：Paper presented at the eventtitle, 月 日, venue.。開催日は eventdate の月日（年は著者の後に出している）。「Paper presented at the」は bibstring `paperpresented`（全言語の jsr.lbx に定義）。type を書くと、type で置き換える（Poster presented at the など）。
- **予稿集の論文**（`@inproceedings` に booktitle がある）は、編書論文と同じ形で出す。eventtitle と type は出ない。

## DOI と MRDF（提案2 A・E、2026-10-24 実装）
- **A. DOI**：オプション名は biblatex 標準の `doi`（jsr の既定は `doi=false`）。既定では、取得日（urldate）があるときだけ「（取得日，DOI／URL）」を出す。`doi=true` にすると、取得日がなくても DOI だけを（DOI）の形で出す：…71(1): 1-10，（https://doi.org/…）．／…, 3(2): 5-15, (https://doi.org/…).。
- **E. MRDF**：`@dataset` に専用ドライバ。データ形式＝`type`、提供機関＝`publisher`、入手先＝`howpublished`。
  - 和文：作成者，年，『名称』[MRDF]，提供機関，入手先．
  - 欧文：Author, year, Title[MRDF], 所在地: 提供機関 [producer]. 入手先．（「producer」は bibstring。入手先は howpublished に「所在地: 名称 [distributor]」まで書く）
  - **提供機関が作成者と同じでも省かない**（ガイド 4.5.4.2 の例が省いていないため。2026-10-24 の「作成者と同じなら自動省略」の決定から変更。省略したいときは、publisher を書かなければよい）。

## 電子書籍と単独の訳書（提案2 B・C、2026-10-24 実装）
- **B. 電子書籍**：紙媒体の刊行年・出版社は `origdate`＋`origpublisher` で書く。書名の後に和文は（2005，日本放送出版協会刊）、欧文は (2005, 所在地: 出版社)（所在地は `origlocation`。和文では出さない）。`origpublisher` があるときは再刊の [初版年] の形にしない（リストも文献注も）。フォーマット（Kindle版、Available on CD-ROM only）は `note` に書き、末尾の括弧に出す。取得日・URL がある場合は（取得日，URL）の後に続ける。「刊」はコードに書いてある（bibstring 化はフェーズC 作業2）。並び順は紙版の年（origdate）が優先される。
- **C. 原典のエントリがない訳書**（translator あり、related なし、author あり）：著者を先頭にし、訳者は書名の後（版の後）に置く。原典の年は出さない：ウルリッヒ・ベック，1998，『危険社会』東廉・伊藤美登里監訳，法政大学出版局．／Beck, Ulrich, 1992, Risk Society, Mark Ritter, trans., London: Sage.。文献注は origdate があれば（ベック 1986=1998）。原典に添える訳書（添え物）と、著者のいない訳書は、従来どおり訳者が先頭。原典のエントリを作って related でつなぐ書き方が推奨。
- **sortname の警告**：`crossref`／`xref` で親から継承する項目は対象外（継承前の段階では sortname が見えず、誤検出になるため）。
