#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;
use Test::LWP::UserAgent;

use WebService::CDNetworks::Purge;

subtest 'Happy path' => sub {

	my $service;
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

	throws_ok {
		$service = WebService::CDNetworks::Purge -> new({});
	} qr/Attribute \(\w+\) is required at constructor/, 'constructor called without credentials';

	lives_ok {
		$service = WebService::CDNetworks::Purge -> new({
			'username' => 'xxxxxxxx',
			'password' => 'yyyyyyyy',
			'ua'       => $useragent,
		});
	} 'Contructor expecting to live';

	isa_ok($service, 'WebService::CDNetworks::Purge');

	my $PADlist = $service -> listPADs();
	my $expected = [
		's.examplestatic.com',
		'test.example.com',
	];

	is_deeply($PADlist, $expected, 'PAD list of two elements');

};

## TODO: Auth failure

## TODO: Rate limit exceeded

