#!perl
# ABSTRACT: the Suxsom blog engine

package Suxsom;
use Moose;

has context => (
  is => 'ro',
  isa => 'HashRef',
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

has inputs => (
  is => 'ro',
  isa => 'ArrayRef{HashRef}',
  default => sub { [] },
);

has io_items => (
  is => 'ro',
  isa => 'ArrayRef[HashRef]',
  default => sub { {} },
);

sub run {
  my ($self, $opt) = @_;
  $self->load_plugins;
  $self->scan_inputs;           # locate input files
  $self->initialize_inputs;            # create input objects
  $self->generate;              # generate input-output mappings
  $self->check_mappings or exit 1;
  $self->build_all;
  $self->run_plugins("finished");
}

sub initialize_inputs {
  my ($self) = @_;
  for my $input (@{$self->{inputs}}) {
    $self->run_plugins("initialize_input", [$input]);
  }
}

sub generate {
  my ($self) = @_;
  for my $plugin ($self->plugins) {
    if ($plugin->can("generate")) {
      push @{$self->io_items}, $plugin->generate($self->context, $self->inputs);
    }
  }
}

# Make sure no output file is described by more than one io item
sub check_mappings {
  my ($self) = @_;
  my $OK = 1;
  $OK &&= $self->check_outputs_unique;
  $OK &&= $self->check_disabled_inputs_unused;
  exit 1 unless $OK;
}

sub check_outputs_unique {
  my ($self) = @_;
  my %seen; # list of items that contain each output - should be exactly 1
  for my $item (@{$self->io_items}) {
    my $owner = $item->{owner};
    for my $output (@{$item->{output}}) {
      push @{$seen{$output}}, $item;
    }
  }

  my $OK = 1;
  for my $output (sort keys %seen) {
    my @items = @{$seen{$output}};
    if (@items > 1) {
      $OK = 0;
      my $warning = sprintf "Output '$output' is to be generated more than once, by:\n";
      for my $item (@items) {
        my $msg = sprintf "  plugin %s (type %s) from inputs <%s>\n",
          $item->{owner}, $item->{type},
            join(", " => @{$item->{input}});
        $warning .= $msg;
      }
      $self->warn(0, $warning);
    }
  }
  return $OK;
}

sub check_disabled_inputs_unused {
  my ($self) = @_;
  my $OK = 1;
  for my $item (@{$self->io_items}) {
    next unless @{$item->{outputs}};
    for my $input (@{$item->inputs}) {
      if ($input->{inactive}) {
        $self->warn(0, sprintf("Inactive input '%s' is required for outputs <%s>\n",
                               $input->{filename},
                               join(", " => @{$item->{outputs}})));
        $OK = 0;
      }
    }
  }
  return $OK;
}

sub build_all {
  my ($self) = @_;
  # At this point the io items are sorted in dependency order
  for my $item (@{$self->io_items}) {
    $self->build_item($item);
  }
}

# Build all the required outputs for this io item
sub build_item {
  my ($self, $item) = @_;
  my $OK = 1;
  my %unbuilt_outputs = set(@{$item->{output}});
  for my $k (keys %unbuilt_outputs) {
    unless ($self->build_output($k, $item)) {
      $self->fatal_o_item("Couldn't build output file '%s' from inputs <%s>",
                          $k, $item);
      $OK = 0;
    }
  }
  return $OK;
}

# Build a single output for an io item
sub build_output {
  my ($self, $output, $item) = @_;
  for my $plugin ($self->plugins) {
    if ($plugin->can("will_build") && $plugin->can("build")
          && $plugin->will_build($self->context, $output, $item)) {
      return $plugin->build($self->context, $output, $item);
    }
  }
  $self->fatal_o_item("Couldn't find any plugin willing to build '%s' from inputs <%s>",
                      $output, $item);
  return;
}

sub load_plugins {
  my ($self) = @_;
  my $dir = $self->plugin_dir;
  opendir my($dh), $dir or do {
    $self->warn(0, sprintf "Couldn't read plugin dir '%s': %s",
                $dir, $!);
    exit 2;
  };
  my $plugin = $self->plugin_hash;

  my @files = sort grep !/^\./, readdir $dh;
  my $OK = 1;
  for my $file (@files) {
    my $plugin_class = require $file;
    $plugin->{$plugin_class} = $plugin_class->new($self->context) or do {
      $self->warn(0, sprintf("Couldn't initialize plugin '%s'", $file));
      $OK = 0;
    };
  }
  exit 1 unless $OK;
}

# traverse the input directory and build input items for each file and directory
# found therein
sub scan_inputs {
  my ($self) = @_;
  my @queue = [$self->input_dir, ""];
  while (@queue) {
    my ($dir, $fn) = @{shift @queue};
    my $file = "$dir/$fn";

    my $type = -d $file ? "dir" : "file";
    my $mtime = (stat _)[9];
    my $input = { dir => $dir, basename => $fn, filename => $file,
                  mtime => $mtime, type => $type };
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

sub run_plugins {
  my ($self, $plugin_method, $arglist, $opt) = @_;
  for my $plugin ($self->plugins) {
    if ($plugin->can($plugin_method)) {
      $plugin->$plugin_method($self->context, @$arglist);
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

sub fatal_o_item {
  my ($self, $format, $output, $item) = @_;
  my @inputs = @{$item->{input}};
  $self->warn(sprintf $format,
              $output,
              join(", " => @inputs));
}

sub emit {
  CORE::warn @_;
}

sub _set { map { $_ => 1 } @_ }

1;
