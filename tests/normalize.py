#!/usr/bin/env python3
"""pdftotext の出力を、期待値ファイルと比べられる形に整える。

- 空行を除き、各行の前後の空白を落とす
- 和文文字（約物を含む）に隣接する空白を除く
  （和欧間の自動スペースや、行揃えで pdftotext が入れた空白を消すため）
- URL 内に入り込んだ空白を除く
- 引用符・アポストロフィの字形をそろえる
"""
import re
import sys

CJK = (
    r"　-〿"  # 和文の約物
    r"぀-ヿ"  # かな
    r"㐀-鿿"  # 漢字
    r"＀-￯"  # 全角英数・約物
    r"—―‥…"  # ダッシュ、三点リーダ
    r"〈-】"  # 括弧類
)
CJK_SPACE = re.compile(rf"\s+(?=[{CJK}])|(?<=[{CJK}])\s+")
URL = re.compile(r"h\s*t\s*t\s*p\s*s?\s*:\s*/\s*/[^，）)]*")


def normalize(line: str) -> str:
    line = line.strip()
    line = line.replace("’", "'").replace("‘", "‘")
    line = URL.sub(lambda m: re.sub(r"\s+", "", m.group(0)), line)
    line = CJK_SPACE.sub("", line)
    line = re.sub(r"\s+", " ", line)
    return line


def main() -> None:
    text = open(sys.argv[1], encoding="utf-8").read()
    for raw in text.splitlines():
        if raw.startswith("#"):  # 期待値ファイルの注釈行
            continue
        line = normalize(raw)
        if line:
            print(line)


if __name__ == "__main__":
    main()
