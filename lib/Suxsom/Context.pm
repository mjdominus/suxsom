# -*- cperl -*-

package Suxsom::Context;
use Moose;

has 'prop' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { {} },
  traits => [ 'Hash' ],
  handles => {
    get => 'get',
    put => 'set',
    keys => 'keys',
  },
);

sub subhash { 
  my ($self, $prefix) = @_;
  my %sh;
  for my $k (grep /^$prefix/, $self->keys) {
    $sh{$k} = $self->get($k);
  }
  return %sh;
}

sub warn {
  my ($self, $fmt, @args) = @_;
  CORE::warn sprintf $fmt, @args;
}

sub info {
  my ($self, $fmt, @args) = @_;
  CORE::warn sprintf $fmt, @args
}

1;
