require 'yaml'

class CommentsDataSource < Nanoc::DataSource
  identifier :comment_data

  def items

    list = []

    for uuid in Dir.children("data/comments")
      i = 0
      for comment_file in Dir["data/comments/#{uuid}/*"]
        parsed = YAML.safe_load_file(comment_file)

        list.append new_item(
                      parsed["message"],
                      { name: parsed["name"],
                        ref: parsed["ref"],
                        time: Date.parse(parsed["date"]),
                        id: parsed["_id"],
                        no: i,
                        replying_to: parsed["replying_to"]
                      },
                      '/' + uuid + '/' + i.to_s
                    )
        i += 1
      end
    end
    list
  end
end

# class DisciplinasDataSource < Nanoc::DataSource
#   identifier :disciplinas

#   def items
#     list = []
#     for disc in Dir.children("#{Dir.home}/Lucas/notas/disciplinas")
#       for nota in Dir["#{Dir.home}/Lucas/notas/disciplinas/#{disc}/*.org"]
#         content = File.read(nota)
#         title = content.match /#\+title: (.*)$/i
#         list.append new_item(content, { title: title[1] }, '/' + disc + '.org')
#       end
#     end
#     list
#   end
# end
