Scripts to convert the bilingual Wiktionary dictionaries created by [User:Matthias_Buchmeier](http://en.wiktionary.org/wiki/User:Matthias_Buchmeier) into compressed DSL-format. Scripts for extracting the source dictionaries, as well as versions of the dictionaries in a number of other formats are available on the [main project page](http://en.wiktionary.org/wiki/User:Matthias_Buchmeier) on Wiktionary.

# Prerequisites

* dictzip should be install
* SOURCE_DICTIONARY containing a first line in the form: "# Language1 :: Language2 dictionary " (watch out for the space)

# Usage

Basic usage is to run either `wikt2dsl.rb` or `wikt2dsl_twoway.rb`, specifying the source dictionary as an argument:

    ruby wikt2dsl.rb [options] [SOURCE_DICTIONARY]

The original dictionaries are unidirectional, which is also the default output of the `wikt2dsl.rb` script. To create bidirectional (but slightly larger) dictionaries, use the `wikt2dsl_twoway.rb` script instead. With the bidirectional dictionaries, the entries will remain unchanged, but searching in either language will find the correct entry.


## Options

There are a couple of command-line options that are mostly useful for development and to find errors in the source dictionaries:

* `-d`, `--dump` (_Dumps dsl format text to standard output rather than an output file_)
* `-t`, `--test` (_Test for common formatting errors in source file_)

There are quite a few errors in the source dictionaries as of the latest available version of the extraction script, most of which seem to be the result of incorrect formatting or templates in the original Wiktionary entries. Some of these (such as the presence of stray square or curly brackets) can cause problems with the conversion script and with the resulting DSL dictionaries (since both types of brackets need to be escaped in DSL entries). Use `-t` to identify some of these errors, and `-d` to look at the converted, uncompressed file to help troubleshoot these and other issues with conversion.

# Downloading dictionaries

Pre-compiled versions of the bilingual Wiktionary dictionaries created using this script can be found in the [wiktionary-dict](https://github.com/open-dsl-dict/wiktionary-dict) repo as part of the [Open DSL Dictionary Project](https://github.com/open-dsl-dict).

If you want to extract the dictionaries yourself, you will need a copy of the latest English Wiktionary [xml dump](https://dumps.wikimedia.org/), as well as the [trans-en-es.awk](https://en.wiktionary.org/wiki/User:Matthias_Buchmeier/trans-en-es.awk) script from the project homepage. You can then go to the folder where the dump file is located and run the command below (changing the dump file name and other parameters as appropriate):

    bzcat enwiktionary-DATE-pages-articles.xml.bz2|gawk -v LANG=language -v ISO=iso-code -f trans-en-es.awk|sort -d -k 1,1 -t"{">en-xx.wiki
 
# License

MIT -- see LICENSE file for details.
