#!/usr/bin/env perl
use Provision::DSL;

User 'sites';
User sites => ( ... );
User sites => { ... };

Perlbrew sites => (
    install_cpanm => 1,
    install_perl  => '5.14.2',
    switch_perl  => '5.14.2',
);

