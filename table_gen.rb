#! /usr/bin/env ruby

def write_to_file(data, filename)
  IO.write(filename, html(data))
end

def html(data)
  result = nil
  data.each do |line|
    k, v = line.split(': ')
    if k == 'Year'
      if result.nil?
        result = ""
      else
        result += "</table>"
      end
      result += "<table><caption><h3>#{v}</h3></caption>"
    else
      vv = v.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      result += "<tr><td>#{k.capitalize}</td><td style=\"text-align:right;\">#{vv}</td></tr>"
    end
  end
  result += "</table>"
  result
end

def get_from_stdin
  data = []
  while line = STDIN.gets
    data << line.chomp
  end
  write_to_file(data, ARGV[0])
end

get_from_stdin
