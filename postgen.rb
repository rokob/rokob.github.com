#!/usr/bin/env ruby

require 'date'
require 'yaml'

module PostGen
  class PostGen
    SEPARATOR = '---'

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
      puts self.class.gather_groupings('categories')
      ask('Category') {|c| @categories = c.split}
      puts self.class.gather_groupings('tags')
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

    def self.gather_groupings(type='tags', dir='./_posts')
      tags = []
      Dir.foreach(dir) do |name|
        next if name.start_with? '.'
        File.open("#{dir}/#{name}", 'r') do |f|
          first_line = f.readline.chomp
          if first_line == SEPARATOR
            end_of_front_matter = false
            until end_of_front_matter
              line = f.readline.chomp
              end_of_front_matter = line == SEPARATOR
              if !end_of_front_matter
                if line.start_with? "#{type}: "
                  tags |= line.split("#{type}: ")[1].split
                end
              end
            end
          end
        end
      end
      "#{type.capitalize}: #{tags.join(', ')}"
    end

    def output(dir='_posts')
      filename = File.join(dir, gen_filename(@title))
      File.open(filename, 'w') do |f|
        f.puts frontmatter
        f.puts SEPARATOR
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

