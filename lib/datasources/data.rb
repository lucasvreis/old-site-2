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
                        email: parsed["email"],
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
