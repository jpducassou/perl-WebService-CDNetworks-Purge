use strict;
use warnings;

use Test::More tests => 4;
use Test::Exception;
use Test::NoWarnings 1.04 ':early';
use Test::LWP::UserAgent;

use_ok('WebService::CDNetworks::Purge');

subtest 'Preconditions' => sub {

	my $service;
	my $useragent = Test::LWP::UserAgent -> new();

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

	throws_ok {
		$service -> purgeItems(undef, ['/a.html', '/images/b.png']);
	} qr/No pad given/, 'pad not defined';

	throws_ok {
		$service -> purgeItems('', ['/a.html', '/images/b.png']);
	} qr/No pad given/, 'pad not defined';

	throws_ok {
		$service -> purgeItems('test.example.com');
	} qr/Invalid paths given/, 'Invalid paths given';

	throws_ok {
		$service -> purgeItems('test.example.com', '/a.html');
	} qr/Invalid paths given/, 'Invalid paths given';

	done_testing();

};

subtest 'Happy path' => sub {

	my $service;
	my $useragent = Test::LWP::UserAgent -> new();

	$useragent -> map_response(
		qr{https://openapi.us.cdnetworks.com/purge/rest/doPurge},
		HTTP::Response -> new('200', 'OK', ['Content-Type' => 'text/plain;charset=UTF-8'], '{
  "details": "item rest flush (2 items)",
  "notice": "",
  "paths": [
    "/a.html",
    "/images/b.png"
  ],
  "pid": 666,
  "resultCode": 200
}')
	);

	lives_ok {
		$service = WebService::CDNetworks::Purge -> new({
			'username' => 'xxxxxxxx',
			'password' => 'yyyyyyyy',
			'ua'       => $useragent,
		});
	} 'Contructor expecting to live';

	isa_ok($service, 'WebService::CDNetworks::Purge');

	my $purgeStatus = $service -> purgeItems('test.example.com', ['/a.html', '/images/b.png']);
	is_deeply($purgeStatus, [ 666 ], 'purgeItems returned the right id');

	$useragent -> unmap_all('true');

	done_testing();

};

## TODO: Some paths are not valid

## TODO: Auth failure

## TODO: Rate limit reached

