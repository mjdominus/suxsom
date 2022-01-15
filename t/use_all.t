#!perl

use Test::More;
use File::Find;
use lib 'lib';


system("pwd");

subtest "modules" => sub {
  find({ no_chdir => 1,
         wanted => sub {
             return unless -f && /\.pm$/;
             my $file = $File::Find::name;
             $file =~ s#^lib/##;
             ok(eval { require($file) }, "load $file");
         }}, "lib");
};

subtest "programs" => sub {
  find({ no_chdir => 1,
         wanted => sub {
         return unless -f && -x;
         is(system("perl", "-I", "lib", $File::Find::name, "dry_run=1"), 0, "run $File::Find::name");
       }}, "bin");
};

subtest "plugins" => sub {
  find({ no_chdir => 1,
         wanted => sub {
         return unless -f;
         is(system("perl", "-I", "lib", $File::Find::name, "dry_run=1"), 0, "run $File::Find::name");
       }}, "plugins");
};

done_testing;
