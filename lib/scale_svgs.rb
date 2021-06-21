class ScaleSVGsFilter < Nanoc::Filter
  identifier :scale_svgs

  def run(content, params = {})
    content.sub(/width="([\d\.]+)pt"/) { |m| "width=\"#{params[:scale]*Float($1)}pt\"" }
      .sub(/height="([\d\.]+)pt"/) { |m| "height=\"#{params[:scale]*Float($1)}pt\"" }
  end
end
