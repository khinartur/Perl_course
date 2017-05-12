package Local::MusicLib::Album;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;
use Mouse::Util::TypeConstraints;

use DateTime;

db "Local::MusicLib::DB::SQLite";

table 'album';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field artist_id => (
    isa => 'Int',
    index => 'uniq',
);

has_field year => (
    isa => 'Int',
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
);

enum 'TypeEnum', [qw(single soundtrack collection typical)];

has_field album_type => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
    trigger => \&_album_type,
);

sub _album_type {
    my ( $self, $value ) = @_;
 
    my $msg = $self->name;

    my %types = map { $_ => 1 } qw(single soundtrack collection typical);
 
    unless ( exists $types{$value} ) {
        $msg .= " - should be single or soundtrack or collection or typical!";
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