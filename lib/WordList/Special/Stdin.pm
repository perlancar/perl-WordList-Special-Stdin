package WordList::Special::Stdin;

use strict;
use parent qw(WordList);

use Role::Tiny::With;
with 'WordListRole::EachFromFirstNextReset';

# AUTHORITY
# DATE
# DIST
# VERSION

our $DYNAMIC = 1;

our %PARAMS = (
    cache => {
        summary => 'Whether to cache the words the first time until EOF, then reuse them later',
        schema => 'bool*',
    },
);

sub reset_iterator {
    my $self = shift;
    if ($self->{cache}) {
        $self->{_iterator_idx} = 0;
    } else {
        warn "Warning: resetting a non-resettable wordlist (Special::Stdin)";
    }
}

sub first_word {
    my $self = shift;
    $self->reset_iterator if defined $self->{_iterator_idx};
    $self->next_word;
}

sub next_word {
    my $self = shift;

    $self->{_iterator_idx} = 0 unless defined $self->{_iterator_idx};
    if ($self->{_eof}) {
        if ($self->{_cache}) {
            return undef if $self->{_iterator_idx}++ >= @{ $self->{_words} }; ## no critic: Subroutines::ProhibitExplicitReturnUndef
            return $self->{_words}[ $self->{_iterator_idx} ];
        } else {
            return undef; ## no critic: Subroutines::ProhibitExplicitReturnUndef
        }
    }

    my $word = <STDIN>;
    if (defined $word) {
        chomp $word;
    } else {
        $self->{_eof}++;
    }
    if ($self->{cache}) {
        $self->{_words} = [] unless defined $self->{_words};
        push @{ $self->{_words} }, $word if defined $word;
    }
    $self->{_iterator_idx}++;
    return $word;
}

1;
# ABSTRACT: Wordlist from STDIN

=head1 SYNOPSIS

From Perl:

 use WordList::Special::Stdin;

 my $wl = WordList::Special::Stdin->new();
 $wl->each_word(sub { ... });

From the command-line:

 % some-prog-that-produces-words | wordlist -w Special::Stdin

Typical use-case is to filter some words, either some L<wordlist> or other
programs:

 % wordlist ... | wordlist -w Special::Stdin --len 5 '/foo/'


=head1 DESCRIPTION

This is a special wordlist to get list of words from standard input.


=head1 SEE ALSO

L<WordList>
