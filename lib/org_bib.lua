local bibliography = pandoc.List()

local function is_linebreak(item)
  return not item or item.t == 'SoftBreak'
end

function Para (p)
  for i, inln in ipairs(p.content) do
    local str = pandoc.utils.stringify(inln)
    if is_linebreak(p.content[i-1]) and is_linebreak(p.content[i+1]) then
      local bib = str:match 'bibliography:(.+)'
      if bib then
        bibliography:insert(bib)
        -- remove paragraph
        return {}
      end
    end
  end
end

function Meta (meta)
  meta.bibliography = bibliography
  return meta
end
