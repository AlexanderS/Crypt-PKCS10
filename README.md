# NAME

Crypt::PKCS10 - parse PKCS #10 certificate requests

# VERSION

version 1.601

# SYNOPSIS

    use Crypt::PKCS10;

    Crypt::PKCS10->setAPIversion( 1 );
    my $decoded = Crypt::PKCS10->new( $csr ) or die Crypt::PKCS10->error;

    print $decoded;

    @names = $decoded->extensionValue('subjectAltName' );
    @names = $decoded->subject unless( @names );

    %extensions = map { $_ => $decoded->extensionValue( $_ ) } $decoded->extensions

# DESCRIPTION

`Crypt::PKCS10` parses PKCS #10 certificate requests (CSRs) and provides accessor methods to extract the data in usable form.

Common object identifiers will be translated to their corresponding names.
Additionally, accessor methods allow extraction of single data fields.
The format of returned data varies by accessor.

The access methods return the value corresponding to their name.  If called in scalar context, they return the first value (or an empty string).  If called in array context, they return all values.

    This file is automatically generated by pod2readme from PKCS10.pm and Changes.

# NAME

Crypt::PKCS10 - parse PKCS #10 certificate requests

# RELEASE NOTES

Version 1.4 made several API changes.  Most users should have a painless migration.

ALL users must call Crypt::PKCS10->setAPIversion.  If not, a warning will be generated
by the first class method called.  This warning will be made a fatal exception in a
future release.

Other than that requirement, the legacy mode is compatible with previous versions.

`new` will no longer generate exceptions.  `undef` is returned on all errors. Use
the error class method to retrieve the reason.

new will accept an open file handle in addition to a request.

Users are encouraged to migrate to the version 1 API.  It is much easier to use,
and does not require the application to navigate internal data structures.

Version 1.7 provides support for DSA and ECC public keys.  It also allows the
caller to verify the signature of a CSR.

# INSTALLATION

To install this module type the following:

    perl Makefile.PL
    make
    make test
    make install

# REQUIRES

`Convert::ASN1`

For ECC: `Crypt::PK::ECC`

Tests also require `Crypt::OpenSSL::DSA, Crypt::OpenSSL::RSA, Crypt::PK::ECC, Digest::SHA`.
Note that these are useful for signature verification; see the tests for code.

# METHODS

Access methods may exist for subject name components that are not listed here.  To test for these, use code of the form:

    $locality = $decoded->localityName if( $decoded->can('localityName') );

If a name component exists in a CSR, the method will be present.  The converse is not (always) true.

## class method setAPIversion( $version )

Selects the API version (0 or 1) expected.

Must be called before calling any other method.

- Version 0 - **DEPRECATED**

    Some OID names have spaces and descriptions

    This is the format used for `Crypt::PKCS10` version 1.3 and lower.  The attributes method returns legacy data.

- Version 1

    OID names from RFCs - or at least compatible with OpenSSL and ASN.1 notation.  The attributes method conforms to version 1.

If not called, a warning will be generated and the API will default to version 0.

In a future release, the warning will be changed to a fatal exception.

To ease migration, both old and new names are accepted by the API.

Every program should call `setAPIversion(1)`.

## class method new( $csr, %options )

Constructor, creates a new object containing the parsed PKCS #10 certificate request.

`$csr` may be a scalar containing the request, or a file handle from which to read it.

If a file handle is supplied, the caller should specify `acceptPEM => 0` if the contents are DER.

The request may be PEM or binary DER encoded.  Only one request is processed.

If PEM, other data (such as mail headers) may precede or follow the CSR.

    my $decoded = Crypt::PKCS10->new( $csr ) or die Crypt::PKCS10->error;

Returns `undef` if there is an I/O error or the request can not be parsed successfully.

Call `error()` to obtain more detail.

### options

- acceptPEM

    If **false**, the input must be in DER format.  `binmode` will be called on a file handle.

    If **true**, the input is checked for a PEM certificate request.  If not found, the csr
    is assumed to be in DER format.

    Default is **true**.

- escapeStrings

    If **true**, strings returned for extension and attribute values are '\\'-escaped when formatted.
    This is compatible with OpenSSL configuration files.

    The special characters are: '\\', '$', and '"'

    If **false**, these strings are not '\\'-escaped.  This is useful when they are being displayed
    to a human.

    The default is **true**.

No exceptions are generated.

The object will stringify to a human-readable representation of the CSR.  This is
useful for debugging and perhaps for displaying a request.  However, the format
is not part of the API and may change.  It should not be parsed by automated tools.

Exception: The public key and extracted request are PEM blocks, which other tools
can extract.

## class method error

Returns a string describing the last error encountered;

## class method name2oid( $oid )

Returns the OID corresponding to a name returned by an access method.

Not in API v0;

## csrRequest( $format )

Returns the binary (ASN.1) request (after conversion from PEM and removal of any data beyond the length of the ASN.1 structure.

If $format is **true**, the request is returned as a PEM CSR.  Otherwise as a binary string.

## certificationRequest

Returns the binary (ASN.1) section of the request that is signed by the requestor.

The caller can verify the signature using **signatureAlgorithm**, **certificationRequest** and **signature(1)**.

## Access methods for the subject's distinguished name

Note that **subjectAltName** is prefered, and that modern certificate users will ignore the subject if **subjectAltName** is present.

### subject( $format )

Returns the entire subject of the CSR.

In scalar context, returns the subject as a string in the form `/componentName=value,value`.
  If format is **true**, long component names are used.  By default, abbreviations are used when they exist.

    e.g. /countryName=AU/organizationalUnitName=Big org/organizationalUnitName=Smaller org
    or     /C=AU/OU=Big org/OU=Smaller org

In array context, returns an array of `(componentName, [values])` pairs.  Abbreviations are not used.

Note that the order of components in a name is significant.

### commonName

Returns the common name(s) from the subject.

    my $cn = $decoded->commonName();

### organizationalUnitName

Returns the organizational unit name(s) from the subject

### organizationName

Returns the organization name(s) from the subject.

### emailAddress

Returns the email address from the subject.

### stateOrProvinceName

Returns the state or province name(s) from the subject.

### countryName

Returns the country name(s) from the subject.

## subjectAltName( $type )

Convenience method.

When $type is specified: returns the subject alternate name values of the specified type in list context, or the first value
of the specified type in scalar context.

Returns undefined/empty list if no values of the specified type are present, or if the **subjectAltName**
extension is not present.

Types can be any of:

      otherName
    * rfc822Name
    * dNSName
      x400Address
      directoryName
      ediPartyName
    * uniformResourceIdentifier
    * iPAddress
    * registeredID

The types marked with '\*' are the most common.

If `$type` is not specified:
 In list context returns the types present in the subjectAlternate name.
 In scalar context, returns the SAN as a string.

## version

Returns the structure version as a string, e.g. "v1" "v2", or "v3"

## pkAlgorithm

Returns the public key algorithm according to its object identifier.

## subjectPublicKey( $format )

If `$format` is **true**, the public key will be returned in PEM format.

Otherwise, the public key will be returned in its hexadecimal representation

## subjectPublicKeyParams

Returns a hash describing the public key.  The contents may vary depending on
the public key type.

`keytype` - ECC, RSA, DSA

`keylen` - Approximate length of the key in bits.

## signatureAlgorithm

Returns the signature algorithm according to its object identifier.

## signatureParams

Returns the parameters associated with the **signatureAlgorithm** as binary.
Returns **undef** if none, or if **NULL**.

Note: In the future, some **signatureAlgorithm**s may return a hashref of decoded fields.

Callers are advised to check for a ref before decoding...

## signature( $format )

The CSR's signature is returned.

If `$format` is **1**, in binary.

If `$format` is **2**, decoded as an ECDSA signature - returns hashref to `r` and `s`.

Otherwise, in its hexadecimal representation.

## attributes( $name )

A request may contain a set of attributes. The attributes are OIDs with values.
The most common is a list of requested extensions, but other OIDs can also
occur.  Of those, **challengePassword** is typical.

For API version 0, this method returns a hash consisting of all
attributes in an internal format.  This usage is **deprecated**.

For API version 1:

If $name is not specified, a list of attribute names is returned.  The list does not
include the requestedExtensions attribute.  For that, use extensions();

If no attributes are present, the empty list (`undef` in scalar context) is returned.

If $name is specified, the value of the extension is returned.  $name can be specified
as a numeric OID.

In scalar context, a single string is returned, which may include lists and labels.

    cspName="Microsoft Strong Cryptographic Provider",keySpec=2,signature=("",0)

Special characters are escaped as described in options.

In array context, the value(s) are returned as a list of items, which may be references.

    print( " $_: ", scalar $decoded->attributes($_), "\n" )
                                      foreach ($decoded->attributes);

See the module documentation for a list of known OID names.

It is too long to include here.

## extensions

Returns an array containing the names of all extensions present in the CSR.  If no extensions are present,
the empty list is returned.

The names vary depending on the API version; however, the returned names are acceptable to `extensionValue`, `extensionPresent`, and `name2oid`.

The values of extensions vary, however the following code fragment will dump most extensions and their value(s).

    print( "$_: ", $decoded->extensionValue($_,1), "\n" ) foreach ($decoded->extensions);

The sample code fragment is not guaranteed to handle all cases.
Production code needs to select the extensions that it understands and should respect
the **critical** boolean.  **critical** can be obtained with extensionPresent.

## extensionValue( $name, $format )

Returns the value of an extension by name, e.g. `extensionValue( 'keyUsage' )`.
The name SHOULD be an API v1 name, but API v0 names are accepted for compatibility.
The name can also be specified as a numeric OID.

If `$format` is 1, the value is a formatted string, which may include lists and labels.
Special characters are escaped as described in options;

If `$format` is 0 or not defined, a string, or an array reference may be returned.
The array many contain any Perl variable type.

To interpret the value(s), you need to know the structure of the OID.

See the module documentation for a list of known OID names.

It is too long to include here.

## extensionPresent( $name )

Returns **true** if a named extension is present:
    If the extension is **critical**, returns 2.
    Otherwise, returns 1, indicating **not critical**, but present.

If the extension is not present, returns `undef`.

The name can also be specified as a numeric OID.

See the module documentation for a list of known OID names.

It is too long to include here.

## registerOID( )

Class method.

Register a custom OID, or a public OID that has not been added to Crypt::PKCS10 yet.

The OID may be an extension identifier or an RDN component.

The oid is specified as a string in numeric form, e.g. `'1.2.3.4'`

### registerOID( $oid )

Returns **true** if the specified OID is registered, **false** otherwise.

### registerOID( $oid, $longname, $shortname )

Registers the specified OID with the associated long name.  This
enables the OID to be translated to a name in output.

The long name should be Hungarian case (**commonName**), but this is not currently
enforced.

Optionally, specify the short name used for extracting the subject.
The short name should be upper-case (and will be upcased).

E.g. built-in are `$oid => '2.4.5.3', $longname => 'commonName', $shortname => 'CN'`

To register a shortname for an existing OID without one, specify `$longname` as `undef`.

E.g. To register /E for emailAddress, use:
  `Crypt::PKCS10->registerOID( '1.2.840.113549.1.9.1', undef, 'e' )`

Generates an exception if any argument is not valid, or is in use.

Returns **true** otherwise.

## certificateTemplate

`CertificateTemplate` returns the **certificateTemplate** attribute.

Equivalent to `extensionValue( 'certificateTemplate' )`, which is prefered.

# CHANGES

    1.0 2014-08-20

    

     - Initial Version

    

    1.1 2015-10-09

    

     - Allow same OID elements in RDNs

     - Support for all DirectoryStrings

     - New accessor method: organizationName 

    

    1.2 2015-11-13

    

     - Add generic method extensionValue

     - Ommit unknown or damaged extensions

    

    1.3 2015-11-17

    

     - Experimental Perl features removed

     - Refactored building process

    

    1.4_01 2016-01-14

    

    - Find PEM anywhere

    - Support repeated attributes

    - Various crashes, internal optimizations

    - More OIDs

    - Access methods: subject, subjectAltName, extensions

    - Generate access methods for unknown OIDs in DNs at runtime

    - Add extractCSR method to get CSR in binary or PEM

    - subjectPublicKey option to extract in PEM format

    - Convert IP addresses to strings

    - Convert basicConstraints to string

    - Add registerOID to allow extraction of simple custom OIDs

    - More tests

    - Improve documentation

    - Add setAPIversion, regularize OID names in V1

    - For API V1, attributes method returns names or values of attributes (except extensions)

    - Improve build: Use Dist::Zilla, autogenerate README,LICENE,META,Makefile.PL

    - Generate & ship Commitlog from git

    

    1.4_02

    

    - For API V1, omit space in key usage list

    - Look for policy identifier names in all tables

    - Decode certificatePolicyIdentifier, add related OIDs

    - Avoid building un-necessary ASN.1 parsers

    - Fully decode ApplicationCertPolicies for API V1

    - Check enhanced key usage before registering OID

    - Add name2oid to API

    - Internal cleanup  & error reporting improvements

    

    1.4_03

    

    - certificateTemplate ASN correction: MajorVersion is optional

    - certificateTemplate returns id as a name if OID registered (API V1)

    - handle some malformed requests better

    - decode more M$ attributes, correct some.

    - Don't croak() on missing attributes

    - Convert BMPStrings from UCS2 to Perl (printable) strings

    - Rework special OID handling to be scalable & cover attributes

    - Don't croak in new.  (API V1) Always return undef.  Class method error() returns detail.

    - Return reasonable strings from attributes('name') and extensionValue('name',1)

    - Overload object so print can produce a useful dump.

    - Handle null subject

    - More enhanced key usage OIDs

    - keyUsage returns array rather than comma separated string (API v1)

    - Cleaned up POD

    - Do a better job with error reporting

    - Validate PEM's Base64 encoding.

    - Ensure that only the first PEM certificate is extracted.

    - Improve tests

    - Enable (internal) custom formatters for extensions and attributes.

    - Return basicConstraints as a hash

    - Accept numeric OIDs as arguments to extensionValue, extensionPresent and attributes.

    

    1.4_04

     - Build Kwalitee issues: Minimum Perl version, Repo location, and Provides in META

     - Fix test issues due to hash randomization on newer Perl versions.

    

    1.4_05

     - Sign distribution kits

     - Remove execute permissions from text files

     - Generate Markdown format README for github

     - Use Pod::Weaver to manage authorship, copyright from dist.ini

     - Add prerequisites display test

     - Validate with perlcritic, pod syntax

    

    1.5

     - Uncoordinated release of 1.4_04

    

    1.6

     - Support some EC OIDs

    

    1.6_01

     - ECC test doesn't require Data::Dumper

     - Support more EC OIDs

     - Add DSA OIDs

     - Add subjectPublicKeyParams(), which provides some description of the key

     - Add certificationRequest and signature(1) to enable verification of CSR signatures

     - Add signatureParams()

     - Add signature(2) to extract ECDSA signature components.

     - Fix and extend registerOID, add tests.

    

For a more detailed list of changes, see `Commitlog` in the distribution.

# EXAMPLES

In addition to the code snippets contained in this document, the `t/` directory of the distribution
contains a number of tests that exercise the API.  Although artificial, they are a good source of
examples.

Note that the type of data returned when extracting attributes and extensions is dependent
on the specific OID used.

Also note that some functions not listed in this document are tested.  The fact that they are
tested does not imply that they are stable, or that they will be present in any future release.

The test data was selected to exercise the API; the CSR contents are not representative of
realistic certificate requests.

# ACKNOWLEDGEMENTS

Martin Bartosch contributed preliminary EC support:  OIDs and tests.

Timothe Litt made most of the changes for V1.4+

`Crypt::PKCS10` is based on the generic ASN.1 module by Graham Barr and on the
 x509decode example by Norbert Klasen. It is also based upon the
works of Duncan Segrest's `Crypt-X509-CRL` module.

# AUTHORS

- Gideon Knocke &lt;gknocke@cpan.org>
- Timothe Litt &lt;tlhackque@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014, 2016 by Gideon Knocke, Timothe Litt.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# BUG REPORTS

Please report any bugs or feature requests on the bugtracker website
https://rt.cpan.org/Public/Dist/Display.html?Name=Crypt-PKCS10 or by email
to bug-crypt-pkcs10@rt.cpan.org.

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.
