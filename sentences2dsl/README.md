sentences2dsl - A very basic script to convert parallel corpora into DSL-format sentence pair dictionaries.

# Requirements

The script requires that the dictzip program be installed in order to compress the final dictionary (dsl.dz files are a small fraction of the size of the uncompressed originals and are supported by most dictionary programs that support dsl format).

# Usage

Just run the script from the command-line, providing the location of a source file as an argument:

    ./sentences2dsl.rb /path/to/mydictionary.txt

You can optionally specify a name for your dictionary (using `-n`), a source language (using `-f`), or a target language (`-t`). It is also possible to filter the results through a list of stop words using the `-s` option.

# Source format

sentences2dsl expects a source file containing two tab-separated columns in which the first column is the headword, and the second column is the body of the entry or definition, e.g.:

    Headword	Entry

These will converted into DSL-format entries with minimal formatting (italicized headwords and indented definitions).

# License

MIT -- see LICENSE file for details.
