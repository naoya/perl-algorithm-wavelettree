package Algorithm::WaveletTree;
use strict;
use warnings;
use base qw/Class::Accessor::Lvalue::Fast/;

use Bit::Vector; ## NOTE: its my Bit::Vector, not the one on CPAN.
use Bit::Vector::Succinct;
use Heap::Simple::XS;
use Params::Validate qw/validate_pos/;

use Algorithm::WaveletTree::Node;

__PACKAGE__->mk_accessors(qw/tree code_map/);

sub new {
    my ($class, $text) = validate_pos(@_, 1, 1);
    my $self = $class->SUPER::new;

    my $count       = _build_count_table( \$text );
    $self->tree     = _build_huffman_tree( $count );
    $self->code_map = _build_code_map( $self->tree );

    ## FIXME: _build_count_table() とで unpack 2回やってる
    for my $c (unpack('C*', $text)) {
    }

    ## debug
    require Data::Dumper;
    warn Data::Dumper::Dumper($self->tree);
    warn Data::Dumper::Dumper($self->code_map);

    while (my ($ch, $code) = each %{$self->code_map}) {
        warn sprintf "%d => %d (%s)\n", $ch, $code, unpack('B*', pack('C', $code));
    }

    return $self;
}

sub create_node {
    return Algorithm::WaveletTree::Node->new;
}

sub _build_count_table {
    my $textref = shift;
    my $count = [];

    for (my $i = 0; $i < 0x100; $i++) {
        $count->[$i] = 0;
    }

    for my $c (unpack('C*', $$textref)) {
        $count->[$c]++;
    }

    return $count;
}

sub _build_huffman_tree {
    my $count = shift;

    my $heap = Heap::Simple::XS->new(
        order    => '<', # lowest value first
        elements => 'Object',
    );

    ## FIXME: alpha size 0x100
    ## FIXME: ノードが一つしかなかった場合の対応
    for (my $i = 0; $i < 0x100; $i++) {
        if ($count->[$i] > 0) {
            my $node = create_node;
            $node->ch    = $i;
            $node->count = $count->[$i];
            $node->bv    = Bit::Vector->new;
            $heap->key_insert( $node->count, $node );
        }
    }

    while (1) {
        my $n1 = $heap->extract_first;

        if (my $n2 = $heap->extract_first) {
            my $new = create_node;
            $new->count = $n1->count + $n2->count;
            $new->left  = $n1;
            $new->right = $n2;
            $heap->key_insert( $new->count, $new );
        } else {
            return $n1;
        }
    }
}

sub _build_code_map {
    my $root = shift;
    return make_code({}, $root, 0, 0);
}

sub make_code {
    my ($map, $node, $len, $code) = @_;

    if ($node->is_leaf) {
        $map->{ $node->ch } = $code;
    } else {
        make_code( $map, $node->left, $len++,  $code << 1);
        make_code( $map, $node->right, $len++, ($code << 1) | 1);
    }

    return $map;
}

sub insert {
    my ($self, $c) = validate_pos(@_, 1, 1);

    my $node  = $self->tree;
    my $depth = 0;

    while (!$node->is_leaf) {
    }
}

1;

__END__

## 最終的には必要な各ノードから必要なデータ以外全部破棄したツリーにする
