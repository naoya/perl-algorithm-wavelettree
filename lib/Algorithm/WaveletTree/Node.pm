package Algorithm::WaveletTree::Node;
use strict;
use warnings;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/ch bv sucbv bvcount count parent left right is_leaf/);

1;
