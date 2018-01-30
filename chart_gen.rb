#! /usr/bin/env ruby

def fake_html(data, key)
  result = "<html><head><style>\n"
  result += css(data, key)
  result += "\n</style></head>\n"
  result += "<body>\n"
  result += output(data, key)
  result += "\n</body></html>"
  result
end

def val_for(datum, key)
  case key
  when :pages
    datum[key] - (datum[key] % 10)
  when :ratio
    return 0 unless datum[:count] > 0
    val = datum[:pages] / datum[:count]
    val - (val % 10)
  when :count
    datum[:count]
  end
end

def output(data, key)
  result = "<div class=\"chart-#{key}\">"
  data.each do |datum|
    result += "<div class=\"bar bar-#{val_for(datum, key)}\">"
    result += "<span class=\"text\">#{month_abbreviation(datum[:month])}</span>"
    result += "</div>"
  end
  result += '</div>'
  result
end

def css(data, key)
  max = get_max(data, key)
  width = 280
  height = 100
  each_width = (width/data.count).round(4) - 1
  color = "#2c3e50"
  css  = ".chart-#{key} { width: #{width}px;height:#{height}px;background-color:#fff;"
  css += "margin: 0px; padding: 0px;}"
  css += " .chart-#{key} .bar { width: #{each_width}px; border-right: 1px solid #fff;"
  css += "background-color:#{color};display:inline-block;}"
  css += " .chart-#{key} .bar .text { display: none; }"
  step = key != :count ? 10 : 1
  (0..max).step(step).each do |n|
    x = ((n.to_f/max)*100).round
    css += " .chart-#{key} .bar-#{n} { height: #{x}%; }"
  end
  css
end

def get_max(data, key)
  max = nil
  data.each do |datum|
    v = val_for(datum, key)
    max = v unless max && v < max
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
        value = {ds: ds, year: year, month: month, count: 0, pages: 0}
      end
      result << value
    end
  end
  result
end

def clean_line(line)
  date, count, pages = line.split(': ')
  year, month = date.split('-')
  count = count.split.first
  {ds: date, year: year, month: month, count: count.to_i, pages: pages.to_i}
end

def get_from_stdin
  key = (ARGV[0] || :count).to_sym
  data = []
  while line = STDIN.gets
    data << line.chomp
  end
  data = clean_data(data)
  puts fake_html(data, key)
end

get_from_stdin
