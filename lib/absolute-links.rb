class AbsoluteLinksFilter < Nanoc::Filter
  identifier :fix_links

  def run(content, params = {})
    content.gsub(/(href|src)="http:(.*?)"/, "\\1=\"#{params[:link]}\\2\"")
  end
end
