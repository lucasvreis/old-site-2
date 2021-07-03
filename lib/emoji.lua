-- Tool for converting :smile: emojis into <i class="twa twa-smile"></i>

function Str (p)
  if p.text:find('^:[^:]*:$') then
    return pandoc.RawInline("html", "<i class=\"twa twa-"..p.text:sub(2,-2).."\"></i>")
  end
end
