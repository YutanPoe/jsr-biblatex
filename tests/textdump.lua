-- 組版された各行の文字列を <jobname>.lines.txt に書き出す（回帰テスト用）。
-- 紙面を横に広くしてあるので、1 段落（文献注 1 つ、文献 1 つ）が 1 行になる。
local GLYPH = node.id("glyph")
local GLUE  = node.id("glue")
local HLIST = node.id("hlist")
local VLIST = node.id("vlist")
local DISC  = node.id("disc")

local out = io.open(tex.jobname .. ".lines.txt", "w")

-- 構成文字に戻す合字：私用領域、および U+FB00–FB06（ff, fi, fl, ffi, ffl など）
local function decompose(c)
  return (c >= 0xE000 and c <= 0xF8FF) or (c >= 0xFB00 and c <= 0xFB06)
end

local function collect(head, buf, state)
  for n in node.traverse(head) do
    local id = n.id
    if id == GLUE then
      -- 連続するグルーは合計し、正の幅のときだけ 1 つの空白とみなす
      state.glue = state.glue + n.width
    else
      if id == GLYPH or id == HLIST or id == VLIST or id == DISC then
        if state.glue > 65536 then buf[#buf + 1] = " " end
        state.glue = 0
      end
      if id == GLYPH then
        if n.components and decompose(n.char) then
          collect(n.components, buf, state)
        else
          buf[#buf + 1] = utf8.char(n.char)
        end
      elseif id == HLIST or id == VLIST then
        collect(n.head, buf, state)
      elseif id == DISC then
        collect(n.replace, buf, state)
      end
    end
  end
end

luatexbase.add_to_callback("post_linebreak_filter", function(head)
  for line in node.traverse_id(HLIST, head) do
    local buf, state = {}, { glue = 0 }
    collect(line.head, buf, state)
    out:write(table.concat(buf), "\n")
  end
  return true
end, "jsr-test-textdump")
