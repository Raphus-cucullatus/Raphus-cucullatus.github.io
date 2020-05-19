require 'date'
require 'rake/clean'

POSTS_ORGS = FileList['./posts/**/*.org']
BIN_GEN_BC = './bin/gen-bc.rb'
BIN_GEN_RP = './bin/gen-rp.rb'
CONFIG_EMACS_ORG_EXPORT = './config/emacs-org-export.el'

desc "Compile standalone Org file to html (I have my Org file named '*.org')."
rule '.html' => ['.org'] do |post|
  sh "emacs -batch -l #{CONFIG_EMACS_ORG_EXPORT} -eval '(progn (set-buffer (find-file-noselect \"#{post.source}\")) (org-mode) (org-html-export-to-html))'"
end

POSTS_HTMLS = POSTS_ORGS.ext('html')
CLEAN.include(POSTS_HTMLS)

desc "Generate 'by-category.org' Org file."
file 'by-category.org' => POSTS_HTMLS + POSTS_ORGS + [BIN_GEN_BC] do |f|
  ruby "#{BIN_GEN_BC} ."
end
CLEAN.include('by-category.org')

desc "Generate 'recent-posts.org' Org file."
file 'recent-posts.org' => POSTS_HTMLS + POSTS_ORGS + [BIN_GEN_RP] do |f|
  ruby "#{BIN_GEN_RP} ."
end
CLEAN.include('recent-posts.org')

desc "Generate 'index.html'."
file 'index.html' => %w[recent-posts.org by-category.org index.org]
CLEAN.include('index.html')

desc "Publish to GitHub."
task publish: %w[index.html] do
  sh "git add --all"
  sh "git commit -m\"#{Date.today.strftime("%b %d, %Y")}\""
  sh "git push origin master"
end

task default: %w[index.html]

