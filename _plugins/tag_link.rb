module Jekyll
  module TagLink
    def tag_link(tags)
      link = ->(t) { "<a href=\"/tag/#{t}\">#{t}</a>" }
      if tags.is_a? Array
        tags.map &link
      else
        link.call tags
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::TagLink)
