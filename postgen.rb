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
      @pagecount = nil
      @book_link = nil
    end

    def gather_info
      ask('Title') {|t| @title = t}
      puts self.class.gather_groupings('categories')
      ask('Category') {|c| @categories = c.split}
      puts self.class.gather_groupings('tags')
      ask('Tags') {|g| @tags = g.split}
      if @categories.include? 'book'
        ask('Page count') {|p| @pagecount = p}
        ask('Link') {|l| @book_link = l}
      end
    end

    def gen_filename(title, ext='md')
      safe_title = parameterize(title)
      "#{get_ymd}-#{safe_title}.#{ext}"
    end

    def get_ymd
      @date.strftime('%Y-%m-%d')
    end

    def get_datestring
      @date.iso8601
    end

    def frontmatter
      frontmatter = {
        layout: 'post',
        title: @title,
        date: get_datestring.sub(/-0.:../, 'Z'),
        categories: @categories.join(' '),
        tags: @tags,
        published: false
      }
      unless @pagecount.nil?
        frontmatter[:pagecount] = @pagecount.to_i
      end
      frontmatter = Hash[frontmatter.map{|k,v| [k.to_s, v]}]
      frontmatter.to_yaml
    end

    def self.gather_groupings(type='tags', dir='./content')
      tags = []
      walk_posts(dir) do |data|
        tags |= data[type.to_sym]
      end
      "#{type.capitalize}: #{tags.sort.join(', ')}"
    end

    def self.walk_posts(dir='./content', year=nil)
      Dir.foreach(dir) do |name|
        next if File.directory?("#{dir}/#{name}")
        next if name.start_with? '.'
        File.open("#{dir}/#{name}", 'r') do |f|
          data = {date: nil, categories: [], tags: [], pagecount: 0}
          first_line = f.readline.chomp.strip
          if first_line == SEPARATOR
            frontmatter = first_line + "\n"
            loop do
              line = f.readline
              if line.start_with? SEPARATOR
                break
              end
              frontmatter += line
            end
            frontmatter = YAML.load(frontmatter)
            data[:date] = frontmatter["date"]
            data[:categories] = frontmatter["categories"].split
            data[:tags] = frontmatter["tags"]
            data[:pagecount] = frontmatter["pagecount"].to_i if frontmatter["pagecount"]
            if !year || data[:date].strftime('%Y') == year
              yield data if block_given?
            end
          end
        end
      end
    end

    def output(dir='content')
      filename = File.join(dir, gen_filename(@title))
      File.open(filename, 'w') do |f|
        f.puts frontmatter
        f.puts SEPARATOR
        f.puts
        unless @book_link.nil?
          f.puts "[*#{@title}*][book-amaz]"
          f.puts
          f.puts "[book-amaz]:      #{@book_link}"
        end
      end
    end

    def parameterize(str)
      str.gsub(/[^A-Za-z0-9]/,' ').downcase.split.join('-')
    end

    def ask(prompt)
      print "#{prompt}>  "
      result = readline
      yield result.strip if block_given?
    end
  end
end

PostGen::PostGen.run
