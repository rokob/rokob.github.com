module Jekyll
  module CleanWritings

    def clean_writings(objects)
      all_writings = writings(objects, 'url')
      all_writings.partition {|w| w["size"] < 2}
    end

    private
      def writings(objects, path_key)
        objects.group_by do |object|
          get_path(object.send(path_key))
        end.inject([]) do |memo, i|
          unless i.last.first["index"]
            memo << { "key" => i.first, "values" => i.last, "size" => i.last.size }
          else
            memo
          end
        end
      end

      def get_path(path)
        parts = path.split('/')
        unless parts.last.include? '.'
          parts.join('/')
        else
          parts[0..-2].join('/')
        end
      end
  end
end

Liquid::Template.register_filter(Jekyll::CleanWritings)
