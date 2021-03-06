package Edge::Customer;

use Moose;

has 'schema' => (
  is => 'ro',
  isa => 'Edge::Schema',
  required => 1,
);

has 'id' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'profile_form' => (
  is => 'ro',
  isa => 'HashRef',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $profile_form = $self->schema->resultset('FormSubmission')->search(
                    {
                      'data' => \["->>'id' = ?", $self->id],
                      'data' => \["->>'form' = 'profile'"],
                    },
                    {
                      'order_by' => { -desc => 'id' },
                    },
                  )->first;
    if ($profile_form && ref $profile_form->data) {
      return $profile_form->data;
    }
    else {
      return {};
    }
  },
);

has 'name' => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $name = ($self->profile_form->{fname} || '') . ' ' . ($self->profile_form->{lname} || '');
    if ($name eq ' ') { return '--not set--'; }
    return $name;
  },
);

has 'orders' => (
  is => 'ro',
  isa => 'ArrayRef[Edge::Order]',
  lazy => 1,
  default => sub {
    my $self = shift;
    return [];
  },
);


no Moose;
__PACKAGE__->meta->make_immutable;
