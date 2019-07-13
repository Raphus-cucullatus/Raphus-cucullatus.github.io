require 'rake/clean'

POSTS_ORGS = FileList['./posts/**/*.txt']
BIN_GEN_BC = './bin/gen-bc.rb'
BIN_GEN_RP = './bin/gen-rp.rb'
CONFIG_EMACS_ORG_EXPORT = './config/emacs-org-export.el'

desc "Compile standalone Org file to html (I have my Org file named '*.txt')."
rule '.html' => ['.txt'] do |post|
  sh "emacs -batch -eval '(progn (load-file \"#{CONFIG_EMACS_ORG_EXPORT}\") (set-buffer (find-file-noselect \"#{post.source}\")) (org-mode) (org-html-export-to-html))'"
end

POSTS_HTMLS = POSTS_ORGS.ext('html')
CLEAN.include(POSTS_HTMLS)

desc "Generate 'by-category.txt' Org file."
file 'by-category.txt' => POSTS_HTMLS + POSTS_ORGS + [BIN_GEN_BC] do |f|
  ruby "#{BIN_GEN_BC} ."
end
CLEAN.include('by-category.txt')

desc "Generate 'recent-posts.txt' Org file."
file 'recent-posts.txt' => POSTS_HTMLS + POSTS_ORGS + [BIN_GEN_RP] do |f|
  ruby "#{BIN_GEN_RP} ."
end
CLEAN.include('recent-posts.txt')

desc "Generate 'index.html'."
file 'index.html' => %w[recent-posts.html by-category.html]
CLEAN.include('by-category.html')
CLEAN.include('recent-posts.html')
CLEAN.include('index.html')

task default: %w[index.html]

