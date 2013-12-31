module Jekyll
  class Commit < Liquid::Tag
    MATCHER = /\A(\S+)\Z/
    def render(context)
      markup = @markup.strip

      page_file = "#{context.registers[:site].source}"
      file_path = "#{context.environments.first["page"]["path"]}"
      page_file += "/#{file_path}"

      sha = `git log -n 1 --pretty=format:%H -- #{page_file}`
      message = `git log -n 1 --pretty=format:%s -- #{page_file}`

      history_icon = "<i class=\"fa fa-code-fork fa-lg\"></i>"

      history_url = "<a href='https://github.com/rokob/rokob.github.com/commits/source/"
      history_url += file_path
      history_url += "'>History</a>"

      commit_url = "<span class='commit' title=\"#{message}\">"
      if not markup.empty?
        repo = markup.match(MATCHER)[1]
        commit_url += "<a href=\"https://github.com/#{repo}/commit/#{sha}\""
        commit_url += " title=\"#{message}\">#{sha[0...8]}</a>"
      else
        commit_url += "#{sha[0...8]}"
      end
      commit_url += "</span>"

      history_icon + " " + history_url + " &mdash; " + commit_url
    end
  end
end

Liquid::Template.register_tag('commit', Jekyll::Commit)
