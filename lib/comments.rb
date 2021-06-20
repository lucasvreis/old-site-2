require 'yaml'

def get_comments
  comments = []
  tree = {}
  if @item[:uuid]
    for comm in items.find_all("/data/comments/#{ @item[:uuid] }/*")
      ref = comm[:ref]
      if ref
        if tree[ref]
          tree[ref].append(comm)
        else
          tree[ref] = [comm]
        end
      else
        comments.append(comm)
      end
    end
  end
  return [comments, tree]
end
