package WebService::CDNetworks::Purge;

use strict;
use warnings;

use Try::Tiny;
use Data::Dumper;
use URI::Escape;
use JSON;
use LWP::UserAgent;

use Moose;

has 'baseURL' => (
	is       => 'ro',
	isa      => 'Str',
	default  => sub { 'https://openapi.us.cdnetworks.com/purge/rest' }
);

has 'ua' => (
	is       => 'ro',
	isa      => 'LWP::UserAgent',
	required => 1,
	lazy     => 1,
	default  => sub { LWP::UserAgent -> new() }
);

has 'username' => (
	is       => 'ro',
	isa      => 'Str',
	required => 1
);

has 'password' => (
	is       => 'ro',
	isa      => 'Str',
	required => 1
);

sub list {

	my ($self) = @_;

	my $username = uri_escape($self -> username);
	my $password = uri_escape($self -> password);
	my $operation = 'padList';

	my $url = $self -> baseURL . "/$operation?output=json&user=$username&pass=$password";

	my $ua = $self -> ua;
	$ua -> timeout(10);
	$ua -> env_proxy;

	my $response = $ua -> get($url);

	warn '[DEBUG]: status line: ' . $response -> status_line;

	unless ($response -> is_success) {
		die $response -> status_line;
	}

	my $json = decode_json($response -> decoded_content);

	unless ($json -> {'resultCode'} && $json -> {'resultCode'} == 200) {
		die 'Invalid $json -> {resultCode}: ' . ($json -> {'resultCode'} || '<undef>');
	}

# print Dumper($json);
	return $json -> {'pads'};

}

__PACKAGE__ -> meta -> make_immutable;
1;
