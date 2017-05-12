package Local::MusicLib::DB::SQLite;
use Mouse;
extends 'DBI::ActiveRecord::DB::SQLite';

sub _build_connection_params {
    my ($self) = @_;
    return [
        'dbi:SQLite:dbname=/Users/khinartur/Desktop/dbi-active-record/lib/Local/MusicLib/DB/music_library.db', '', '', {}
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;