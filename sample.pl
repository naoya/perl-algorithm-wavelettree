#!/usr/bin/env perl
use strict;
use warnings;

use FindBin::libs;
use Perl6::Say;

use Data::Dumper qw/Dumper/;

use Algorithm::WaveletTree;

my $text = shift or die "usage: $0 <text>";
my $wt = Algorithm::WaveletTree->new($text);
