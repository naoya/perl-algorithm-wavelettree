use strict;
use warnings;
use Test::More qw/no_plan/;

use Algorithm::WaveletTree;

{
    my $wt = Algorithm::WaveletTree->new("abccbbabca");

    is $wt->rank(6, 'a'), 2;
    is $wt->rank(6, 'b'), 3;
    is $wt->rank(9, 'b'), 4;
    is $wt->rank(5, 'c'), 2;
    is $wt->rank(4, 'c'), 2;
    is $wt->rank(3, 'c'), 2;
    is $wt->rank(2, 'c'), 1;
    is $wt->rank(6, 'd'), 0;

    ## FIXME: rank() で pos が超えた場合の仕様を確認
    ## これでいいのかな?
    is $wt->rank(10, 'b'), 4;
    is $wt->rank(11, 'b'), 4;
    is $wt->rank(12, 'b'), 4;
    is $wt->rank(20, 'b'), 4;
}

{
    my $wt = Algorithm::WaveletTree->new("To be or not to be that is the question.");

    is $wt->rank(6, 'T'),  1;
    is $wt->rank(37, 't'), 5;
    is $wt->rank(37, '.'), 1;
    is $wt->rank(37, 'o'), 5;
    is $wt->rank(8,  'o'), 2;
}

