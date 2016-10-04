#!/usr/bin/perl -w

# A very ugly and primitive script to check DF raws for errors.  Currently detects:
# - duplicate objects
# - missing or incorrect [OBJECT:] tags
# - missing creature / caste names (no per-caste checks yet)
#
# Usage example: perl utils/check_raws.pl raw/objects/*.txt

use strict;
use warnings;

# read raws (TODO: check first lines)
my %raws;
my %sort;
foreach my $file (@ARGV) {
    warn "Skipping $file due to wrong suffix.\n" and next unless $file =~ /\.txt$/;
    open my $fh, '<:crlf', $file or die "Error opening $file: $!\n";
    my @lines = <$fh>;
    $raws{$file} = \@lines;
    $sort{$file} = (grep /\S/, @lines)[0] || "";
}

# sort by first non-blank lines
my @names = sort {$sort{$a} cmp $sort{$b}} keys %raws;

my %type_variants;
$type_variants{ITEM}{"ITEM_$_"}++ for qw(ARMOR WEAPON AMMO GLOVES HELM INSTRUMENT SHIELD SHOES SIEGEAMMO TOOL TOY TRAPCOMP PANTS FOOD);
$type_variants{BUILDING}{$_}++ for qw(BUILDING_WORKSHOP);
$type_variants{BODY}{$_}++ for qw(BODYGLOSS);
$type_variants{LANGUAGE}{$_}++ for qw(TRANSLATION WORD SYMBOL);

my %seen;
foreach my $file (@names) {
    my $lines = $raws{$file};
    my $first_seen;
    my $type;
    my $name;
    my $creature_name;
    my $caste_name;

    foreach my $ln (1 .. @$lines) {
	my $line = $lines->[$ln - 1];
	$first_seen = 1, next if not $first_seen and $line =~ /\S/;  # eat first non-blank line

	while ($line =~ /\[([^]]+)\]/g) {
	    my $tag = $1;
	    my @tag = split /:/, $tag;
	    if ($tag[0] eq 'OBJECT') {
		$type = $tag[1];
		$type =~ s/^DESCRIPTOR_//;
		$type_variants{$type}{$type} = 1;
	    }
	    elsif (not defined $type) {
		warn "Unexpected [$tag] on $file line $ln (missing [OBJECT:$tag[0]]?).\n";
		$type = "[]"; # kluge to avoid duplicate warnings
	    }
	    elsif (exists $type_variants{$type}{$tag[0]}) {
		if ($type eq 'CREATURE' and defined $name and not defined $creature_name) {
		    warn "[$type:$name] in $file (ends on line $ln) has no [NAME:] tag!\n";
		}
		if ($type eq 'CREATURE' and defined $name and not defined $caste_name) {
		    warn "[$type:$name] in $file (ends on line $ln) has no [CASTE_NAME:] tag!\n";
		}
		if (exists $seen{$tag}) {
		    warn "Duplicate [$tag] in $seen{$tag} and $file line $ln!\n";
		} else {
		    $seen{$tag} = "$file line $ln";
		}
		$name = $tag[1];
		undef $creature_name;
		undef $caste_name;
	    }
	    elsif (not defined $name and $type ne '[]') {
		warn "Unexpected [$tag] on $file line $ln (missing [$type:] tag?).\n";
		$name = "[]"; # kluge to avoid duplicate warnings	
	    }
	    elsif ($type eq 'CREATURE' and $tag[0] eq 'NAME') {
		my $cname = join ":", @tag[1..$#tag];
		warn "Duplicate name for [$type:$name] ([NAME:$creature_name] / [NAME:$cname]).\n" if defined $creature_name;
		$creature_name = $cname;
	    }
	    elsif ($type eq 'CREATURE' and $tag[0] eq 'CASTE_NAME') {
		$caste_name = join ":", @tag[1..$#tag];  # TODO: actually parse castes properly
	    }
	}
    }
    if (defined $type and $type eq 'CREATURE' and defined $name and not defined $creature_name) {
	warn "[$type:$name] in $file (ends at eof) has no [NAME:] tag!\n";
    } 
    if (defined $type and $type eq 'CREATURE' and defined $name and not defined $caste_name) {
	warn "[$type:$name] in $file (ends at eof) has no [CASTE_NAME:] tag!\n";
    }
}
