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
