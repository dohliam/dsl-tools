#!/usr/bin/ruby -KuU
# encoding: utf-8

# create a dsl dictionary from collection of paired bilingual sentences
# keywords can also be filtered through a stoplist if specified
#
# Usage:
# ./sentences2dsl.rb [-s LANG] sentence_file.txt

require 'fileutils'
require 'optparse'
require 'json'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-d', '--debug', 'Output dictionary text to stdin (without creating compressed file)') { options[:debug] = true }
  opts.on('-f', '--from-lang LANG', 'Name of source language') { |v| options[:from_lang] = v }
  opts.on('-n', '--dict-name NAME', 'Full name of dictionary') { |v| options[:dict_name] = v }
  opts.on('-t', '--to-lang LANG', 'Name of target language') { |v| options[:to_lang] = v }
  opts.on('-s', '--stoplist LANG', 'Specify a stoplist language to filter keywords') { |v| options[:stoplist] = v }

end.parse!

if ARGV[0]
  @dict_source = ARGV[0]
else
  puts "  Please enter a target sentence file."
  exit
end
sentences_file = File.read(dict_source)

# configure the location of your stoplist directory here
stoplist_dir = ""

lang = ""
json = []

if options[:stoplist]
  lang = options[:stoplist]
  stopwords_file = File.read(stoplist_dir + lang + ".json")
  json = JSON.parse(stopwords_file)
end

dict_name = "Bilingual dictionary"
if !options[:dict_name]
  dict_name = options[:dict_name]
end
index_lang = ""
contents_lang = ""

header_stuff = "#NAME \"#{dict_name}\"\n#INDEX_LANGUAGE \"#{index_lang}\"\n#CONTENTS_LANGUAGE \"#{contents_lang}\"\n\n"

dict_content = ""

sentences_file.each_line do |sentence|
  lang1,lang2 = sentence.chomp.split("\t")
  lang1_array = []
  lang1.split(" ").each do |w|
    word = w.gsub(/[\?\!\.,:;"“”]/, "")
    lang1_array.push(word.downcase)
  end
  lang1_array.each do |keyword|
    if !json.include?(keyword) && !keyword.match(/^[\s\n]*$/)
      dict_content << keyword + "\n"
    end
  end
  dict_content << "\t" + lang1 + "\n"
  dict_content << "\t" + lang2 + "\n\n"
end

if !options[:debug]
  dsl_name = File.basename(dict_source, File.extname(dict_source))

  File.open(dsl_name + ".dsl", "wt", encoding: "UTF-16LE") do |f|
    f << header_stuff
    f << dict_content
  end

  `dictzip #{dsl_name}.dsl`

  puts "Done! Your dictionary is now available in the file #{dsl_name}.dsl.dz"
  exit
end

puts header_stuff
puts dict_content
