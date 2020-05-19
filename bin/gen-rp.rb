#!/usr/bin/env ruby

exit(-1) if ARGV.length < 1

require 'find'
require 'date'
require 'uri'

post_dir = "#{ARGV[0]}/posts"
out = "#{ARGV[0]}/recent-posts.org"
exit(-1) unless File.directory?(post_dir)

posts = []
Find.find(post_dir) do |path|
  if File.basename(path) =~ /.+\.org$/
    content = File.read(path, :encoding => "utf-8")
    match_date = /#\+DATE: (.*)$/.match(content)
    match_title = /#\+TITLE: (.*)$/.match(content)
    if match_date and match_title
      posts.push({ path: path, date: match_date[1], title: match_title[1] })
    end
  end
end

posts.map do |p|
  date = Date.strptime(p[:date], '%b %d, %Y')
  p[:date_raw] = date.strftime('%s')
  p
end

posts.sort! do |a, b|
  b[:date_raw] <=> a[:date_raw]
end

File.open(out, mode="w") do |f|
  posts.slice(0, 3).each do |p|
    path_html = p[:path].gsub(/(.*)\.org$/, '\1.html')
    path_html_escaped = URI.escape(path_html)
    f.write("- #{p[:date]}: [[file:#{path_html_escaped}][#{p[:title]}]]\n")
  end
end
