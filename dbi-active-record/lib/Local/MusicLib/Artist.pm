package Local::MusicLib::Artist;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;

use DateTime;

db "Local::MusicLib::DB::SQLite";

table 'artist';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
);

has_field country => (
    isa     => 'Str',
    trigger => \&_country_size,
);
 
sub _country_size {
    my ( $self, $value ) = @_;
 
    my $msg = $self->name;
 
    unless ( $value =~ m/^[a-z]{2}$/ ) {
        $msg .= " - should be 2-letter country code!";
        warn $msg;
    }
}

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->epoch },
    deserializer => sub { DateTime->from_epoch(epoch => $_[0]) },
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;