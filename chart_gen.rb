#! /usr/bin/env ruby

def fake_html(data)
  result = "<html><head><style>\n"
  result += css(data)
  result += "\n</style></head>\n"
  result += "<body>\n"
  result += output(data)
  result += "\n</body></html>"
  result
end

def output(data)
  result = '<div class="chart">'
  data.each do |datum|
    result += "<div class=\"bar bar-#{datum[:count]}\">"
    result += "<span class=\"text\">#{month_abbreviation(datum[:month])}</span>"
    result += "</div>"
  end
  result += '</div>'
  result
end

def css(data)
  max = get_max(data)
  width = 280
  height = 100
  each_width = (width/data.count).round(4) - 1
  color = "#2c3e50"
  css  = ".chart { width: #{width}px;height:#{height}px;background-color:#fff;"
  css += "margin: 0px; padding: 0px;}"
  css += " .chart .bar { width: #{each_width}px; border-right: 1px solid #fff;"
  css += "background-color:#{color};display:inline-block;}"
  css += " .chart .bar .text { display: none; }"
  0.upto(max+1) do |n|
    x = (( (n.to_f/(max+1.0)))*100).round
    css += " .chart .bar-#{n} { height: #{x}%; }"
  end
  css
end

def get_max(data)
  max = nil
  data.each do |datum|
    max = datum[:count] unless max && datum[:count] < max
  end
  max
end

def month_abbreviation(month)
  ['Jan', 'Feb', 'Mar', 'Apr', 'May',
   'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
   'Nov', 'Dec'][month.to_i-1]
end

def clean_data(input)
  data = {}
  first_data, last_data = nil, nil
  input.each do |line|
    line_data = clean_line(line)
    unless first_data && first_data[:ds] < line_data[:ds]
      first_data = line_data
    end
    unless last_data && line_data[:ds] < last_data[:ds]
      last_data = line_data
    end
    data[line_data[:ds]] = line_data
  end
  result = []
  first_data[:year].upto(last_data[:year]) do |year|
    start_m, end_m = first_data[:month], last_data[:month]
    if last_data[:year] > first_data[:year]
      start_m = "01" if year > first_data[:year]
      end_m = "12" if year < last_data[:year] 
    end
    start_m.upto(end_m) do |month|
      ds = "#{year}-#{month}"
      value = data[ds]
      unless value
        value = {ds: ds, year: year, month: month, count: 0}
      end
      result << value
    end
  end
  result
end

def clean_line(line)
  date, count = line.split(': ')
  year, month = date.split('-')
  {ds: date, year: year, month: month, count: count.to_i}
end

def get_from_stdin
  data = []
  while line = gets
    data << line.chomp
  end
  data = clean_data(data)
  puts fake_html(data)
end

get_from_stdin
