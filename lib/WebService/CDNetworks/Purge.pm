package WebService::CDNetworks::Purge;

use strict;
use warnings;

use Carp;
use Try::Tiny;
use URI::Escape;
use JSON;
use LWP::UserAgent;

use Moose;

my $MAX_PATHS_PER_CALL = 1000;

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

sub listPADs {

	my ($self) = @_;

	my $requestPayload = {
		'output' => 'json',
		'user'   => $self -> username,
		'pass'   => $self -> password,
	};

	my $url = $self -> baseURL . '/padList';
	$url .= '?' . join '&', map { $_ . '=' . uri_escape($requestPayload -> {$_}) } keys %$requestPayload;

	my $ua = $self -> ua;
	$ua -> timeout(10);
	$ua -> env_proxy;

	my $response = $ua -> get($url);

	unless ($response -> is_success) {
		die $response -> status_line;
	}

	my $json = decode_json($response -> decoded_content);

	unless ($json -> {'resultCode'} && $json -> {'resultCode'} == 200) {
		die 'Invalid $json -> {resultCode}: ' . ($json -> {'resultCode'} || '<undef>');
	}

	return $json -> {'pads'};

}

sub purgeItems {

	my ($self, $pad, $paths) = @_;

	unless ($pad) {
		croak 'No pad given!';
	}

	unless ($paths && ref($paths) && ref($paths) eq 'ARRAY') {
		croak 'Invalid paths given';
	}

	if (scalar (@$paths) == 0) {
		carp 'Zero paths given!';
		return;
	}

	if (scalar (@$paths) > $MAX_PATHS_PER_CALL) {
		croak 'Too many path given!';
	}

	my $requestPayload = {
		'output' => 'json',
		'user'   => $self -> username,
		'pass'   => $self -> password,
		'type'   => 'item',
		'pad'    => $pad,
		'path'   => $paths,
	};

	my $url = $self -> baseURL . '/doPurge';

	my $ua = $self -> ua;
	$ua -> timeout(10);
	$ua -> env_proxy;

	my $response = $ua -> post($url, $requestPayload);

	unless ($response -> is_success) {
		die $response -> status_line;
	}

	my $json = decode_json($response -> decoded_content);

	unless ($json -> {'resultCode'} && $json -> {'resultCode'} == 200) {
		die 'Error [' . $json -> {'resultCode'} . ']: ' . $json -> {'details'};
	}

	return $json -> {'pid'};

}

__PACKAGE__ -> meta -> make_immutable;
1;
