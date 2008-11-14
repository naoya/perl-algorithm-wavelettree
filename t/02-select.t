use strict;
use warnings;
use Test::More qw/no_plan/;

use Algorithm::WaveletTree;

{
    my $wt = Algorithm::WaveletTree->new("abccbbabca");

    is $wt->select(0, 'a'), 0;
    is $wt->select(1, 'a'), 6;
    is $wt->select(2, 'a'), 9;

    is $wt->select(0, 'b'), 1;
    is $wt->select(1, 'b'), 4;
    is $wt->select(2, 'b'), 5;
    is $wt->select(3, 'b'), 7;

    is $wt->select(0, 'c'), 2;
    is $wt->select(1, 'c'), 3;
    is $wt->select(2, 'c'), 8;

    is $wt->select(1, 'd'), undef;
    is $wt->select(2, 'd'), undef;

    ## FIXME: 範囲越え Succinct vector の方がおかしい
    # is $wt->select(5, 'c'), 0;
}

{
    my $wt = Algorithm::WaveletTree->new("To be or not to be that is the question.");

    is $wt->select(0, 'T'), 0;
    is $wt->select(0, 't'), 11;
    is $wt->select(1, 't'), 13;
    is $wt->select(2, 't'), 19;
    is $wt->select(3, 't'), 22;
}

