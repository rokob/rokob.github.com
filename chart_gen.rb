#! /usr/bin/env ruby

require 'securerandom'

def fake_html(data, key, token, cssfile, htmlfile)
  if cssfile
    IO.write(cssfile, css(data, key, token))
  end
  if htmlfile
    IO.write(htmlfile, output(data, key, token))
  end
  if !cssfile && !htmlfile
    result = "<html><head><style>\n"
    result += css(data, key, token)
    result += "\n</style></head>\n"
    result += "<body>\n"
    result += output(data, key, token)
    result += "\n</body></html>"
    result
  end
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

def output(data, key, token)
  max, _ = get_max(data, key)
  result = "<div class=\"chart-#{token}-#{key}\">"
  data.each do |datum|
    result += "<div class=\"bar bar-#{val_for(datum, key)}\">"
    result += "<span class=\"text\">#{month_abbreviation(datum[:month])}</span>"
    result += "</div>"
  end
  result += "<div class=\"first-date-#{token}-#{key}\">#{first_date(data)}</div>"
  result += "<div class=\"max-value-#{token}-#{key}\">#{max}</div>"
  result += "<div class=\"last-date-#{token}-#{key}\">#{last_date(data)}</div>"
  result += '</div>'
  result
end

def first_date(data)
  data.first[:ds]
end

def last_date(data)
  data.last[:ds]
end

def css(data, key, token)
  max, max_idx = get_max(data, key)
  width = 100
  height = 200
  each_width = (width.to_f/data.count).round(2) - 0.35
  color = "#2c3e50"
  css  = ".chart-#{token}-#{key} { width: #{width}%;height:#{height}px;background-color:#fff;"
  css += "margin: 0px; padding: 20px 0px 20px 0px; text-align: center; position: relative;}"
  css += " .chart-#{token}-#{key} .bar { width: #{each_width}%; border-right: 1px solid #fff;"
  css += "background-color:#{color};display:inline-block;}"
  css += " .chart-#{token}-#{key} .bar .text { display: none; }"
  step = key != :count ? 10 : 1
  (0..max).step(step).each do |n|
    x = ((n.to_f/max)*100).round
    css += " .chart-#{token}-#{key} .bar-#{n} { height: #{x}%; }"
  end
  css += " .last-date-#{token}-#{key} { position: absolute; right: 0; bottom: 0 }"
  css += " .first-date-#{token}-#{key} { position: absolute; left: 0; bottom: 0 }"
  css += " .max-value-#{token}-#{key} { position: absolute; left: #{each_width*(2+max_idx)}%; top: 0 }"
  css
end

def get_max(data, key)
  max = nil
  idx = 0
  data.each_with_index do |datum, i|
    v = val_for(datum, key)
    unless max && v < max
      max = v
      idx = i
    end
  end
  [max, idx]
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
  token = 0 # I don't need this anymore SecureRandom.hex(4)
  data = []
  while line = STDIN.gets
    data << line.chomp
  end
  data = clean_data(data)
  value = fake_html(data, key, token, ARGV[1], ARGV[2])
  puts value if value
end

get_from_stdin
