#!/usr/bin/env ruby

require 'date'
require 'yaml'

module PostGen
  class PostGen
    SEPARATOR = '---'
    RANKINGS  = %w{bad okay good great}

    def self.run(args)
      if args.length > 0
        dir = './_posts'
        if args[0] == 'book_info'
          gather_book_info(dir, args[1])
        elsif args[0] == 'calendar'
          output_calendar(dir, args[1])
        elsif args[0] == 'yearly'
          output_yearly_summary(dir)
        end
      else
        gen = PostGen.new
        gen.gather_info
        gen.output
      end
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
        date: get_datestring,
        categories: @categories.join(' '),
        tags: @tags.join(' '),
        published: false
      }
      unless @pagecount.nil?
        frontmatter[:pagecount] = @pagecount.to_i
      end
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
      total_count = counts.values.reduce(0){|a,x| a + x[:count]}
      total_pages = counts.values.reduce(0){|a,x| a + x[:pages]}
      puts "Total count: #{total_count}"
      puts "Total pages: #{total_pages}"
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
      counts = {}
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
          d = data[:date].strftime('%Y-%m')
          if counts[d].nil?
            counts[d] = {count: 0, pages: 0}
          end
          counts[d][:count] += 1
          counts[d][:pages] += data[:pagecount]
        end
      end
      [counts, rank_counts, tags]
    end

    def self.output_calendar(dir='./_posts', year=nil)
      counts, _, _ = normalize_data(dir, year)
      output_by_month(counts)
    end

    def self.output_by_month(counts)
      counts.keys.sort.each do |date|
        puts "#{date}: #{counts[date][:count]}\t Pages: #{counts[date][:pages]}"
      end
    end

    def self.output_by_year(counts)
      by_year_count = Hash.new(0)
      by_year_pages = Hash.new(0)
      counts.each do |date, count|
        by_year_count[date[0..3]] += count[:count]
        by_year_pages[date[0..3]] += count[:pages]
      end
      by_year_count.keys.sort.each do |year|
        puts "#{year}: #{'%02d' % by_year_count[year]}\t Pages: #{by_year_pages[year]}\t Avg: #{(by_year_pages[year]/12.0).round(2)}"
      end
    end

    def self.yearly_data(dir='./_posts')
      years = {}
      tags = {}
      rank_counts = {}
      counts = {}
      walk_posts(dir) do |data|
        year = data[:date].strftime('%Y')
        if data[:categories].include? 'book'
          years[year] = 1
          data[:tags].each do |tag|
            next if tag == 'book'
            if RANKINGS.include? tag
              if rank_counts[year].nil?
                rank_counts[year] = {}
                RANKINGS.each do |rank|
                  rank_counts[year][rank] = 0
                end
              end
              rank_counts[year][tag] += 1
            else
              if tags[year].nil?
                tags[year] = Hash.new(0)
              end
              tags[year][tag] += 1
            end
          end
          if counts[year].nil?
            counts[year] = {count: 0, pages: 0}
          end
          counts[year][:count] += 1
          counts[year][:pages] += data[:pagecount]
        end
      end
      [counts, rank_counts, tags, years.keys.sort]
    end

    def self.output_yearly_summary(dir='./_posts')
      counts, rank_counts, tags, years = yearly_data(dir)
      years.each do |year|
        puts "Year: #{year}"
        puts "Books read: #{counts[year][:count]}"
        puts "Pages read: #{counts[year][:pages]}"
        RANKINGS.each do |rank|
          puts "#{rank}: #{rank_counts[year][rank]}"
        end
        ['fiction', 'nonfiction'].each do |tag|
          puts "#{tag}: #{tags[year][tag]}"
        end
      end
    end

    def self.walk_posts(dir='./_posts', year=nil)
      Dir.foreach(dir) do |name|
        next if name.start_with? '.'
        File.open("#{dir}/#{name}", 'r') do |f|
          data = {date: nil, categories: [], tags: [], pagecount: 0}
          first_line = f.readline.chomp.strip
          if first_line == SEPARATOR
            end_of_front_matter = false
            until end_of_front_matter
              line = f.readline.chomp.strip
              end_of_front_matter = line == SEPARATOR
              if !end_of_front_matter
                if line.start_with? "date: "
                  date = line.split("date: ")[1]
                  datestring = line.split("date: ")[1]
                  data[:date]   = Date.parse(datestring, '%Y-%m-%d %H:%m:%S')
                  data[:date] ||= Date.parse(datestring, '%FT%T')
                end
                ['categories', 'tags'].each do |type|
                  if line.start_with? "#{type}: "
                    data[type.to_sym] = line.split("#{type}: ")[1].split
                  end
                end
                if line.start_with? "pagecount: "
                  count = line.split("pagecount: ")[1].to_i
                  data[:pagecount] = count
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

PostGen::PostGen.run ARGV
