#!/usr/bin/ruby -KuU
# encoding: utf-8

# == wordlist2dsl.rb ==
# Takes a monolingual wordlist file extracted from
# a Wikidata dump and converts it to dictzipped DSL 
# dictionary format (dict.dz files).
#
# A monolingual dictionary derived from the titles 
# of Wikipedia entries can be useful in a number of ways,
# including checking spelling and checking to see if an
# article exists on Wikipedia when offlne or in cases where
# internet access is not available.
#
# For bilingual dictionaries, see wiki2dsl.rb.
#
# Usage: Assuming you have a directory of compressed, 
# tab-separated wikidata dictionary files named
# [language-code].tar.gz, navigate to the directory
# containing the tar.gz files and execute the following 
# command:
# 
# ruby wordlist2dsl.rb [language-code]
#
# To extract the tab-separated files from a wikidata dump,
# you'll need the wikidata-parse.rb script.

require 'rubygems/package'
require 'zlib'
require 'fileutils'

dir = "wordlist"

counter = 0

lang_name = { "en" => "English", "sv" => "Swedish", "nl" => "Dutch", "de" => "German", "fr" => "French", "war" => "Waray-Waray", "ru" => "Russian", "ceb" => "Cebuano", "it" => "Italian", "es" => "Spanish", "vi" => "Vietnamese", "pl" => "Polish", "ja" => "Japanese", "pt" => "Portuguese", "zh" => "Chinese", "uk" => "Ukrainian", "ca" => "Catalan", "fa" => "Persian", "Norsk" => "Norwegian", "sh" => "Serbo-Croatian", "fi" => "Finnish", "id" => "Indonesian", "ar" => "Arabic", "cs" => "Czech", "sr" => "Serbian", "ko" => "Korean", "hu" => "Hungarian", "ro" => "Romanian", "ms" => "Malay", "tr" => "Turkish", "min" => "Minangkabau", "eo" => "Esperanto", "kk" => "Kazakh", "eu" => "Basque", "sk" => "Slovak", "da" => "Danish", "bg" => "Bulgarian", "lt" => "Lithuanian", "he" => "Hebrew", "hy" => "Armenian", "hr" => "Croatian", "sl" => "Slovenian", "et" => "Estonian", "uz" => "Uzbek", "gl" => "Galician", "Nynorsk" => "Norwegian", "vo" => "Volapük", "la" => "Latin", "Simple" => "Simple", "el" => "Greek", "hi" => "Hindi", "az" => "Azerbaijani", "th" => "Thai", "ka" => "Georgian", "oc" => "Occitan", "be" => "Belarusian", "mk" => "Macedonian", "ce" => "Chechen", "mg" => "Malagasy", "new" => "Newar / Nepal Bhasa", "ur" => "Urdu", "tt" => "Tatar", "ta" => "Tamil", "pms" => "Piedmontese", "cy" => "Welsh", "tl" => "Tagalog", "te" => "Telugu", "lv" => "Latvian", "bs" => "Bosnian", "Беларуская" => "Belarusian", "br" => "Breton", "ht" => "Haitian", "sq" => "Albanian", "jv" => "Javanese", "lb" => "Luxembourgish", "mr" => "Marathi", "is" => "Icelandic", "ml" => "Malayalam", "zh" => "Cantonese", "bn" => "Bengali", "af" => "Afrikaans", "ba" => "Bashkir", "شاہ" => "Western", "ga" => "Irish", "lmo" => "Lombard", "Frysk" => "West", "tg" => "Tajik", "yo" => "Yoruba", "cv" => "Chuvash", "my" => "Burmese", "an" => "Aragonese", "sco" => "Scots", "sw" => "Swahili", "ky" => "Kirghiz", "io" => "Ido", "ne" => "Nepali", "gu" => "Gujarati", "scn" => "Sicilian", "ইমার" => "Bishnupriya", "Plattdüütsch" => "Low", "ku" => "Kurdish", "ast" => "Asturian", "qu" => "Quechua", "als" => "Alemannic", "su" => "Sundanese", "kn" => "Kannada", "pa" => "Punjabi", "ckb" => "Sorani", "ia" => "Interlingua", "nap" => "Neapolitan", "mn" => "Mongolian", "bug" => "Buginese", "bat" => "Samogitian", "arz" => "Egyptian", "wa" => "Walloon", "Bân" => "Min", "map" => "Banyumasan", "Gàidhlig" => "Scottish", "yi" => "Yiddish", "mzn" => "Mazandarani", "am" => "Amharic", "si" => "Sinhalese", "fo" => "Faroese", "bar" => "Bavarian", "vec" => "Venetian", "nah" => "Nahuatl", "sah" => "Sakha", "os" => "Ossetian", "sa" => "Sanskrit", "roa" => "Tarantino", "li" => "Limburgish", "Hornjoserbsce" => "Upper", "or" => "Oriya", "pam" => "Kapampangan", "Олык" => "Meadow", "Sámegiella" => "Northern", "mi" => "Maori", "Кырык" => "Hill", "ilo" => "Ilokano", "Fiji" => "Fiji", "Bikol" => "Central", "gan" => "Gan", "rue" => "Rusyn", "glk" => "Gilaki", "bo" => "Tibetan", "Nedersaksisch" => "Dutch", "ps" => "Pashto", "West" => "West", "diq" => "Zazaki", "fiu" => "Võro", "bh" => "Bihari", "xmf" => "Mingrelian", "tk" => "Turkmen", "gv" => "Manx", "co" => "Corsican", "sc" => "Sardinian", "csb" => "Kashubian", "hak" => "Hakka", "km" => "Khmer", "kv" => "Komi", "zea" => "Zeelandic", "vep" => "Vepsian", "Qırımtatarca" => "Crimean", "古文" => "Classical", "Nordfriisk" => "North", "ay" => "Aymara", "eml" => "Emilian-Romagnol", "Seeltersk" => "Saterland", "nrm" => "Norman", "kw" => "Cornish", "rm" => "Romansh", "wuu" => "Wu", "udm" => "Udmurt", "szl" => "Silesian", "so" => "Somali", "koi" => "Komi-Permyak", "as" => "Assamese", "lad" => "Ladino", "mt" => "Maltese", "fur" => "Friulian", "dv" => "Divehi", "gn" => "Guarani", "Dolnoserbski" => "Lower", "pcd" => "Picard", "Chavacano" => "Zamboanga", "lij" => "Ligurian", "ie" => "Interlingue", "ksh" => "Ripuarian", "ext" => "Extremaduran", "mwl" => "Mirandese", "gag" => "Gagauz", "ang" => "Anglo-Saxon", "Mìng" => "Min", "ug" => "Uyghur", "ace" => "Acehnese", "pi" => "Pali", "pag" => "Pangasinan", "nv" => "Navajo", "frp" => "Franco-Provençal/Arpitan", "sn" => "Shona", "kab" => "Kabyle", "lez" => "Lezgian", "ln" => "Lingala", "Pälzisch" => "Palatinate", "krc" => "Karachay-Balkar", "myv" => "Erzya", "haw" => "Hawaiian", "rw" => "Kinyarwanda", "kaa" => "Karakalpak", "Deitsch" => "Pennsylvania", "to" => "Tongan", "xal" => "Kalmyk", "kl" => "Greenlandic", "arc" => "Aramaic", "nov" => "Novial", "Адыгэбзэ" => "Kabardian", "sd" => "Sindhi", "av" => "Avar", "bjn" => "Banjar", "lo" => "Lao", "ha" => "Hausa", "Tok" => "Tok", "Буряад" => "Buryat", "na" => "Nauruan", "pap" => "Papiamentu", "lbe" => "Lak", "jbo" => "Lojban", "ty" => "Tahitian", "mdf" => "Moksha", "wo" => "Wolof", "roa" => "Aromanian", "ig" => "Igbo", "tyv" => "Tuvan", "srn" => "Sranan", "Sepedi" => "Northern", "kg" => "Kongo", "tet" => "Tetum", "ab" => "Abkhazian", "ltg" => "Latgalian", "zu" => "Zulu", "om" => "Oromo", "chy" => "Cheyenne", "za" => "Zhuang", "Словѣньскъ" => "Old", "rmy" => "Romani", "tw" => "Twi", "tn" => "Tswana", "chr" => "Cherokee", "pih" => "Norfolk", "got" => "Gothic", "bi" => "Bislama", "xh" => "Xhosa", "sm" => "Samoan", "mai" => "Maithili", "ss" => "Swati", "mo" => "Moldovan", "ki" => "Kikuyu", "rn" => "Kirundi", "pnt" => "Pontic", "bm" => "Bambara", "iu" => "Inuktitut", "ee" => "Ewe", "lg" => "Luganda", "ts" => "Tsonga", "ak" => "Akan", "fj" => "Fijian" "ik" => "Inupiak", "sg" => "Sango", "st" => "Sesotho", "ff" => "Fula", "dz" => "Dzongkha", "ny" => "Chichewa", "ti" => "Tigrinya", "ch" => "Chamorro", "ve" => "Venda", "ks" => "Kashmiri", "tum" => "Tumbuka", "cr" => "Cree", "ng" => "Ndonga", "cho" => "Choctaw", "kj" => "Kuanyama", "mh" => "Marshallese", "Hiri" => "Hiri", "ꆇꉙ" => "Sichuan", "aa" => "Afar", "mus" => "Muscogee", "hz" => "Herero", "kr" => "Kanuri" }

tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open("../targz/#{dir}.tar.gz", :external_encoding => "UTF-8"))
tar_extract.rewind
total = lang_name.length
tar_extract.each do |entry|
  unless entry.directory? == true
    dict_name = entry.full_name.gsub(/.*\//, "").gsub(/_wiki\.txt/, "")
    index_lang = dict_name.gsub(/\-.*/, "")
    header_stuff = "#NAME \"#{dict_name} Wiki Wordlist\"\n#INDEX_LANGUAGE \"#{lang_name[index_lang]}\"\n#CONTENTS_LANGUAGE \"#{lang_name[index_lang]}\"\n\n"
    puts "Your dictionary header looks like this:\n\n"
    puts header_stuff
    puts "Please wait. Processing dictionary data..."
    dict_content = ""
    FileUtils.mkdir_p "../dsl/" + dir
    dsl_name = "../dsl/" + dir + "/" + dict_name + "_wiki-wordlist.dsl"
    f = File.open(dsl_name, "w", encoding: "UTF-16LE")
    data = entry.read.force_encoding('UTF-8')
    data.each_line do |line|
      tab = line.chomp
      regex = /^[^\s]+:(?!\s)/
      if !regex.match(tab)
        dict_content << tab + "\n\t[m1]" + tab + "[/m]\n\n"
      end
    end
    f << header_stuff
    f << dict_content

    `dictzip #{dsl_name}`

    counter += 1
    progress = counter.to_f / total.to_f * 100.0

    puts counter.to_s + " out of " + total.to_s + " dictionaries processed (" + progress.round(2).to_s + "%)"
    puts
  end
end
tar_extract.close
