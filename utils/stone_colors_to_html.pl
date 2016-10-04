#!/usr/bin/perl -w

# Script to render the tile symbols and colors of stones and other
# inorganic materials as an HTML table.
#
# Released into the public domain by Ilmari Karonen (Vyznev).
# Do whatever you want with it.
#
# Usage: Run the script in your DF folder, with the names of the files
# containing the raws for the materials you want to examine as command
# line parameters.  Pipe the output to an .html file and open it in a
# browser.
#
# Known bugs:
#  * Colors or tiles specified in material templates are ignored.
#  * The same set of example symbols is shown for all materials, even
#    if some combinations never appear in-game (e.g. engraved soil).
#
# I think the parsing of contradictory color tag combinations matches
# the way DF does it, but I haven't tested this fully.  Caveat emptor.

use strict;
use warnings;
use Getopt::Long 'GetOptions';
use Encode 'decode';

my $colorfile = "data/init/colors.txt";

my $usage = <<"END";
Usage: $0 [options] [<raws.txt> ...]
Options:
  --colorfile=<file>, -c <file>
    File to read colors from; default: $colorfile
END

GetOptions('colorfile|c=s' => \$colorfile)
    or die $usage;

-e $colorfile or die "$colorfile not found. Use the -c option to specify an alternate location.\n";

# load color values from file
my @colornames = qw(
    BLACK BLUE  GREEN  CYAN  RED  MAGENTA  BROWN  LGRAY
    DGRAY LBLUE LGREEN LCYAN LRED LMAGENTA YELLOW WHITE
);
my @rgb = qw(R G B);
my (%colornum, %rgbnum);
@colornum{@colornames} = (0 .. $#colornames);
@rgbnum{@rgb} = (0 .. $#rgb);

my $color_re = join "|", @colornames;
$color_re = qr/\[\s*($color_re)_([RGB])\s*:\s*(\d+)\s*\]/i;

open FH, '<', $colorfile or die "Error opening $colorfile: $!\n";
my @colors;
while (<FH>) {
    while (/$color_re/g) {
	$colors[ $colornum{uc $1} ][ $rgbnum{uc $2} ] = $3;
    }
}

# check that we have all colors, pack as RGB triples
foreach my $color (0 .. 15) {
    foreach my $rgb (0 .. 2) {
	defined $colors[$color][$rgb] or die "No color value found for $colornames[$color]_$rgb[$rgb].\n";
	$colors[$color][$rgb] < 256 or die "Invalid color value $colors[$color][$rgb] for $colornames[$color]_$rgb[$rgb].\n";
    }
    $colors[$color] = unpack "H6", pack "C3", @{ $colors[$color] };
}

# decode CP-437 text using graphical symbols for control chars
sub decode_cp437 ($) {
    local $_ = decode('cp437', shift);  # this handles non-control chars
    tr/\x01-\x0F/\x{263A}\x{263B}\x{2665}\x{2666}\x{2663}\x{2660}\x{2022}\x{25D8}\x{25CB}\x{25D9}\x{2642}\x{2640}\x{266A}\x{266B}\x{263C}/;
    tr/\x10-\x1F/\x{25BA}\x{25C4}\x{2195}\x{203C}\x{00B6}\x{00A7}\x{25AC}\x{21A8}\x{2191}\x{2193}\x{2192}\x{2190}\x{221F}\x{2194}\x{25B2}\x{25BC}/;
    tr/\x7F/\x{2302}/;
    return $_;
}

# read raws (parsing rules based on http://dwarffortresswiki.org/index.php/DF2012:Material_definition_token)
my ($mat, %materials, @materials);
while (<>) {
    while (/\[([^\[\]]*)\]/g) {
	my $tag = $1;
	my ($name, @args) = split /:/, $tag;
	$name = uc $name;
	if ($name eq 'INORGANIC') {
	    $mat = $args[0];
	    push @materials, $mat;
	    $materials{$mat} = {  # defaults
		TILE_COLOR  => [7,7,1],
		BUILD_COLOR => [7,7,1],
		BASIC_COLOR => [7,1],
		tags => ""
	    };
	}
	elsif ($name eq 'TILE') {
	    my $tile;
	    if ($args[0] =~ /^\d+$/ and $args[0] < 256) {
		$tile = chr $args[0];
	    }
	    elsif ($args[0] =~ /^'(.)'$/) {
		$tile = $1;
	    }
	    else {
		die "Unrecognized tile $args[0] for $mat.\n";
	    }
	    $materials{$mat}{TILE} = decode_cp437($tile);
	    $materials{$mat}{tags} .= "[$tag]";
	}
	elsif ($name =~ /^(TILE|BUILD|BASIC)_COLOR$/i) {
	    $materials{$mat}{$name} = [ @args ];
	    $materials{$mat}{tags} .= "[$tag]";
	}
	elsif ($name eq 'DISPLAY_COLOR') {
	    $materials{$mat}{TILE_COLOR} = [ @args ];
	    $materials{$mat}{BUILD_COLOR} = [ @args[1,0], $args[0] == $args[1] ];
	    $materials{$mat}{BASIC_COLOR} = [ @args[0,2] ];
	    $materials{$mat}{tags} .= "[$tag]";
	}
    }
}

# print table
binmode STDOUT, ":utf8";
print <<"END";
<!DOCTYPE html><meta charset="utf-8"> 
<style type="text/css">
tt { font-family: 'Courier New', 'Quicktype Mono', 'Bitstream Vera Sans Mono', 'Lucida Console', 'Lucida Sans Typewriter', monospace;
     font-weight: bold; line-height: 100%; }
</style>
<table style="border: 0;">
<tr><th>Material</th><th>Tile color</th><th>Basic color</th><th>Build color</th><th>Tags</th></tr>
END

my %escape = qw(& amp < lt > gt " quot);
sub escape ($) {
    my $text = shift;
    $text =~ s/([&<>"])/&$escape{$1};/g;
    return $text;
}

foreach my $mat (@materials) {
    my $tile = $materials{$mat}{TILE};
    $tile = "\x{2588}" unless defined $tile;  # default = 219 = U+2588 (solid block)

    my $basic_fg = $materials{$mat}{BASIC_COLOR}[0] & 15;
    $basic_fg |= 8 if $materials{$mat}{BASIC_COLOR}[1];
    my $basic_bg = ($basic_fg ? 0 : 8);
    my $basic_style = "color: #$colors[$basic_fg]; background-color: #$colors[$basic_bg]";

    my $tile_fg = $materials{$mat}{TILE_COLOR}[0] & 15;
    my $tile_bg = $materials{$mat}{TILE_COLOR}[1] & 15;
    $tile_fg |= 8 if $materials{$mat}{TILE_COLOR}[2];
    my $tile_style = "color: #$colors[$tile_fg]; background-color: #$colors[$tile_bg]";

    my $build_fg = $materials{$mat}{BUILD_COLOR}[0] & 15;
    my $build_bg = $materials{$mat}{BUILD_COLOR}[1] & 15;
    $build_fg |= 8 if $materials{$mat}{BUILD_COLOR}[2];
    my $build_style = "color: #$colors[$build_fg]; background-color: #$colors[$build_bg]";

    print "<tr><th style=\"text-align: left\">", escape($mat), "</th>";
    print "<td><tt style=\"$tile_style\">", escape($tile x 6), "</tt> <tt style=\"$tile_style\">\x{263A}\x{263B}\x{263C}\x{2665}\x{2666}\x{2663}\x{2660}</tt></td>";
    print "<td><tt style=\"$basic_style\">O\x{2550}\x{2569}\x{2555},.;'+<>X\x{25B2}\x{25BC}\x{2022}</tt></td>";
    print "<td><tt style=\"$build_style\">\x{253C}\x{A2}xX\x{F7}\x{203C}</tt></td>";
    print "<td><code>", escape($materials{$mat}{tags}), "</code></td></tr>\n";
}

print "</table>\n";
