#!/usr/bin/env ruby
#
# Generate "By Category Posts"" index org file from template.

require "erb"
include ERB::Util

name = "by-category"

posts_dir = "#{ARGV[0]}/posts"
template_file = "#{ARGV[0]}/#{name}.org.template"
out_file = "#{ARGV[0]}/#{name}.org"

categories = []

Dir.glob("*/", base: posts_dir) do |subdir|
  posts = []
  Dir.glob("*.org", base: File.join(posts_dir, subdir)) do |post|
    org_file = File.join(posts_dir, subdir, post)
    html_file = org_file.sub(/\.org$/, '.html')

    match = File.read(org_file, encoding: "utf-8").match(/#\+TITLE: (.*)$/)
    abort %Q[No "#+TITLE" found in file #{org_file}] unless match
    title = match[1]

    posts << {title: title, html: url_encode(html_file)}
  end

  match = %r{(\d+)([^0-9/]+)}.match subdir
  abort "Illegal dir name #{subdir}, a correct example: 1Kernel" unless match
  name = match[2]
  order = match[1]
  categories << {name: name, order: order, posts: posts}
end

categories.sort_by! { |cat| cat[:order] }

out = ERB.new(File.read(template_file), 0, "<>").result(binding)
File.write(out_file, out)


