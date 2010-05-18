set client_min_messages = warning;

drop table if exists user_data cascade;

create table user_data
(
	id serial primary key,
	name text unique not null,
	email text default null,
	--null if the standard search format is used
	search_format text default null,
	is_administrator boolean not null default false
);

drop table if exists user_release_filter cascade;

drop type if exists filter_type;
create type filter_type as enum ('name', 'nfo', 'genre');

create table user_release_filter
(
	id serial primary key,
	user_id integer references user_data(id) not null,
	filter text not null,
	release_filter_type filter_type not null,
	--may be null if no category is set
	category text default null
);

drop table if exists user_command_log;

create table user_command_log
(
	id serial primary key,
	user_id integer references user_data(id) not null,
	command_time timestamp default now() not null,
	command text not null
);

drop table if exists scene_access_data cascade;

create table scene_access_data
(
	id serial primary key,
	site_id integer unique not null,
	torrent_path text not null,
	section_name text not null,
	name text not null,
	--may be null if no NFO was available
	nfo text default null,
	--may be null because it cannot be extracted from the pages
	info_hash text,
	--may be null if no pre-time is available
	pre_time integer,
	file_count integer not null,
	release_date timestamp not null,
	release_size bigint not null,
	hit_count integer not null,
	download_count integer not null,
	seeder_count integer not null,
	leecher_count integer not null
);

create index scene_access_data_name_index on scene_access_data(name);

drop table if exists torrentvault_data;

create table torrentvault_data
(
	id serial primary key,
	site_id integer unique not null,
	torrent_path text not null,
	section_name text not null,
	name text not null,
	--NFOs are not available on TorrentVault - always null for now, this just means less work for the categoriser
	nfo text default null,
	--may be null if no pre-time is available
	pre_time integer,
	--genre is null for non-MP3 releases
	genre text,
	--unluckily the release date is not always available - use the added/release_date_offset fields otherwise
	release_date timestamp,
	added timestamp default now(),
	release_date_offset integer,
	release_size bigint not null,
	download_count integer not null,
	seeder_count integer not null,
	leecher_count integer not null,
	--may be null if the uploader is unknown
	uploader text
);

create index torrentvault_name_index on torrentvault_data(name);

create table torrentleech_data
(
	id serial primary key,
	site_id integer unique not null,
	torrent_path text not null,
	--may be null if it was from the index/archive
	info_hash text,
	section_name text not null,
	name text not null,
	--may be null if the NFO isn't available because the data was retrieved from the index/archive
	nfo text,
	release_date timestamp not null,
	release_size bigint not null,
	file_count integer not null,
	--not a straight forward extraction from single releases
	comment_count integer,
	download_count integer not null,
	seeder_count integer not null,
	leecher_count integer not null,
	uploader text not null
);

create index torrentleech_name_index on torrentleech_data(name);
