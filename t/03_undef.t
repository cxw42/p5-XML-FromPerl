#!perl

use strict;
use XML::LibXML;
use XML::FromPerl qw(xml_from_perl xml_node_from_perl);
use Test::More;
use Test::Warn;
use Tie::IxHash;
use warnings;   # After the `use XML::FromPerl`
                # per https://rt.perl.org/Public/Bug/Display.html?id=128765

# === Test handling of `undef` values ======================================

my $doc = xml_from_perl
    [ Foo =>
        [ Bar =>
            undef,
            'Baz',
            undef,
            'Quux',
        ]
    ];

like $doc->toString, qr{<Foo><Bar>BazQuux</Bar></Foo>},
    'undef element is skipped';
    # like(), not is(), because there's also an XML processing instruction.

$doc = xml_from_perl undef;
ok $doc, 'undef in -> document out';
ok !defined $doc->documentElement, 'undef in -> no documentElement out';

$doc = XML::LibXML::Document->new;
my $el = xml_node_from_perl($doc, undef);
ok !defined $el, 'No data -> undefined node';

# === Test warnings for `undef` values =====================================

#my $saved_warning_bits = ${^WARNING_BITS};

warning_like { xml_from_perl undef } qr/document.*undefined/,
    'xml_from_perl(undef) warns by default when warnings are enabled';

eval {
    no warnings 'XML::FromPerl::undefined';
    #isnt ${^WARNING_BITS}, $saved_warning_bits, 'different warning bits at ' . __LINE__;
    warning_is { xml_from_perl undef } undef,
        'xml_from_perl respects XML::FromPerl::undefined warning category';
} if $] ge '5.014';

#is ${^WARNING_BITS}, $saved_warning_bits, 'same warning bits at ' . __LINE__;

eval {
    no warnings 'XML::FromPerl';
    #isnt ${^WARNING_BITS}, $saved_warning_bits, 'different warning bits at ' . __LINE__;
    warning_is { xml_from_perl undef } undef,
        'xml_from_perl respects XML::FromPerl warning category';
};

#is ${^WARNING_BITS}, $saved_warning_bits, 'same warning bits at ' . __LINE__;

$doc = XML::LibXML::Document->new;
warning_like { xml_node_from_perl $doc, undef } qr/node.*undefined/,
    'xml_node_from_perl(undef) warns by default when warnings are enabled';

#diag $saved_warning_bits;
eval {
    no warnings 'XML::FromPerl::undefined';
    #isnt ${^WARNING_BITS}, $saved_warning_bits, 'different warning bits at ' . __LINE__;
    warning_is { xml_node_from_perl $doc, undef } undef,
        'xml_node_from_perl respects XML::FromPerl::undefined warning category';
} if $] ge '5.014';

#is ${^WARNING_BITS}, $saved_warning_bits, 'same warning bits at ' . __LINE__;

eval {
    no warnings 'XML::FromPerl';
    #isnt ${^WARNING_BITS}, $saved_warning_bits, 'different warning bits at ' . __LINE__;
    warning_is { xml_node_from_perl $doc, undef } undef,
        'xml_node_from_perl respects XML::FromPerl warning category';
};

#is ${^WARNING_BITS}, $saved_warning_bits, 'same warning bits at ' . __LINE__;

done_testing;
