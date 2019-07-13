#!/usr/bin/env ruby

exit(-1) if ARGV.length < 1

post_dir = "#{ARGV[0]}/posts"
out = "#{ARGV[0]}/by-category.txt"

exit(-1) unless File.directory?(post_dir)

require 'uri'
File.open(out, mode="w") do |f|
  Dir.glob(File.join(post_dir, "*/")).each do |d|
    f.write("* #{File.basename(d)}\n")

    Dir.glob(File.join(d, "*.txt")).each do |post_txt|
      post_html = post_txt.gsub(/(.*)\.txt$/, '\1.html')
      match_title = File.read(post_txt, :encoding => "utf-8").match(/#\+TITLE: (.*)$/)

      post_html_escaped = URI.escape(post_html)
      post_title = match_title[1] if match_title
      f.write("- [[file:#{post_html_escaped}][#{post_title}]]\n") if post_title
    end
  end
end
