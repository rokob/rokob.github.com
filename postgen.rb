#!/usr/bin/env ruby

require 'date'
require 'yaml'

module PostGen
  class PostGen
    def self.run
      gen = PostGen.new
      gen.gather_info
      gen.output
    end

    def initialize
      @date = DateTime.now
    end

    def gather_info
      ask('Title') {|t| @title = t}
      ask('Category') {|c| @categories = c.split}
      ask('Tags') {|g| @tags = g.split}
    end

    def gen_filename(title, ext='md')
      safe_title = parameterize(title)
      "#{get_ymd}-#{safe_title}.#{ext}"
    end

    def get_ymd
      @date.strftime('%Y-%m-%d')
    end

    def get_datestring
      @date.strftime('%Y-%m-%d %H:%m:%S')
    end

    def frontmatter
      frontmatter = {
        layout: 'post',
        title: @title,
        date: get_datestring,
        categories: @categories.join(' '),
        tags: @tags.join(' '),
        published: false
      }
      frontmatter = Hash[frontmatter.map{|k,v| [k.to_s, v]}]
      frontmatter.to_yaml
    end

    def output(dir='_posts')
      filename = File.join(dir, gen_filename(@title))
      separator = '---'
      File.open(filename, 'w') do |f|
        f.puts frontmatter
        f.puts separator
        f.puts
      end
    end

    def parameterize(str)
      str.downcase.split.join('-')
    end

    def ask(prompt)
      print "#{prompt}>  "
      result = readline
      yield result.strip if block_given?
    end
  end
end

PostGen::PostGen.run
