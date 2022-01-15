# -*- cperl -*-

package Suxsom::Plugin;
use Moose;

has what => (
  is => 'ro',
  isa => 'Str',
  reader => 'me',
);

around BUILDARGS => sub {
  my $orig = shift;
  my $class = shift;
  my ($ctx) = @_;
  my $what //= ($class->what // $class);
  my $ctx_prefix = $what;
  $ctx_prefix =~ s/^Suxsom:://;
  $ctx_prefix =~ s/::/_/g;
  my %h = (what => $what, $ctx->subhash($ctx_prefix));
  return $class->$orig(%h);
};

sub what { return }

sub filter_products {
  my ($self, $pred, $products) = @_;
  return [ grep $pred->($_), @$products ];
}

1;
