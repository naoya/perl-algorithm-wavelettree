package Algorithm::WaveletTree;
use strict;
use warnings;
use base qw/Class::Accessor::Lvalue::Fast/;

use Heap::Simple::XS;
use Params::Validate qw/validate_pos ARRAYREF/;

## NOTE: its my Bit::Vector, not the one on CPAN.
use Bit::Vector;
use Bit::Vector::Succinct;

use Algorithm::WaveletTree::Node;
use Algorithm::WaveletTree::Code;

__PACKAGE__->mk_accessors(qw/tree code_map leaf_map text_len debug/);

sub new {
    my ($class, $text) = validate_pos(@_, 1, 1);
    my $self = $class->SUPER::new;

    $self->text_len = length $text;
    my $count         = _build_count_table( \$text );
    $self->tree       = _build_huffman_tree( $count );
    $self->code_map   = _build_code_map( $self->tree );
    $self->leaf_map   = {};

    ## FIXME: _build_count_table() とで unpack 2回やってる
    # my $nchars = keys %{$self->code_map};
    for my $c (unpack('C*', $text)) {
        my $code = $self->code_map->{$c};

        if (not defined $code) {
            die 'assert';
        }

        $self->insert($code);
    }

    travarse_tree($self->tree, sub {
        my $node = shift;
        if (!$node->is_leaf) {
            $node->sucbv = Bit::Vector::Succinct->new($node->bv);
            $node->bv    = undef;
        } else {
            $self->leaf_map->{ $node->ch } = $node;
        }
    });

#     require Data::Dumper;
#     warn Data::Dumper::Dumper($self->tree);
#     warn Data::Dumper::Dumper($self->code_map);

#     while (my ($ch, $code) = each %{$self->code_map}) {
#         warn sprintf "%d => %d (%s)\n", $ch, $code->code, unpack('b*', pack('C', $code->code));
#     }

#     travarse_tree($self->tree, sub {
#          my $node = shift;
#          warn sprintf "%s (%d)\n", $node->bv->as_bitstring, $node->bvcount;
#     });

    return bless $self, $class;
}

sub travarse_tree {
    my ($node, $sub) = validate_pos(@_ ,1 ,1);
    if (not defined $node) {
        return;
    } else {
        $sub->($node);
        travarse_tree($node->left, $sub);
        travarse_tree($node->right, $sub);
    }
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
        order    => '<',
        elements => 'Object',
    );

    ## FIXME: alpha size 0x100 が固定
    ## FIXME: ノードが一つしかなかった場合の対応
    for (my $i = 0; $i < 0x100; $i++) {
        if ($count->[$i] > 0) {
            my $leaf = create_node;
            $leaf->ch    = $i;
            $leaf->count = $count->[$i];
            $heap->key_insert( $leaf->count, $leaf );
        }
    }

    while (1) {
        my $n1 = $heap->extract_first;

        if (my $n2 = $heap->extract_first) {

            my $new = create_node;
            $new->count   = $n1->count + $n2->count;
            $new->left    = $n1;
            $new->right   = $n2;
            $new->bvcount = 0;
            $new->bv      = Bit::Vector->new;

            $n1->parent = $new;
            $n2->parent = $new;

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
        $map->{ $node->ch } = Algorithm::WaveletTree::Code->new([ $code, $len ]);
    } else {
        make_code( $map, $node->left,  $len + 1, $code << 1);
        make_code( $map, $node->right, $len + 1, ($code << 1) | 1);
    }

    return $map;
}

sub insert {
    my ($self, $code) = validate_pos(@_, 1, { type => ARRAYREF });

    my $node  = $self->tree;
    my $depth = $code->bit_length - 1;

    while (!$node->is_leaf) {
        my $bit = (($code->code >> $depth) & 1);
        if ($bit == 1) {
            $node->bv->set( $node->bvcount++ );
            $node = $node->right;
        } else {
            $node->bvcount++;
            $node = $node->left;
        }
        $depth--;
    }
}

sub rank {
    my ($self, $pos, $ch) = validate_pos(@_, 1, 1, 1);
    my $code = $self->code_map->{ord $ch};

    if (!$code) {
        return 0;
    }

    if ($pos >= $self->text_len) {
        $pos = $self->text_len - 1;
    }

    my $node  = $self->tree;
    my $depth = $code->bit_length - 1;

    while (1) {
        my $bit = (($code->code >> $depth) & 1);

        $pos  = $node->sucbv->rank($pos, $bit);
        $node = $bit ? $node->right : $node->left;

        if ($pos == 0 || $node->is_leaf) {
            last;
        } else {
            $depth--;
            $pos--;
        }
    }

    return $pos;
}

sub select {
    my ($self, $i, $ch) = validate_pos(@_, 1, 1, 1);
    my $code = $self->code_map->{ord $ch};

    if (!$code) {
        return;
    }

    if ($i >= $self->text_len) {
        $i = $self->text_len - 1;
    }

    my $depth = 0;
    my $node  = $self->leaf_map->{ord $ch}->parent;
    if ($node->is_leaf) {
        die 'assert'
    }

    while (defined $node) {
        my $bit = (($code->code >> $depth) & 1);
        $i = $node->sucbv->select($i, $bit);
        $node = $node->parent;
        $depth++;
    }

    return $i;
}

1;

__END__

## TODO
## 1. 最終的には必要な各ノードから必要なデータ以外全部破棄したツリーにする
## new の引数をテキストのリファレンスに
