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

require_relative '../lib/dsl_lib.rb'

def format_dictionary(sentences_file, options)
  dict_content = ""
  lang = options[:stoplist]
  json = read_stoplist(options, lang)

  sentences_file.each_line do |sentence|
    lang1,lang2 = sentence.chomp.split("\t")
    lang1_array = []
    lang1.split(" ").each do |w|
      word = w.gsub(/[\?\!\.,:;"“”]/, "")
      lang1_array.push(word.downcase)
    end
    lang1_array.each do |keyword|
      if !json.include?(keyword) && !keyword.match(/^[\s\n]*$/)
        dict_content << keyword + "\r\n"
      end
    end
    dict_content << "\t" + lang1 + "\r\n"
    dict_content << "\t" + lang2 + "\r\n\r\n"
  end
  dict_content
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: sentences2dsl.rb [options] [filename]"

  opts.on('-d', '--debug', 'Output dictionary text to stdin (without creating compressed file)') { options[:debug] = true }
  opts.on('-f', '--from-lang LANG', 'Name of source language') { |v| options[:from_lang] = v }
  opts.on('-m', '--monolingual', 'Only provide unidirectional lookups (default is bidirectional)') { options[:monolingual] = true }
  opts.on('-n', '--dict-name NAME', 'Full name of dictionary') { |v| options[:dict_name] = v }
  opts.on('-t', '--to-lang LANG', 'Name of target language') { |v| options[:to_lang] = v }
  opts.on('-s', '--stoplist LANG', 'Specify a stoplist language to filter keywords') { |v| options[:stoplist] = v }
  opts.on('-S', '--stop-dir DIR', 'Specify path of stoplist directory') { |v| options[:stopdir] = v }

end.parse!

if ARGV[0]
  dict_source = ARGV[0]
else
  puts "  Please enter a target sentence file."
  exit
end
sentences_file = File.read(dict_source)

header_stuff = get_header(options)
dsl_name = get_dict_name(dict_source)
header_stuff = get_header(options)
dict_content = format_dictionary(sentences_file, options)

handle_output(options, dsl_name, header_stuff, dict_content)
