require 'yaml'

def get_comments
  if @item[:uuid]
    @items.find_all("/data/comments/#{ @item[:uuid] }/*")
  else
    []
  end
end
