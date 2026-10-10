#!/usr/bin/env perl
use strict;
use warnings;

binmode STDOUT;

for my $file (
    ["stand",      512],
    ["miniroot", 10240],
    ["rootdump", 10240],
    ["srcsys.tar",10240],
    ["usr.tar",   10240],
    ["vfont.tar", 10240],
    ["src.tar",   10240],
    ["new.tar",   10240],
    ["ingres.tar",10240]
) {
    my ($name, $blocksize) = @$file;
    open(my $fh, "<:raw", $name) or die "$name: $!";
    while (1) {
        my $bytes = read($fh, my $block, $blocksize);
        die "Read error: $!" unless defined $bytes;
        last if $bytes == 0;
        $block .= "\0" x ($blocksize - $bytes);
        print pack("V", $blocksize), $block, pack("V", $blocksize);
    }
    close($fh);
    print pack("V", 0);
}
print pack("V", 0);
