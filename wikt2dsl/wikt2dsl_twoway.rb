#!/usr/bin/ruby -KuU
# encoding: utf-8

require 'optparse'

# requires: dictzip


# define command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ./wikt2dsl_twoway.rb [options] [SOURCE_DICTIONARY]"

  opts.on("-d", "--dump", "Dump dsl format text to standard output rather than output file") { options[:dump] = true }
  opts.on("-t", "--test", "Test for common formatting errors in source file") { options[:test] = true }

end.parse!


# open wiktionary source
if ARGV[0] then source_file = ARGV[0] end

if !source_file
  puts "Enter Wiktionary source file name:"
  source_file = gets.chomp
end

if source_file == ""
  abort("No file specified")
end

wiktionary = File.open(source_file)

source_dict = wiktionary.readlines


# get dictionary header information from the top of the file
first_line = source_dict[0]

re = /^# ([A-Za-z\-_]+) :: ([A-Za-z\-_]+) dictionary /
index_lang = first_line.match(re)[1]
cont_lang = first_line.match(re)[2]
dict_name = "Wiktionary #{index_lang}-#{cont_lang}"

header_info = "#NAME \"#{dict_name}\"\n#INDEX_LANGUAGE \"#{index_lang}\"\n#CONTENTS_LANGUAGE \"#{cont_lang}\"\n\n"

if options[:dump] != true && options[:test] != true
  puts "The Wiktionary dictionary header looks like this:\n\n"
  puts header_info
  puts "Please wait. Processing dictionary data..."
end

# if -t specified, test for common errors in source file
if options[:test] == true
  if options[:dump] == true
    source_dict.each do |line|
      unless /^# /.match(line)
        line = line.gsub(/\n\]\] ::\n/, "\n").gsub(/\n.*\[.*\n/, "\n").gsub(/\{\{/, "").gsub(/\[\[\[(.*)\]\]\]/, "[i]\\1[/i]").gsub(/\]\]|\[\[/, "")
        puts line
      end
    end
    exit
  else
    line_number = 1
    source_dict.each do |line|
      unless /^# /.match(line)
        if line.match(/\{\{/) then puts "**Source file contains \"{{\", which may cause errors:\n  In line #" + line_number.to_s + ": " + line end
        if line.match(/^[^\{]+$/) then puts "**Source file contains line without \"{\":\n  In line #" + line_number.to_s + ": " + line end
        if line.match(/\[\[/) then puts "**Source file contains \"[[\", which may cause errors:\n  In line #" + line_number.to_s + ": " + line end
      end
      line_number += 1
    end
  end
  exit
end

# get dictionary entries
dict_content = ""

source_dict.each do |line|
  line = line.gsub(/\n\]\] ::\n/, "\n").gsub(/\n.*\[.*\n/, "\n").gsub(/\{\{/, "").gsub(/\[\[\[(.*)\]\]\]/, "[i]\\1[/i]").gsub(/\]\]|\[\[/, "")
  unless /^# /.match(line)
    headword = ""
    if line.match(/\{/)
      headword = line.match(/^(.*?) \{/)[1]
    elsif line.match(/\(/)
      headword = line.match(/^(.*?) \(/)[1]
    end
    # headwords with special characters produce programm exceptions in the regexps below and have to be removed or escaped:
    headword2 = headword.gsub(/[\+\?\.\*\^\$\(\)\[\]\{\}\|\\]/, ".")
    entry = line.gsub(/(\[|\])/, "@@@\\1").gsub(/@@@/, "\\").gsub(/^#{headword2}/, "[b][c darkblue]#{headword}[/c][/b]").gsub(/\} \/(.*?)\//, "} [c gray]/\\1/[/c]").gsub(/\{(.*?)\}/, "[p]<\\1>[/p]").gsub(/SEE: (.*) ::/, "\n\tSEE: <<\\1>>").gsub(/ ::\s+(.*)$/, "\n\t[m1]\\1[/m]").gsub(/(\[\/p\] )(\(.*\))/, "\\1[i]\\2[/i]").gsub(/\{|\}/, "")
    if !/\tSEE: /.match(entry)
#       trans = entry.gsub(/\t\[b\]\[c darkblue\].*\n/, "").gsub(/\t\[m1\](.*)\[\/m\]/, "\\1").gsub(/\\/, "").gsub(/\s*[\[\(\<].*?[\]\)\>]\s*/, "").gsub(/~/, "").split(/\s*[,;]\s*/)
      trans = entry.split("\n")[1].gsub(/\t\[m1\](.*)\[\/m\]/, "\\1").gsub(/\\/, "").gsub(/\s*[\[\(\<].*?[\]\)\>]\s*/, "").gsub(/~/, "").split(/\s*[,;\/]\s*/).uniq.join("\n") + "\n"
    else
      trans = ""
    end
    dict_content << headword + "\n" + trans + "\t" + entry + "\n"
  end
end


# if -d specified, just dump the dictionary contents and exit
if options[:dump] == true
  puts header_info
  puts dict_content
  exit
end


# print dictionary in dsl format
dsl_name = source_file.gsub(/\.txt/, "") + ".dsl"
File.open(dsl_name, "wt", encoding: "UTF-16LE") do |dsl|
  dsl << header_info
  dsl << dict_content
end

# compress dsl file with dictzip
`dictzip #{dsl_name}`

puts "Done! Your dictionary is now available in the file #{dsl_name}.dz"
