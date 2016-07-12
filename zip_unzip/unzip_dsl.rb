#!/usr/bin/ruby

# uncompress zipped dsl.dz format dictionary files
# and convert them to UTF-8 for viewing or editing

def unzip_dictfile(dict)
  ext = File.extname(dict)
  basename = File.basename(dict, ext)
  dir = File.split(File.absolute_path(dict))[0]
  dsl_loc = dir + "/" + basename
  if ext == ".dz"
    `dictunzip #{dict}`
    dict_content = File.open(dsl_loc, "rb:UTF-16LE").read
    File.open(dsl_loc, "w", encoding: "UTF-8") {|t| t << dict_content }
    puts "  Processed #{basename}"
  end
end

def iterate_dir(dir)
  dir_array = Dir.glob(File.absolute_path(dir) + "/*")

  dir_array.sort.each do |d|
    unzip_dictfile(d)
  end
end

dir = ""
if ARGV[0]
  dict = ARGV[0]
  if File.directory?(dict)
    iterate_dir(dict)
  else
    unzip_dictfile(dict)
  end
else
  puts "  Please specify a source file or directory containing .dsl.dz files."
  exit
end
