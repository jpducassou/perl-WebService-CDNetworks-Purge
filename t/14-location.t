#!/usr/bin/env perl

# ============================================================================
use strict;
use warnings;

# ============================================================================
use Test::More tests => 3;
use Test::Exception;
use Test::LWP::UserAgent;

use WebService::CDNetworks::Purge;

# ============================================================================
subtest 'Happy path' => sub {

	my $useragent = Test::LWP::UserAgent -> new();
	my $service = WebService::CDNetworks::Purge -> new(
		'username' => 'xxxxxxxx',
		'password' => 'yyyyyyyy',
		'ua'       => $useragent,
	);

	$service -> location('Korea');
	is($service -> baseURL, 'https://openapi.us.cdnetworks.com/purge/rest', 'Location is Korea');

};

subtest 'No parameter given' => sub {

	my $useragent = Test::LWP::UserAgent -> new();
	my $service = WebService::CDNetworks::Purge -> new(
		'username' => 'xxxxxxxx',
		'password' => 'yyyyyyyy',
		'ua'       => $useragent,
	);

	throws_ok {
		$service -> location();
	} qr/No location given/, 'location method called without parameter';

};

subtest 'Fallback' => sub {

	my $useragent = Test::LWP::UserAgent -> new();
	my $service = WebService::CDNetworks::Purge -> new(
		'username' => 'xxxxxxxx',
		'password' => 'yyyyyyyy',
		'ua'       => $useragent,
	);

	$service -> location('Unknown');
	is($service -> baseURL, 'https://openapi.us.cdnetworks.com/purge/rest', 'Location is unknown');

};

# ============================================================================
done_testing();


