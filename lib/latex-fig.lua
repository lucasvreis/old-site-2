--[[
diagram-generator – create images and figures from code blocks.

This Lua filter is used to create images with or without captions
from code blocks. Currently PlantUML, GraphViz, Tikz, and Python
can be processed. For further details, see README.md.

Copyright: © 2018-2021 John MacFarlane <jgm@berkeley.edu>,
             2018 Florian Schätzig <florian@schaetzig.de>,
             2019 Thorsten Sommer <contact@sommer-engineering.com>,
             2019-2021 Albert Krewinkel <albert+pandoc@zeitkraut.de>
License:   MIT – see LICENSE file for details
]]
-- Module pandoc.system is required and was added in version 2.7.3
PANDOC_VERSION:must_be_at_least '2.7.3'

local system = require 'pandoc.system'
local utils = require 'pandoc.utils'
local stringify = utils.stringify
local with_temporary_directory = system.with_temporary_directory
local with_working_directory = system.with_working_directory

local pdf2svg_path  = os.getenv("PDF2SVG")  or "pdf2svg"
local pdflatex_path = os.getenv("PDFLATEX") or "pdflatex"

-- The default format is SVG i.e. vector graphics:
local filetype = "svg"
local mimetype = "image/svg+xml"

-- This will join all preambles in the file
local preamble = ""

local prefix = "content"
local path = "/media/"

--
-- TikZ
--

--- LaTeX template used to compile TikZ images. Takes additional
--- packages as the first, and the actual TikZ code as the second
--- argument.
local tikz_template = [[
\documentclass[varwidth]{standalone}
\usepackage{tikz}
%% begin: additional packages
%s
%% end: additional packages
\begin{document}
%s
\end{document}
]]

-- Returns a function which takes the filename of a PDF or SVG file
-- and a target filename, and writes the input as the given format.
-- Returns `nil` if conversion into the target format is not possible.
local function convert_with_pdf2svg (pdf_file, outfile)
  local pdf2svg_command = string.format(
    '"%s" "%s" "%s"',
    pdf2svg_path,
    pdf_file,
    outfile
  )
  local command_output = io.popen(pdf2svg_command)
  command_output:close()
end

--- Compile LaTeX with Tikz code to an image
local function tikz2image(src, filetype)
  return with_temporary_directory("tikz2image", function (tmpdir)
    return with_working_directory(tmpdir, function ()
      -- Define file names:
      local file_template = "%s/tikz-image.%s"
      local tikz_file = file_template:format(tmpdir, "tex")
      local pdf_file = file_template:format(tmpdir, "pdf")
      local outfile = file_template:format(tmpdir, filetype)

      -- Build and write the LaTeX document:
      local f = io.open(tikz_file, 'w')
      f:write(tikz_template:format(preamble or '', src))
      f:close()

      -- Execute the LaTeX compiler:
      pandoc.pipe(pdflatex_path, {'-output-directory', tmpdir, tikz_file}, '')

      convert_with_pdf2svg(pdf_file, outfile)

      -- Try to open and read the image:
      local img_data
      local r = io.open(outfile, 'rb')
      if r then
        img_data = r:read("*all")
        r:close()
      else
        -- TODO: print warning
      end

      return img_data
    end)
  end)
end

-- Executes each document's code block to find matching code blocks:
function RawBlock(block)

  -- If block is part of it, add to preamble
  if block.c[1] == "latex" then
    local match, _, rest = string.find(block.text, "^%%%% PREAMBLE %%%%\n?(.*)")
    if match then
      preamble = preamble .. rest
      return nil
    end
  end

  -- Using a table with all known generators i.e. converters:
  local converters = {
    latex = tikz2image,
  }

  -- Check if a converter exists for this block. If not, return the block
  -- unchanged.
  local img_converter = converters[block.c[1]]
  if not img_converter then
    return nil
  end

  -- Create figure name by hashing the block content
  local fname = pandoc.sha1(tikz_template:format(preamble or '', block.text)) .. "." .. filetype

  local f = io.open(prefix .. path .. fname, "r")
  if f ~= nil then
    -- If file was already processed, skip
    io.close(f)
  else
    -- Call the correct converter which belongs to the used class:
    local success, img = pcall(img_converter, block.text, filetype)

    -- Bail if an error occured; img contains the error message when that
    -- happens.
    if not (success and img) then
        io.stderr:write(tostring(img or "no image data has been returned."))
        io.stderr:write('\n')
        io.stderr:write(block.text, 'n')
        error 'Image conversion failed. Aborting.'
    end

    -- If we got here, then the transformation went ok and `img` contains
    -- the image data.

    -- Now we save the image in disk
    local file, err = io.open(prefix .. path .. fname, 'w+')
    if err then print(err) else
      file:write(img)
      io.close(file)
    end
  end

  -- If the user defines a caption, read it as Markdown.
  local caption = {}

  -- A non-empty caption means that this image is a figure. We have to
  -- set the image title to "fig:" for pandoc to treat it as such.
  local title = #caption > 0 and "fig:" or ""

  -- Transfer identifier and other relevant attributes from the code
  -- block to the image. Currently, only `name` is kept as an attribute.
  -- This allows a figure block starting with:
  --
  --     ```{#fig:example .plantuml caption="Image created by **PlantUML**."}
  --
  -- to be referenced as @fig:example outside of the figure when used
  -- with `pandoc-crossref`.
  local img_attr = {
    id = block.identifier,
    class = 'tikzfig'
  }

  -- Create a new image for the document's structure. Attach the user's
  -- caption. Also use a hack (fig:) to enforce pandoc to create a
  -- figure i.e. attach a caption to the image.
  local img_obj = pandoc.Image(caption, path .. fname, title, img_attr)

  -- Finally, put the image inside an empty paragraph. By returning the
  -- resulting paragraph object, the source code block gets replaced by
  -- the image:
  return pandoc.Para{ img_obj }
end

function RawInline(block)

  -- Using a table with all known generators i.e. converters:
  local converters = {
    latex = tikz2image,
  }

  -- Check if a converter exists for this block. If not, return the block
  -- unchanged.
  local img_converter = converters[block.c[1]]
  if not img_converter then
    return nil
  end

  -- Create figure name by hashing the block content
  local fname = pandoc.sha1(tikz_template:format(preamble or '', block.text)) .. "." .. filetype

  local f = io.open(prefix .. path .. fname,"r")
  if f ~= nil then
    -- If file was already processed, skip
    io.close(f)
  else
    -- Call the correct converter which belongs to the used class:
    local success, img = pcall(img_converter, block.text, filetype)

    -- Bail if an error occured; img contains the error message when that
    -- happens.
    if not (success and img) then
        io.stderr:write(tostring(img or "no image data has been returned."))
        io.stderr:write('\n')
        io.stderr:write('\n', block.text, '\n\n')
        error 'Image conversion failed. Aborting.'
    end

    -- If we got here, then the transformation went ok and `img` contains
    -- the image data.

    -- Now we save the image in disk
    local file, err = io.open(prefix .. path .. fname, 'w+')
    if err then print(err) else
      file:write(img)
      io.close(file)
    end
  end

  local img_attr = {
    id = block.identifier,
    class = 'tikzfig inl'
  }

  -- Create a new image for the document's structure. Attach the user's
  -- caption. Also use a hack (fig:) to enforce pandoc to create a
  -- figure i.e. attach a caption to the image.
  local img_obj = pandoc.Image({},  path .. fname, '', img_attr)

  return img_obj
end

-- Normally, pandoc will run the function in the built-in order Inlines ->
-- Blocks -> Meta -> Pandoc. We instead want Meta -> Blocks. Thus, we must
-- define our custom order:
return {
  {Meta = Meta},
  {RawBlock = RawBlock},
  {RawInline = RawInline}
}
