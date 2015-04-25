Scripts to convert the bilingual Wiktionary dictionaries created by [User:Matthias_Buchmeier](http://en.wiktionary.org/wiki/User:Matthias_Buchmeier) into compressed DSL-format. Scripts for extracting the source dictionaries, as well as versions of the dictionaries in a number of other formats are available on the [main project page](http://en.wiktionary.org/wiki/User:Matthias_Buchmeier) on Wiktionary.

# Downloading dictionaries

Pre-compiled versions of the bilingual Wiktionary dictionaries created using this script can be found in the [wiktionary-dict](https://github.com/open-dsl-dict/wiktionary-dict) repo as part of the [Open DSL Dictionary Project](https://github.com/open-dsl-dict).

If you want to extract the dictionaries yourself, you will need a copy of the latest English Wiktionary [xml dump](https://dumps.wikimedia.org/), as well as the [trans-en-es.awk](https://en.wiktionary.org/wiki/User:Matthias_Buchmeier/trans-en-es.awk) script from the project homepage. You can then go to the folder where the dump file is located and run the command below (changing the dump file name and other parameters as appropriate):

    bzcat enwiktionary-DATE-pages-articles.xml.bz2|gawk -v LANG=language -v ISO=iso-code -f trans-en-es.awk|sort -d -k 1,1 -t"{">en-xx.wiki
 
# License

MIT -- see LICENSE file for details.
