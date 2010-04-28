set client_min_messages = warning;

drop table if exists release cascade;

create table release
(
	id serial primary key,
	site_id integer not null,
	section_id integer not null,
	name text not null,
	--may be null if no pre-time is available
	pre_time integer,
	file_count integer not null,
	comment_count integer not null,
	release_date timestamp not null,
	size bigint not null,
	download_count integer not null,
	seeder_count integer not null,
	leecher_count integer not null
);

drop table if exists user_data cascade;

create table user_data
(
	id serial primary key,
	name text not null
);

drop table if exists user_release_filter cascade;

create table user_release_filter
(
	id serial primary key,
	user_id integer references user_data(id) not null,
	filter text not null
);
