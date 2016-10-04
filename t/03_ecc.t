# -*- mode: cperl; -*-

# Elliptic curve CSR tests
#
# This software is copyright (c) 2014 by Gideon Knocke.
# Copyright (c) 2016 Gideon Knocke, Timothe Litt
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
# Terms of the Perl programming language system itself
#
# a) the GNU General Public License as published by the Free
#   Software Foundation; either version 1, or (at your option) any
#   later version, or
# b) the "Artistic License"
#
# See LICENSE for details.
#
use strict;
use warnings;

use Test::More 0.94 tests => 19;

use File::Spec;
use Crypt::PKCS10;
use Crypt::PK::ECC;

ok( Crypt::PKCS10->setAPIversion(1), 'setAPIversion 1' );

my @dirpath = (File::Spec->splitpath( $0 ))[0,1];

my $file = File::Spec->catpath( @dirpath, 'csr4.pem' );

my $decoded;
if( open( my $csr, '<', $file ) ) {
    $decoded = Crypt::PKCS10->new( $csr, escapeStrings => 1 );
} else {
    BAIL_OUT( "$file: $!\n" );;
}

isnt( $decoded, undef, 'load PEM from file handle' ) or BAIL_OUT( Crypt::PKCS10->error );

is( scalar $decoded->subject, '/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd', 'subject' );

is( $decoded->commonName, "", 'CSR commonName' );

is( $decoded->subjectPublicKey, '048d0507a7ebf58a17910fe2b15b0c451e93bc948a4bafb7bf1204d6043e7de1394230befab9c5115cd3cd1e059a545788bb1e0830ee06300c4f3e8d87128f3ddc', 'hex subjectPublicKey' );

is( $decoded->subjectPublicKey(1), << '_KEYPEM_', 'PEM subjectPublicKey' );
-----BEGIN PUBLIC KEY-----
MFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABI0FB6fr9YoXkQ/isVsMRR6TvJSKS6+3vxIE1gQ+
feE5QjC++rnFEVzTzR4FmlRXiLseCDDuBjAMTz6NhxKPPdw=
-----END PUBLIC KEY-----
_KEYPEM_

is( $decoded->signature, '30440220730d25ebe5f187c607577cc106d3141dc7f90827914f2a6a11ebc9de6fdf1d26022042c02e4819f2c16c56181205c6c2176902f20cbfcfdc1fa82b30f79bd15d2172',
    'signature' );

is( scalar $decoded->subject, '/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd',
    'subject()' );

is( $decoded->pkAlgorithm, 'ecPublicKey', 'encryption algorithm' );

is_deeply( $decoded->subjectPublicKeyParams,
           {keytype => 'ECC',
            keylen => 256,
            curve => 'brainpoolP256r1',
            'pub_x' => '8D0507A7EBF58A17910FE2B15B0C451E93BC948A4BAFB7BF1204D6043E7DE139',
            'pub_y' => '4230BEFAB9C5115CD3CD1E059A545788BB1E0830EE06300C4F3E8D87128F3DDC',
           }, 'subjectPublicKeyParams(EC brainpool)' );

is( $decoded->signatureAlgorithm, 'ecdsa-with-SHA256', 'signature algorithm' );

my $sig = $decoded->signature( 2 );
ok( defined $sig &&
    substr( $sig->{r}->as_hex, 2 ) eq '730d25ebe5f187c607577cc106d3141dc7f90827914f2a6a11ebc9de6fdf1d26' &&
    substr( $sig->{s}->as_hex, 2 ) eq '42c02e4819f2c16c56181205c6c2176902f20cbfcfdc1fa82b30f79bd15d2172',
    'ECDSA signature components' );


my $key = $decoded->subjectPublicKey(1);

isnt( $key = Crypt::PK::ECC->new( \$key ), undef, 'parse EC key' );
is_deeply( $key->key2hash, {
   'curve_A' => '7D5A0975FC2C3057EEF67530417AFFE7FB8055C126DC5C6CE94A4B44F330B5D9',
   'curve_B' => '26DC5C6CE94A4B44F330B5D9BBD77CBF958416295CF7E1CE6BCCDC18FF8C07B6',
   'curve_Gx' => '8BD2AEB9CB7E57CB2C4B482FFC81B7AFB9DE27E1E3BD23C23A4453BD9ACE3262',
   'curve_Gy' => '547EF835C3DAC4FD97F8461A14611DC9C27745132DED8E545C1D54C72F046997',
   'curve_bits' => 256,
   'curve_bytes' => 32,
   'curve_cofactor' => 1,
   'curve_name' => 'brainpoolp256r1',
   'curve_oid' => '1.3.36.3.3.2.8.1.1.7',
   'curve_order' => 'A9FB57DBA1EEA9BC3E660A909D838D718C397AA3B561A6F7901E0E82974856A7',
   'curve_prime' => 'A9FB57DBA1EEA9BC3E660A909D838D726E3BF623D52620282013481D1F6E5377',
   'k' => '',
   'pub_x' => '8D0507A7EBF58A17910FE2B15B0C451E93BC948A4BAFB7BF1204D6043E7DE139',
   'pub_y' => '4230BEFAB9C5115CD3CD1E059A545788BB1E0830EE06300C4F3E8D87128F3DDC',
   'size' => 32,
   'type' => 0,
                           }, 'extract EC parameters' );

ok( $key->verify_message($decoded->signature(1), $decoded->certificationRequest, 'SHA256'), 'verify CSR signature' );


$file = File::Spec->catpath( @dirpath, 'csr6.pem' );

if( open( my $csr, '<', $file ) ) {
    $decoded = Crypt::PKCS10->new( $csr, escapeStrings => 1 );
} else {
    BAIL_OUT( "$file: $!\n" );;
}

isnt( $decoded, undef, 'load PEM from file handle' ) or BAIL_OUT( Crypt::PKCS10->error );

is( $decoded->pkAlgorithm, 'ecPublicKey', 'encryption algorithm' );

is_deeply( $decoded->subjectPublicKeyParams,
           {keytype => 'ECC',
            keylen => 384,
            curve => 'secp384r1',
            'pub_x' => '43FCD15809728171AECA3029A002C13424E92F5D39C3FB7074B5B4B8802FA3E9AB79E1F6CC174596AA09C6BEA9DFAAFF',
            'pub_y' => '1891F7048842DF14F3FDCABB81C40BDDBFDA64A20FCEA13136DF8109AB56D205F857A295ED00C6B7FAFB6240D66447EB',
           }, 'subjectPublicKeyParams(EC secp)' );

is( $decoded->signatureAlgorithm, 'ecdsa-with-SHA384', 'signature algorithm' );
