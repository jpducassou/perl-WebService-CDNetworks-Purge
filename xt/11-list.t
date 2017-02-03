#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Exception;
use Test::LWP::UserAgent;

use WebService::CDNetworks::Purge;

subtest 'Invalid contructor parameters' => sub {

	throws_ok {
		my $service = WebService::CDNetworks::Purge -> new({});
	} qr/Attribute \(\w+\) is required at constructor/, 'constructor called without credentials';

};

subtest 'Valid contructor parameters' => sub {

	my $useragent = Test::LWP::UserAgent -> new();
	my $service;

	lives_ok {
		$service = WebService::CDNetworks::Purge -> new(
			'username' => 'xxxxxxxx',
			'password' => 'yyyyyyyy',
			'ua'       => $useragent,
		);
	} 'Contructor expecting to live';

	isa_ok($service, 'WebService::CDNetworks::Purge');

};

subtest 'Not success' => sub {

	my $useragent = Test::LWP::UserAgent -> new();
	my $service = WebService::CDNetworks::Purge -> new(
		'username' => 'xxxxxxxx',
		'password' => 'yyyyyyyy',
		'ua'       => $useragent,
	);

	throws_ok {
		$service -> listPADs();
	} qr/404 Not Found/, 'URL not found';

};

subtest 'result code not 200' => sub {

	my $useragent = Test::LWP::UserAgent -> new();
	$useragent -> map_response(
		qr{https://openapi.us.cdnetworks.com/purge/rest/padList\?.*output=json},
		HTTP::Response -> new('200', 'OK', ['Content-Type' => 'text/plain;charset=UTF-8'], '{
		"details": "Internal server error",
		"pads": [],
		"resultCode": 500
	}')
	);

	my $service = WebService::CDNetworks::Purge -> new(
		'username' => 'xxxxxxxx',
		'password' => 'yyyyyyyy',
		'ua'       => $useragent,
	);

	throws_ok {
		$service -> listPADs();
	} qr/Invalid .*: 500/, 'Service status not 200';

};

subtest 'Happy path' => sub {

	my $useragent = Test::LWP::UserAgent -> new();
	$useragent -> map_response(
		qr{https://openapi.us.cdnetworks.com/purge/rest/padList\?.*output=json},
		HTTP::Response -> new('200', 'OK', ['Content-Type' => 'text/plain;charset=UTF-8'], '{
		"details": "Found 2 PAD(s) that you can access",
		"pads": [
			"s.examplestatic.com",
			"test.example.com"
		],
		"resultCode": 200
	}')
	);

	my $service = WebService::CDNetworks::Purge -> new(
		'username' => 'xxxxxxxx',
		'password' => 'yyyyyyyy',
		'ua'       => $useragent,
	);

	my $PADlist = $service -> listPADs();
	my $expected = [
		's.examplestatic.com',
		'test.example.com',
	];

	is_deeply($PADlist, $expected, 'PAD list of two elements');

};

## TODO: Auth failure

## TODO: Rate limit exceeded

