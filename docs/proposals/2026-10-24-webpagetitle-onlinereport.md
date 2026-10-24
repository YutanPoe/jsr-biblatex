# 提案：webpagetitle と type=onlinereport を標準の書き方に置き換える（2026-10-24、Claude Code）

フェーズC 作業5（残り）。bib の書き方が変わるため、選択肢と決定を残す。

## 1. 現状
- **`webpagetitle`**：ウェブサイト名・ブログ名のための独自フィールド（jsr.dbx で宣言）。`online` と `report` のドライバが、書名の後に出す。
- **`type=onlinereport`**：`@report` に付ける目印。report ドライバが、これがあるとき ①書名を『』でなく「」にする ②種類（type）を出さない。
- bib の方針（CLAUDE.md）：bib を jsr 固有の仕組みに依存させない。和書bib工房の既知フィールド一覧にも、Zotero の書き出しにも、`webpagetitle` はない。

## 2. 選択肢と決定

### ウェブサイト名・ブログ名
| 案 | 内容 | 判断 |
|---|---|---|
| **A. `titleaddon`** | `@online` の標準フィールド。Zotero はウェブサイト名・ブログ名をここに書き出す。和書bib工房の既知フィールドに含まれる。 | **採用** |
| B. `organization` | `@online` の標準フィールドだが、欧文の「所在地: 運営機関名」に既に使っている。ブログ名と運営機関の両方を持つ例を書き分けられない。 | 不採用 |
| C. `webpagetitle` のまま | bib は変わらないが、標準のデータモデルに依存しない方針に反する。 | 不採用 |

実装上の注意：jsr の `title` マクロは `titleaddon` を書名の「」の中に出す。`online` ドライバでは、`titleaddon` を退避して消し、書名の後にサイト名として出す。

### オンラインで取得した報告書
| 案 | 内容 | 判断 |
|---|---|---|
| **A. `@online` で書く** | ガイド 4.5.3 は、PDF の報告書（Johns Hopkins University 2003）をウェブ文書として載せている。目印を使わず `@online`＋`organization` にする。 | **採用** |
| B. `@report` の urldate で自動判定 | 紙で読んだ報告書にも取得日を付ける運用だと、意図せず形が変わる。 | 不採用 |
| C. `type=onlinereport` を残す | bib は変わらないが、type に目印を入れる転用が残る。 | 不採用 |

### 旧形式の扱い
当面そのまま読めるようにし、警告を出す（次の版で警告を外す）。biber の sourcemap で読み替える。
- `webpagetitle` → `titleaddon`
- `@report`＋`type=onlinereport` → `@online`（`institution` → `organization`、`type` は消す）

警告は組版時に `jsr: entry '…' uses deprecated '…'` と出る。読み替えの前に、印のフィールド `jsrlegacy`（jsr.dbx で宣言）を付けて検出する（`jsrnosortname` と同じ方式）。

## 3. bib の書き換え
| 旧 | 新 |
|---|---|
| `webpagetitle = {国立国会図書館 電子展示会}` | `titleaddon = {国立国会図書館 電子展示会}` |
| `@report{…, institution={X}, type={onlinereport}, …}` | `@online{…, organization={X}, …}` |

## 4. 注意
- `@online` の和文では `organization`（旧 `institution`）は出ない（ガイドの和文のウェブページに運営機関名の欄がないため）。欧文では「所在地: 運営機関名」として出る。
- 旧形式の report では、和文のオンライン報告書にも研究機関名（institution）が出ていた。`@online` にすると出なくなる。必要なら著者名かサイト名に書く。
