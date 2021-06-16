use_helper Nanoc::Helpers::Tagging
use_helper Nanoc::Helpers::Blogging
use_helper Nanoc::Helpers::Breadcrumbs
use_helper Nanoc::Helpers::Rendering
use_helper Nanoc::Helpers::LinkTo
use_helper Nanoc::Helpers::Filtering

def tags
  if @item[:tags].nil?
    '(none)'
  else
    @item[:tags].join(', ')
  end
end

def slug
  @item.path[1...-1].gsub(/\//, "-")
end
