#!/usr/bin/env perl

print <<__END__;
.syntax unified
.arm
__END__

while (<>) {
  if (/file format binary/ or /Disassembly of section/ or /^000000/) {

  } elsif (my ($pos, $word, $asm) = /^ *([\da-f]+):\s+([\da-f]{8})\s+(.*)$/){
    my $p = hex($pos);
    my $bytes = reverse (pack "H*", $word);
    if ($bytes =~ /[a-zA-Z\d_ :+\r\n\0=%\.>()-]{4}/ and $bytes ne "xG\0\0") {
      $bytes =~ s/\0/\\0/g;
      $bytes =~ s/\r/\\r/g;
      $bytes =~ s/\n/\\n/g;
      printf "x%04s: .ascii \"%s\"\n",$pos,$bytes;
    } elsif ($p >= 0xf98 and $p < 0xfe0 or $p >= 0xff0 ) {
      printf "x%04s: .word 0x%s\n",$pos,$word
    } elsif ($asm =~ /^(b|bcc|bcs|beq|blx)\s+0x([\da-f]{1,3})$/) {
      printf "x%04s: $1 x%04s\n",$pos,$2
    } elsif ($asm =~ /^ldr\s+(\w+), \[pc(?:, #-?\d+)?\]\s; 0x([\da-f]+)/) {
      printf "x%04s: ldr $1, x%04s\n",$pos,$2
    } elsif ($asm =~ /^(and|cmp|mov|bx|push|pop|ldr|svc).*/) {
      $asm =~ s/;/@/;
      printf "x%04s: %s\n",$pos,$asm
    } else {
      printf "x%04s: .word 0x%s @ %s\n",$pos,$word,$asm
    }
  } else {
    print
  }
}
