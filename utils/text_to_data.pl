#!/usr/bin/perl -w

# Script to encode and decode the Dwarf Fortress compressed
# announcement / help / dipscript files.
#
# Released into the public domain by Ilmari Karonen (Vyznev).
# Do whatever you want with it.
#
# Usage: Run once in your main DF folder with the --reverse switch to
# decode all compressed files from data/ to data_src/.  After editing
# the decoded text files, run without the --reverse switch to update
# the compressed files.  See below for more options.

use strict;
use warnings;
use Compress::Zlib qw'compress uncompress $gzerrno';
use Getopt::Long qw'GetOptions';

my $basedir = ".";
my $datadir = "data";
my $textdir = "data_src";

my $usage = <<"END";
Usage: $0 [options] <subdir(s)>
Options:
  --reverse, -r
    Decode compressed files into text files, rather than the opposite.
  --force, -f
    Overwrite target files even if they are newer than the source files.
  --quiet, -q
    Print nothing unless something goes wrong.
  --verbose, -v
    Show exactly what is being en/decoded.
  --basedir=<dir>, -d <dir>
    Look for the data/text directories under <dir> instead of "$basedir".
  --datadir=<dir>
    Subdirectory containing compressed data files (default: "$datadir").
  --textdir=<dir>
    Subdirectory containing uncompressed text files (default: "$textdir").
The remaining arguments should be file or directory names found under the
data/text subdirectories.
END

GetOptions( 'r|reverse'   => \my $reverse,
	    'f|force'     => \my $force,
	    'q|quiet'     => \my $quiet,
	    'v|verbose'   => \my $verbose,
	    'd|basedir=s' => \$basedir,
	    'datadir=s'   => \$datadir,
	    'textdir=s'   => \$textdir,
    ) or die $usage;

undef $quiet if $verbose;

# strip trailing slashes, strip base dir names from subdirs
# XXX: this is kind of a kluge, but allows use of command line completion and/or shell wildcards for subdirs
s!/*$!! for $basedir, $datadir, $textdir;
s!^\Q$basedir\E/!!, s!^(\Q$datadir\E|\Q$textdir\E)/!! for @ARGV;

$_ = "$basedir/$_" for $datadir, $textdir;
my $srcdir = ($reverse ? $datadir : $textdir);
my $dstdir = ($reverse ? $textdir : $datadir);

die "Source directory $srcdir not found.\n" unless -d $srcdir;
mkdir $dstdir or die "Error creating target directory $dstdir: $!\n" unless -d $dstdir;

my %skipdirs = ("." => 1, ".." => 1);  # don't recurse into these directories!

# traverse the directories:
my @stack = (@ARGV ? reverse @ARGV : ".");
while (@stack) {
    my $name = pop @stack;
    # catch errors with eval, resume from next entry:
    eval {
	my $srcpath = "$srcdir/$name";
	my $dstpath = "$dstdir/$name";
	s!(^|/)(\./)+!$1!g for $srcpath, $dstpath;  # strip useless /./ from paths

	if (!-e $srcpath) {
	    warn "$srcpath does not exist.\n";
	}
	elsif (-d _) {
	    # make sure the target directory exists:
	    unless (-d $dstpath) {
		mkdir $dstpath or die "Error creating $dstpath: $!\n";
	    }
	    # push contents of source directory on stack:
	    opendir DIR, $srcpath or die "Error opening directory $srcpath: $!\n";
	    push @stack, reverse map "$name/$_", grep !$skipdirs{$_}, readdir DIR;
	    closedir DIR, $srcpath or die "Error opening directory $srcpath: $!\n";
	}
	else {
	    # assume it's a file:
	    if ($reverse) {
		die "$srcpath already has .txt suffix, skipping.\n" if $srcpath =~ /\.txt$/;
		$dstpath .= ".txt";
	    } else {
		die "$srcpath doesn't have a .txt suffix, skipping.\n" unless $srcpath =~ /\.txt$/;
		$dstpath =~ s/\.txt$//;
	    }

	    my $srctime = (stat _)[9];
	    my $dsttime = (stat $dstpath)[9] || 0;

	    if ($dsttime >= $srctime and not $force) {
		# XXX: if the times are identical, silently assume the files to be up to date
		warn "$dstpath is newer than $srcpath (use --force to overwrite)\n" unless $dsttime == $srctime;
		return;
	    }
   	    if ($reverse) {
		decode_datafile($srcpath, $dstpath);
	    } else {
		encode_datafile($srcpath, $dstpath);
	    }
	    # set the target file's timestamp equal to the source file's:
	    utime $srctime, $srctime, $dstpath;
	}
    };
    # announce any errors caught by eval, then resume from next file:
    warn $@ if $@;
}
exit;


# decode compressed DF data file to a plain text file:
sub decode_datafile {
    my ($zipfile, $txtfile) = @_;
    my $filename = (split "/", $zipfile)[-1];

    # decode compressed file to text file
    open my $zip, '<', $zipfile or die "Failed to open $zipfile: $!\n";
    binmode $zip;
    local $/; # slurp mode
    my ($len, $deflate) = unpack "Va*", <$zip>;
    close $zip or die "Error reading $zipfile: $!\n";
    defined $len or die "Something went wrong reading $zipfile!\n";
    
    # verify length tag (also works as a file format check):
    die "$zipfile has mismatched length tag ($len != ".length($deflate).").\n"
	if $len != length $deflate;
    
    # kluge: deobfuscate index file
    my $index_mode = ($zipfile =~ m!/index$!);
    warn "Note: automatically deobfuscating index file $zipfile\n" if $index_mode and not $quiet;
    
    # decompress input data (secondary format check):
    my $data = uncompress $deflate;
    die "Uncompressing $zipfile failed: $gzerrno\n" unless defined $data;
    
    # open output file:
    open my $txt, '>:crlf', $txtfile or die "Failed to open $txtfile: $!\n";
    
    # extract line count from data stream:
    (my $n, $data) = unpack "Va*", $data;
    warn "Decoding $n lines from $zipfile to $txtfile\n" unless $quiet;
    
    # extract and print lines from data stream:
    foreach my $line (1 .. $n) {
	(my $len, my $len2, $data) = unpack "Vva*", $data;
	die "Error: length mismatch for line $line: $len != $len2\n" if $len != $len2;

	(my $str, $data) = unpack "a[$len]a*", $data;
	warn "Warning: expected $len bytes for line $line, got only ".length($str)."\n"
	    if $len != length $str;
	
	# kluge: deobfuscate index file
	$str =~ s/(.)/chr(255 - ($-[1] % 5) - ord $1)/seg if $index_mode;
	
	warn "Warning: non-ASCII characters found on line $line of $zipfile.\n" if $str =~ /[^\t -~]/;
	warn "Warning: first line \"$txt\" does not match file name $zipfile.\n"
	    if $line == 1 and $str ne $filename;

	print $txt $str, "\n";

	if ($verbose) {
	    s/\\/\\\\/g, s/\r/\\r/g, s/\n/\\n/g, s/\t/\\t/g for $str;
	    s/([^ -~])/sprintf "\\x%02X", ord $1/eg for $str;
	    warn "  line $line: \"$str\" ($len bytes)\n";
	}
    }
    
    # close output file:
    close $txt or die "Error writing to $txtfile: $!\n";
}


# encode plain text file to compressed DF data file:
sub encode_datafile {
    my ($txtfile, $zipfile) = @_;
    my $filename = (split "/", $zipfile)[-1];

    # open input text file:
    open my $txt, '<:crlf', $txtfile or die "Failed to open $txtfile: $!\n";
    my @lines = <$txt>;
    close $txt or die "Error reading $txtfile: $!\n";

    # strip newlines and trailing blank lines:
    s/\r?\n$// for @lines;
    pop @lines while @lines and $lines[-1] !~ /\S/;

    # consistency checks: 
    warn "Encoding ".@lines." lines from $txtfile to $zipfile\n" unless $quiet;
    warn "Warning: first line \"$lines[0]\" does not match file name $zipfile.\n"
	if @lines and $lines[0] ne $filename;

    if ($verbose) {
	foreach my $line (1 .. @lines) {
	    my $str = $lines[$line-1];
	    my $len = length $str;
	    s/\\/\\\\/g, s/\r/\\r/g, s/\n/\\n/g, s/\t/\\t/g for $str;
	    s/([^ -~])/sprintf "\\x%02X", ord $1/eg for $str;
	    warn "  line $line: \"$str\" ($len bytes)\n";
	}
    }

    # kluge: obfuscate index file
    if ($zipfile =~ m!/index$!) {
	warn "Note: automatically obfuscating index file $zipfile\n" unless $quiet;
	s/(.)/chr(255 - ($-[1] % 5) - ord $1)/seg for @lines;
    }

    # prepend length tags:
    $_ = pack "Vva*", length, length, $_ for @lines;
    
    # concatenate lines, prepend count tag and compress data:
    my $data = pack "V/(a*)*", @lines;
    my $deflate = compress $data;

    # write output file:
    open my $zip, '>', $zipfile or die "Failed to open $zipfile: $!\n";
    binmode $zip;
    print $zip pack("V", length $deflate), $deflate;
    close $zip or die "Error writing to $zipfile: $!\n";
}
