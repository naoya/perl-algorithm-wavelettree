package Algorithm::WaveletTree::Node;
use strict;
use warnings;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/ch bv sucbv bvcount count parent left right/);

# sub new {
#     my $class = shift;
#     my $self = $class->SUPER::new(@_);

#     $self->bvcount = 0;

#     bless $self, $class;
# }

sub is_leaf {
    shift->ch ? 1 : 0;
}

1;
