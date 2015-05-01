# My Home Binaries #

just a silly collection of binaries, I like to share among different machines. All of these binaries reside in my $HOME/bin directory which is part of my search path.

These binaries include:

 * `make_pod.sh` creates .pdf Files from a series of .pm/.pod files
 * `update_minicpan.sh` updates my minicpan mirror
 * `check_ssl.sh` checks available ciphers for a given ssl server
 * `install_cpan_modules.sh` installs a collection of useful modules

The misc_apps directory contains some apps that may get installed
independently. `dzil install` is your friend :-)


more things will get added from time to time.

TODO: find a way to add these lines to "/opt/local/etc/macports/variants.conf"
    +no_x11
    -x11
    +quartz


Homebrew install

https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Installation.md#installation
$ mkdir homebrew && curl -L https://github.com/Homebrew/homebrew/tarball/master | tar xz --strip 1 -C homebrew


Install aspnet

https://github.com/aspnet/home#os-x

brew tap aspnet/dnx
brew update
brew install dnvm

dnvm upgrade


.NET Projekte erzeugen

$ yo aspnet


Pakete restaurieren, bauen, starten:

$ dnu restore
$ dnu build
$ dnx . run for console projects
$ dnx . kestrel or dnx . web for web projects
