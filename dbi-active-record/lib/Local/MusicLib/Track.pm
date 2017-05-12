package Local::MusicLib::Track;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;

use DateTime;

db "Local::MusicLib::DB::SQLite";

table 'tracks';

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

has_field extension => (
    isa => 'Str',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->epoch },
    deserializer => sub { DateTime->from_epoch(epoch => $_[0]) },
);

has_field album_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;