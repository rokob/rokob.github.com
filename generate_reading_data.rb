#! /usr/bin/env ruby
require 'securerandom'
token = SecureRandom.hex(4)
`rm css/count.*.css;`
`rm css/pages.*.css;`
`rm css/ratio.*.css;`
`./postgen.rb calendar | ./chart_gen.rb count css/count.#{token}.css _includes/count.html`
`./postgen.rb calendar | ./chart_gen.rb pages css/pages.#{token}.css _includes/pages.html`
`./postgen.rb calendar | ./chart_gen.rb ratio css/ratio.#{token}.css _includes/ratio.html`
`./postgen.rb yearly | ./table_gen.rb _includes/yearly.html`
File.open('reading/index.html', 'r+') do |f|
  f.write("---\n")
  f.write("layout: base\n")
  f.write("title: Reading\n")
  f.write("icon: fa-book\n")
  f.write("extra_css:\n")
  f.write("  - count.#{token}.css\n")
  f.write("  - pages.#{token}.css\n")
  f.write("  - ratio.#{token}.css\n")
  f.write("---")
end
