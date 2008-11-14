#!/usr/bin/env perl
use strict;
use warnings;

use FindBin::libs;
use Perl6::Say;

use Algorithm::WaveletTree;

my $wt = Algorithm::WaveletTree->new("abccbbabca");

say sprintf "rank(6, 'a') 2 => %d", $wt->rank(6, 'a');
say sprintf "rank(6, 'b') 3 => %d", $wt->rank(6, 'b');
say sprintf "rank(9, 'b') 4 => %d", $wt->rank(9, 'b');
say sprintf "rank(5, 'c') 2 => %d", $wt->rank(5, 'c');
say sprintf "rank(4, 'c') 2 => %d", $wt->rank(4, 'c');
say sprintf "rank(3, 'c') 2 => %d", $wt->rank(3, 'c');
say sprintf "rank(2, 'c') 1 => %d", $wt->rank(2, 'c');
say sprintf "rank(6, 'd') 0 => %d", $wt->rank(6, 'd');

say sprintf "select(0, 'a') 0 => %d", $wt->select(0, 'a');
say sprintf "select(1, 'a') 6 => %d", $wt->select(1, 'a');
say sprintf "select(2, 'a') 9 => %d", $wt->select(2, 'a');

say sprintf "select(0, 'b') 1 => %d", $wt->select(0, 'b');
say sprintf "select(1, 'b') 4 => %d", $wt->select(1, 'b');
say sprintf "select(2, 'b') 5 => %d", $wt->select(2, 'b');
say sprintf "select(3, 'b') 7 => %d", $wt->select(3, 'b');

say sprintf "select(0, 'c') 2 => %d", $wt->select(0, 'c');
say sprintf "select(1, 'c') 3 => %d", $wt->select(1, 'c');
say sprintf "select(0, 'c') 8 => %d", $wt->select(2, 'c');

