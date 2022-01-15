#!perl
# ABSTRACT: the Suxsom blog engine

package Suxsom;
use Moose;

has context => (
  is => 'ro',
  isa => 'Suxsom::Context',
  default => sub { {} },
);

has warnlevel => (
  is => 'rw',
  isa => 'Int',
  default => 2,
);

for my $dir (qw(input output plugin)) {
  has "$dir\_dir" => (
    is => 'ro',
    isa => 'Str',
    required => 1,
   );
}

has plugin_hash => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { {} },
  traits => ['Hash'],
  handles => {
    plugins      => 'values',
    plugin_names => 'keys',
    plugin       => 'get',
  },
);

# These items are hashes
# which may contain file content from the input files
# and metainformation like a MIME type
# or the name of the plugin that created them.
# Plugins might modify these in place
# or use them to create new products.
# Some plugins, seeing a completed product,
# might write it to a disk file in the appropriate place. 
has products => (
  is => 'ro',
  isa => 'ArrayRef[HashRef]',
  default => sub { {} },
  traits => ['Array'],
  handles => {
    add_products => 'push',
  },
);

sub run {
  my ($self, $opt) = @_;
  $self->load_config();  
  $self->load_plugins($self->plugin_dir);
  $self->build_all or exit 1;
  $self->run_plugins("finished");
}

sub load_plugins {
  my ($self, $dir) = @_;
  opendir my($dh), $dir or do {
    $self->warn(0, sprintf "Couldn't read plugin dir '%s': %s",
                $dir, $!);
    exit 2;
  };
  my $plugin = $self->plugin_hash;

  my @files = sort grep !/^\./, readdir $dh;
  my $OK = 1;
  for my $file (@files) {
    if (-d $file) {
      $self->load_plugins("$dir/$file");
    } else {
      require $file;
      my $plugin_class = $file;
      $plugin->{$plugin_class} = $plugin_class->new($self->context) or do {
        $self->warn(0, sprintf("Couldn't initialize plugin '%s'", $file));
        $OK = 0;
      };
    }
  }
  exit 1 unless $OK;
}

# traverse the input directory and build input items for each file and
# directory found therein
# Perhaps most of this should be delegated to plugins
sub scan_inputs {
  my ($self) = @_;
  my @queue = [$self->input_dir, ""];
  while (@queue) {
    my ($dir, $fn) = @{shift @queue};
    my $file = "$dir/$fn";

    my $type = -d $file ? "dir" : "file";
    my $mtime = (stat _)[9];
    my $input = { dir => $dir, basename => $fn, filename => $file,
                  mtime => $mtime, type => $type, path => "$dir/$file" };
    push @{$self->inputs}, $input;

    if ($type eq "dir") {
      my $dh;
      unless (opendir $dh, $file) {
        $self->warn(1, sprintf("Couldn't read directory '%s': %s; skipping\n",
                               $file, $!));
        next;
      }
      my @dirents = grep { $_ ne "." && $_ ne ".." } readdir $dh;
      push @queue, map { [ $file, $_ ] } @dirents;
    }
  }
}

sub initialize_inputs {
  my ($self) = @_;
  for my $input (@{$self->{inputs}}) {
    $self->run_plugins("initialize_input", [$input]);
  }
}

sub generate {
  my ($self) = @_;
  $self->run_plugins("generate",
                     [ $self->inputs ],
                     sub { $self->add_products(@_) },
                    );
}

#
# For each plugin,
# either run its build_all method on all the current products
# or run its build method on the current products one at a time.
# If it fails, report the error and stop after running this plugin.
sub build_all {
  my ($self) = @_;
  # At this point the products are sorted in dependency order
  for my $plugin ($self->plugins) {
    my $products = $self->products;
    my $GOOD = 1;
    my @new_products;
    my ($status, $new_products) ;
    if ($plugin->can("build_all")) {
      ($status, $new_products) = $plugin->build_all($self->context,
                                                    $products);
      if ($status eq "success") {
        $self->add_products(@$new_products);
      } else {
        $self->failed_build_warning($plugin, $status);
        return;
      }
    } elsif ($plugin->can("build")) {
      for my $item (@$products) {
        ($status, $new_products) = $plugin->build($item);
        if ($status eq "success") {
          $self->add_products(@$new_products);
        } else {
          $self->failed_build_warning($plugin, $status, $item);
          $GOOD = 0;
        }
      }
      return unless $GOOD;
    }
  }
  return 1;
}

sub failed_build_warning {
  my ($self, $plugin, $status, $item) = @_;
  if ($item) {
    $self->warn(0,
                sprintf("Plugin '%s' failed to build item '%s': %s",
                        $plugin->what,
                        $self->describe_product($item),
                        $status));
  } else {
    $self->warn(0,
                sprintf("Plugin '%s' failed to build all items: %s",
                        $plugin->what,
                        $status));
  }
}

sub run_plugins {
  my ($self, $plugin_method, $arglist, $opt) = @_;
  for my $plugin ($self->plugins) {
    if ($plugin->can($plugin_method)) {
        my @res = $plugin->$plugin_method($self->context, @$arglist);
        if ($opt->{postprocess}) {
            $opt->{postprocess}->(@res);
        }
    }
  }
}

# level 0 = fatal error
# level 1 = serious error
# level 2 = warning
# level 3 = informational
sub warn {
  my ($self, $level, @msgs) = @_;
  return if $level > $self->warnlevel;
  $self->emit($_) for @msgs;
}

sub emit {
  CORE::warn @_;
}

sub _set { map { $_ => 1 } @_ }
1;

