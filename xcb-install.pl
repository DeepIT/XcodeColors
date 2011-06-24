#!/usr/bin/env perl

system("./install") if ($ENV{BUILD_STYLE} =~ /Release/);
