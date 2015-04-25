#!/usr/bin/ruby -KuU
# encoding: utf-8

# requires: dictzip

if ARGV[0] then dsl_file = ARGV[0] end

if !dsl_file
  puts "DSL file name:"
  dsl_file = gets.chomp
end

tab_data = File.read(dsl_file)

dsl_name = dsl_file.gsub(/(\/*.*\/)*(.*)\....$/, "\\2")

puts "Dictionary name:"
dict_name = $stdin.gets.chomp
puts "Index Language (from):"
index_lang = $stdin.gets.chomp
puts "Contents Language (to):"
contents_lang = $stdin.gets.chomp

header_stuff = "#NAME \"#{dict_name}\"\n#INDEX_LANGUAGE \"#{index_lang}\"\n#CONTENTS_LANGUAGE \"#{contents_lang}\"\n\n"

puts "Thank you. Your dictionary header looks like this:\n\n"
puts header_stuff
puts "Please wait. Processing dictionary data..."

dict_content = ""

tab_data.each_line do |line|
  if line.include? "\t"
    line = line.gsub(/\[/, "\\[").gsub(/\]/, "\\]")

    tab1,tab2 = line.chomp.split("\t")
    tab2 = tab2.gsub(tab1, "[i]~[/i]")
    dict_content << tab1 + "\n\t[m1]" + tab2 + "[/m]\n\n"
  end
end

File.open(dsl_name + ".dsl", "wt", encoding: "UTF-16LE") do |f|
  f << header_stuff
  f << dict_content
end

`dictzip #{dsl_name}.dsl`

puts "Done! Your dictionary is now available in the file #{dsl_name}.dsl.dz"
