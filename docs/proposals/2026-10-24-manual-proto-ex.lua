-- examples/*.bib から，指定したキーのエントリを抜き出して一時ファイルに書く
jsrex = {}
function jsrex.extract(files, keys, out)
  local want = {}
  for k in keys:gmatch("[^,%s]+") do want[#want+1] = k end
  local buf = {}
  for _, k in ipairs(want) do
    for f in files:gmatch("[^,%s]+") do
      local fh = io.open("examples/" .. f .. ".bib")
      if fh then
        local s = fh:read("*a"); fh:close()
        local a = s:find("@%w+{" .. k:gsub("%p","%%%0") .. ",")
        if a then
          local b = s:find("\n}", a, true)
          buf[#buf+1] = s:sub(a, b + 1)
        end
      end
    end
  end
  local o = io.open(out, "w"); o:write(table.concat(buf, "\n\n"), "\n"); o:close()
end
