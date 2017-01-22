use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;
use Test::NoWarnings 1.04 ':early';
use Test::LWP::UserAgent;

use_ok('WebService::CDNetworks::Purge');

subtest 'Happy path' => sub {

	my $service;
	my $useragent = Test::LWP::UserAgent -> new();

	$useragent -> map_response(
		qr{https://openapi.us.cdnetworks.com/purge/rest/status\?.*pid=666},
		HTTP::Response -> new('200', 'OK', ['Content-Type' => 'text/plain;charset=UTF-8'], '{
		"resultCode": 200,
		"details": "success",
		"percentComplete": 100.0
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

	my $status = $service -> status(666);
	my $expected = {
		'resultCode'      => 200,
		'details'         => 'success',
		'percentComplete' => 100.0,
	};

	is_deeply($status, $expected, 'status');

};

## TODO: Auth failure

## TODO: Rate limit exceeded

