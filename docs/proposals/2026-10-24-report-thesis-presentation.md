# 提案：報告書・政府刊行物・学位論文・学会報告の見直し（2026-10-24、claude.ai 側で作成）

対象：ガイド 4.4(8) 調査報告書、(9) 政府刊行物、(10) 修士論文・学会報告原稿。欧文の規定はガイドにないので、ガイドの方針（稀なケースは ASA を参照）に従って案を出す。
確認は、境界的なエントリ12件を組んで行った（フェーズB版。report／thesis／inproceedings ドライバは C-0 でも変わっていない）。

## 0. 先に直すバグ（判断不要）
- **文書中に a、b の付く文献が1つもないと、エラーが出る。** フェーズBで入れた extradate の振り直しで、未定義のリストを etoolbox のループに渡していた（`\relax` が項目として処理される）。ガイドのテストと test.tex には a、b が必ずあったため見逃していた。
- 修正：`docs/proposals/2026-10-24-fix-empty-lists.patch`（`git apply` で当たることを確認済み）。未定義のリストを飛ばすラッパー `\jsr@forlistcs`／`\jsr@dolistcs` を使う。
- 回帰テストに「a、b がない文書」を追加すること（`tests/` に小さな2つ目の文書を足す。guide.tex は a、b を含むので、これ1つでは検出できない）。

## 1. 現状の出力とガイドのずれ

| ケース | 現状の出力 | ガイド・あるべき形 |
|---|---|---|
| 科研報告書（代表者のみ） | 神原文子，1999，『…』1996-1998年度科学研究費補助金研究成果報告書（08451041），相愛大学． | 一致 |
| 科研報告書（分担者あり＝代表者「編」） `editor` に代表者 | **金沢大学文学部，1997，『…』…報告書（07610123）．**（編者が消え，機関名が先頭。文献注は「碓井編 1997」なので食い違う） | 碓井崧編，1997，『…』…報告書（07610123），金沢大学文学部． |
| 報告書所収の論文（ガイド自身の文献リストにある岩本 1997） | 岩本健良，1997，「…」碓井崧編『地域組織とネットワーク』89-103．（報告書の種類と機関名を書く場所がない） | 岩本健良，1997，「…」碓井崧編『…』1995-1996年度科学研究費補助金研究成果報告書，金沢大学文学部，89-103． |
| 政府刊行物（白書） | 一致（国立印刷局・編集機関と同じ発行元は省略） | 一致 |
| 欧文の報告書 `type=techreport`、`number` | Smith, John, 2005, Test Technical Report, Chicago: University of Chicago.（種類と番号が出ない） | 例：…, Test Technical Report, Technical Report TR-12, Chicago: University of Chicago. |
| 修士論文 `type=mathesis`（biblatex 標準のキー） | 「テスト修士論文」東京大学大学院人文社会系研究科**修論**．（日本語の文字列が略語） | …研究科修士論文．（「○○年度」は type に文字で書く運用も残す） |
| 欧文の博士論文 `type=phdthesis` | “A Test Dissertation,” **(PhD thesis)**, University of Wisconsin-Madison. | ASA：PhD dissertation, University of …（括弧なし） |
| 学会報告 `eventtitle`＋`type=報告原稿` | 「テスト報告」**[報告原稿]，**第94回日本社会学会大会．（ガイドの形は eventtitle に「報告原稿」まで書いたときだけ） | 「テスト報告」第94回日本社会学会大会報告原稿． |
| 欧文の学会報告 `eventtitle`、`venue`、`eventdate` | “A Test Paper,” Annual Meeting of the American Sociological Association.（開催地・日付が出ない） | ASA：Paper presented at the Annual Meeting of …, August 22, Chicago, IL. |
| 刊行された予稿集の論文 `@inproceedings`＋`booktitle`、`editor`、`publisher` | “Proceedings Paper,” Proceedings of the Test Conference, 10-20.（編者・出版地・出版社が消える） | 編書論文（incollection）と同じ形 |
| `@unpublished`（未公刊の報告） | 佐藤一郎，「未公刊報告」，第92回日本社会学会大会．（**年が出ない**。専用ドライバがない） | 佐藤一郎，2019，「未公刊報告」第92回日本社会学会大会報告原稿． |

## 2. 改善案

### A. report（判断はほぼ不要。出力が変わるのは不具合の修正にあたる）
1. 先頭の名前は author → editor（「編」）→ institution の順に選ぶ。editor を先頭に出したときは、institution を後ろ（研究機関名）に出す。
2. 欧文でも type（キーなら bibstring、文字ならそのまま）と number を出す。
3. 報告書所収の論文：`@incollection` に `crossref` で親の `@report` を指す書き方を正式に支える。スタイル側で `\DeclareDataInheritance{report}{incollection,inbook}`（title→booktitle、type・number・institution を継承）を宣言し、incollection ドライバは type／number／institution があれば書名の後に出す。bib は標準のデータモデルのまま書ける。
4. `type=onlinereport` の扱いはフェーズC の作業5（`webpagetitle` の置き換え）と合わせて決める。

### B. thesis（判断：欧文の書き方）
1. lbx の文字列を `mathesis`＝修士論文、`phdthesis`＝博士論文 にする（欧文は MA thesis／PhD dissertation など）。
2. 欧文は括弧をやめ、`“Title,” PhD dissertation, Department, University.` の形にする（ASA 準拠）。**要判断：「PhD dissertation」「Ph.D. dissertation」「PhD thesis」のどれにするか。**
3. 和文は今のまま「（type）を機関名の後に続ける」形。「2019年度修士論文」のように年度を書きたい場合は、type に文字で書く運用を README に書く。

### C. 学会報告（判断：エントリ型の使い分け、欧文の書き方）
biblatex の `@inproceedings` は本来「刊行された予稿集の論文」で、未刊行の口頭報告は `@unpublished`（eventtitle、venue、eventdate を持てる）で書くのが標準に近い。そこで：
1. `@inproceedings`：booktitle があれば予稿集の論文として、incollection と同じ形で出す。booktitle がなく eventtitle だけなら、学会報告として扱う（今の bib との互換のため）。
2. `@unpublished`：学会報告の専用ドライバを作る。
   - 和文：報告者名，年，「題」eventtitle＋type．（type の既定は「報告原稿」にするか空にするか：**要判断**）
   - 欧文（ASA 準拠）：Author, year, “Title,” Paper presented at the eventtitle, eventdate, venue.（**要判断：この形でよいか**）
3. 年は date（なければ eventdate）を使う。ガイドは「大会開催年」。

## 3. 進め方の提案
1. 0 のバグ修正（パッチ）とテスト追加 → コミット。
2. A（report）を実装。出力が変わるのは不具合の修正なので、そのまま進めてよい。
3. B・C は要判断の点をユーザーに確認してから実装。テストのケース（上の表の各行）を guide.bib／guide.tex／guide.expected.txt に足す。
