#!/usr/bin/env ruby
#
# Generate "Recent Posts" index org file from template

require "erb"
include ERB::Util

require 'find'
require 'date'

name = "recent-posts"

posts_dir = "#{ARGV[0]}/posts"
template_file = "#{ARGV[0]}/#{name}.org.template"
out_file = "#{ARGV[0]}/#{name}.org"

posts = []
Find.find(posts_dir) do |path|
  if File.basename(path) =~ /.+\.org$/
    content = File.read(path, encoding: "utf-8")
    match_date = /#\+DATE: (.*)$/.match(content)
    match_title = /#\+TITLE: (.*)$/.match(content)
    if match_date and match_title
      posts << {path: url_encode(path), date: match_date[1], title: match_title[1]}
    end
  end
end

posts.map do |p|
  date = Date.strptime(p[:date], '%b %d, %Y')
  p[:date_raw] = date.strftime('%s')
  p
end

posts.sort! { |a, b| b[:date_raw] <=> a[:date_raw] }

recent_posts = posts[0, 3]

out = ERB.new(File.read(template_file), 0, "<>").result(binding)
File.write(out_file, out)
# File.open(out, mode="w") do |f|
#   posts.slice(0, 3).each do |p|
#     path_html = p[:path].sub(/\.org$/, '.html')
#     path_html_escaped = URI.escape(path_html)
#     f.write("- #{p[:date]}: [[file:#{path_html_escaped}][#{p[:title]}]]\n")
#   end
# end
