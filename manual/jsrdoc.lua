-- jsrdoc.lua --- jsr-biblatex マニュアルの検査用：ページごとの内容の左端・右端をログに出す。
-- manual/build.sh が JSRCHK／JSRGEO の行を読んで，余白の左右対称などを確かめる。
  jsrdoc = jsrdoc or {}
  local GLYPH, HLIST, VLIST, RULE, GLUE, KERN, MATH =
    node.id("glyph"), node.id("hlist"), node.id("vlist"), node.id("rule"),
    node.id("glue"), node.id("kern"), node.id("math")
  local xmin, xmax
  local function ink(a, b)
    if a > b then a, b = b, a end
    if not xmin or a < xmin then xmin = a end
    if not xmax or b > xmax then xmax = b end
  end
  local walk
  -- list: リストの先頭，parent: その箱，x: 箱の左端の絶対位置（sp），horizontal: 横組みか
  function walk(list, parent, x, horizontal)
    for n in node.traverse(list) do
      local id = n.id
      if horizontal then
        if id == GLYPH then
          ink(x, x + n.width); x = x + n.width
        elseif id == HLIST or id == VLIST then
          if n.width > 0 or n.head then walk(n.head, n, x, n.id == HLIST) end
          x = x + n.width
        elseif id == RULE then
          if n.width > 0 and n.width < 1073741823 and (n.height + n.depth) > 0 then ink(x, x + n.width) end
          if n.width > 0 and n.width < 1073741823 then x = x + n.width end
        elseif id == GLUE then
          x = x + node.effective_glue(n, parent)
        elseif id == KERN then
          x = x + n.kern
        elseif id == MATH then
          x = x + n.surround
        end
      else
        -- 縦組みの箱の中：子の箱は shift だけ横にずれる
        if id == HLIST or id == VLIST then
          walk(n.head, n, x + n.shift, n.id == HLIST)
        elseif id == RULE then
          if n.width > 0 and n.width < 1073741823 and (n.height + n.depth) > 0 then ink(x, x + n.width) end
        end
      end
    end
  end
  function jsrdoc.measure(b, page)
    xmin, xmax = nil, nil
    local x0 = tex.sp("1in") + tex.hoffset
    walk(b.head, b, x0, b.id == HLIST)
    if xmin then
      texio.write_nl("log", string.format("JSRCHK page=%d xmin=%.2f xmax=%.2f", page, xmin / 65536, xmax / 65536))
    end
  end
  -- 値は TeX から sp で渡す（\paperwidth などは LaTeX の長さで，tex.dimen からは読めない）
  function jsrdoc.geometry(paperwidth, textwidth, oddside, evenside, marglistwidth, parindent)
    texio.write_nl("log", string.format("JSRGEO paperwidth=%.2f textwidth=%.2f oddside=%.2f evenside=%.2f marglistwidth=%.2f parindent=%.2f",
      paperwidth / 65536, textwidth / 65536, oddside / 65536, evenside / 65536, marglistwidth / 65536, parindent / 65536))
  end

-- examples/*.bib から，指定したキーのエントリだけを抜き出して一時ファイルに書く
--   files: ファイル名（拡張子なし）のコンマ区切り，keys: キーのコンマ区切り，out: 出力ファイル
--   エントリは「@型{キー,」から，行頭の「}」までとする
function jsrdoc.extract(files, keys, out)
  local want = {}
  for k in keys:gmatch("[^,%s]+") do want[#want + 1] = k end
  local buf = {}
  for _, k in ipairs(want) do
    local found = false
    for f in files:gmatch("[^,%s]+") do
      local fh = io.open("examples/" .. f .. ".bib")
      if fh then
        local s = fh:read("*a"); fh:close()
        local a = s:find("@%w+{" .. k:gsub("%p", "%%%0") .. ",")
        if a then
          local b = s:find("\n}", a, true)
          buf[#buf + 1] = s:sub(a, b + 1)
          found = true
          break
        end
      end
    end
    if not found then
      texio.write_nl("log", "JSRERR example key not found: " .. k)
    end
  end
  local o = io.open(out, "w")
  o:write(table.concat(buf, "\n\n"), "\n")
  o:close()
end

-- 縦組みの箱（n 番の箱レジスタ）の，上端から 1 行目のベースラインまでの距離（sp）を返す。
--   最初の hlist（1 行目）の手前にある glue や kern を足し，その hlist の高さを加える。
function jsrdoc.firstbaseline(n)
  local b = tex.box[n]
  if not b or b.id ~= node.id("vlist") then return 0 end
  local y = 0
  for x in node.traverse(b.head) do
    if x.id == node.id("hlist") then
      return y + x.height
    elseif x.id == node.id("glue") then
      y = y + node.effective_glue(x, b)
    elseif x.id == node.id("kern") then
      y = y + x.kern
    end
  end
  return 0
end
