-- 組版された各行を <jobname>.layout.txt に書き出す（回帰テスト layout 用）。
-- 1 行 1 段落。文字は U+0020 を含めてそのまま、グルーは <幅pt> で書く（check-layout.py が読む）。
-- 文字を 1 つも含まない行は "<empty>" とする。
local GLYPH = node.id("glyph")
local GLUE  = node.id("glue")
local HLIST = node.id("hlist")
local VLIST = node.id("vlist")
local DISC  = node.id("disc")

local out = io.open(tex.jobname .. ".layout.txt", "w")

local function decompose(c)
  return (c >= 0xE000 and c <= 0xF8FF) or (c >= 0xFB00 and c <= 0xFB06)
end

local function collect(head, buf)
  for n in node.traverse(head) do
    local id = n.id
    if id == GLUE then
      if n.width ~= 0 then buf[#buf + 1] = string.format("<%.2f>", n.width / 65536) end
    elseif id == GLYPH then
      if n.components and decompose(n.char) then
        collect(n.components, buf)
      else
        buf[#buf + 1] = utf8.char(n.char)
      end
    elseif id == HLIST or id == VLIST then
      collect(n.head, buf)
    elseif id == DISC then
      collect(n.replace, buf)
    end
  end
end

luatexbase.add_to_callback("post_linebreak_filter", function(head)
  for line in node.traverse_id(HLIST, head) do
    local buf = {}
    collect(line.head, buf)
    local s = table.concat(buf)
    if not s:find("[^<>%d%.%-]") then s = "<empty>" end
    out:write(s, "\n")
  end
  return true
end, "jsr-test-layoutdump")
