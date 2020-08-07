#!perl -*- cperl-mode -*-

use Test::More;
use Test::Deep;
use Suxsom::Context;

my $ctx = Suxsom::Context->new(
  prop => { a => 1, b => 2, aa => 3, aba => 4, ca => 5 }
);

cmp_deeply({ $ctx->subhash('a') },
           { a => 1, aa => 3, aba => 4 }, "subhash a");
cmp_deeply({ $ctx->subhash('b') },
           { b => 2 }, "subhash b");
cmp_deeply({ $ctx->subhash('w') },
           { }, "subhash w");
is($ctx->get('aba'), 4, 'get aba');

done_testing;
