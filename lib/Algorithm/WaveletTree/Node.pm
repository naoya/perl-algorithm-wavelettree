package Algorithm::WaveletTree::Node;
use strict;
use warnings;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/ch bv sucbv count parent left right/);

sub is_leaf {
    shift->ch ? 1 : 0;
}

1;
