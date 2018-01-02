#!/usr/bin/env perl

# ============================================================================
use strict;
use warnings;

# ============================================================================
use Test::More tests => 2;
use Test::Exception;

use WebService::CDNetworks::Purge;

# ============================================================================
subtest 'Happy path' => sub {

	my $service = WebService::CDNetworks::Purge -> new();
	$service -> location('Korea');
	is($service -> baseURL, 'https://openapi.us.cdnetworks.com/purge/rest', 'Location is Korea');

};

subtest 'No parameter given' => sub {

	my $service = WebService::CDNetworks::Purge -> new();
	throws_ok {
		$service -> location();
	} qr/No location given/, 'location method called without parameter';

};

subtest 'Fallback' => sub {

	my $service = WebService::CDNetworks::Purge -> new();
	$service -> location('Unknown');
	is($service -> baseURL, 'https://openapi.us.cdnetworks.com/purge/rest', 'Location is unknown');

};

# ============================================================================
done_testing();


