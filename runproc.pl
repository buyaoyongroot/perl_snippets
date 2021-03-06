#!/usr/bin/perl -w
# loader - starts Perl scripts without the annoying DOS window
use strict;
use Win32;
use Win32::Process;

# Create the process object.

Win32::Process::Create($Win32::Process::Create::ProcessObj,
    'C:/perl5/bin/perl.exe',            # Whereabouts of Perl
    'perl realprogram',                 #
    0,                                  # Don't inherit.
    DETACHED_PROCESS,                   #
    ".") or                             # current dir.
die print_error();

sub print_error() {
    return Win32::FormatMessage( Win32::GetLastError() );
}

