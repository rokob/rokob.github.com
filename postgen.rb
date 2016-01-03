#!/usr/bin/env ruby

require 'date'
require 'yaml'

module PostGen
  class PostGen
    SEPARATOR = '---'
    RANKINGS  = %w{bad okay good great}

    def self.run(args)
      if args.length > 0
        if args[0] == 'book_info'
          gather_book_info('./_posts', args[1])
        elsif args[0] == 'calendar'
          output_calendar
        end
      else
        gen = PostGen.new
        gen.gather_info
        gen.output
      end
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
      walk_posts(dir) do |data|
        tags |= data[type.to_sym]
      end
      "#{type.capitalize}: #{tags.sort.join(', ')}"
    end

    def self.gather_book_info(dir='./_posts', year=nil)
      counts, rank_counts, tags = normalize_data(dir, year)
      puts "Total count: #{counts.values.reduce(&:+)}"
      puts
      unless year
        puts "By year:"
        output_by_year(counts)
        puts
      end
      puts "By month:"
      output_by_month(counts)
      puts
      puts "Tags:"
      tags.keys.sort.each do |tag|
        puts "#{tag}: #{tags[tag]}"
      end
      puts
      puts "Ratings:"
      RANKINGS.each do |rank|
        puts "#{rank}: #{rank_counts[rank]}"
      end
      puts
    end

    def self.normalize_data(dir='./_posts', year=nil)
      tags = Hash.new(0)
      rank_counts = {}
      RANKINGS.each do |rank|
        rank_counts[rank] = 0
      end
      counts = Hash.new(0)
      walk_posts(dir, year) do |data|
        if data[:categories].include? 'book'
          data[:tags].each do |tag|
            next if tag == 'book'
            if RANKINGS.include? tag
              rank_counts[tag] += 1
            else
              tags[tag] += 1
            end
          end
          counts[data[:date].strftime('%Y-%m')] += 1
        end
      end
      [counts, rank_counts, tags]
    end

    def self.output_calendar
      counts, _, _ = normalize_data
      output_by_month(counts)
    end

    def self.output_by_month(counts)
      counts.keys.sort.each do |date|
        puts "#{date}: #{counts[date]}"
      end
    end

    def self.output_by_year(counts)
      by_year = Hash.new(0)
      counts.each do |date, count|
        by_year[date[0..3]] += count
      end
      by_year.keys.sort.each do |year|
        puts "#{year}: #{by_year[year]}"
      end
    end

    def self.walk_posts(dir='./_posts', year=nil)
      Dir.foreach(dir) do |name|
        next if name.start_with? '.'
        File.open("#{dir}/#{name}", 'r') do |f|
          data = {date: nil, categories: [], tags: []}
          first_line = f.readline.chomp.strip
          if first_line == SEPARATOR
            end_of_front_matter = false
            until end_of_front_matter
              line = f.readline.chomp.strip
              end_of_front_matter= line == SEPARATOR
              if !end_of_front_matter
                if line.start_with? "date: "
                  date = line.split("date: ")[1]
                  data[:date] = Date.parse(line.split("date: ")[1], '%Y-%m-%d %H:%m:%S')
                end
                ['categories', 'tags'].each do |type|
                  if line.start_with? "#{type}: "
                    data[type.to_sym] = line.split("#{type}: ")[1].split
                  end
                end
              end
            end
            if !year || data[:date].strftime('%Y') == year
              yield data if block_given?
            end
          end
        end
      end
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

PostGen::PostGen.run ARGV

