#!/usr/bin/perl -w

# A simple script to use as an ispell deformat filter for spell-checking DF raws.
# Usage example: ispell -F utils/ispell_deformat_raws.pl raw/objects/*.txt

use strict;
use warnings;

sub blank ($) {
    local $_ = shift;
    tr/A-Za-z/*/;
    return $_;
}

while (<>) {
    s/(^|\])[^\[]+/blank $&/eg;           # blank text outside tags
    s/[\[:][^a-z\[\]]+[:\]]/blank $&/eg;  # blank all-capitals params
    print;
}
