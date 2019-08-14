##
# This file is part of the chicon project.
#
# @copyright © dana <https://github.com/okdana>
# @license   MIT

all:   chicon
build: chicon

chicon:
	xcrun -sdk macosx swiftc Sources/*.swift -o chicon

package: chicon
	zip chicon.zip chicon

install: chicon
	cp chicon /usr/local/bin/

uninstall:
	rm -f /usr/local/bin/chicon

clean:
	rm -f  *.o chicon chicon.tar chicon.tgz chicon.zip
	rm -rf *.dSYM/

help:
	@echo 'Available targets:'
	@echo '  all ......... Same as `chicon`'
	@echo '  build ....... Same as `chicon`'
	@echo '  chicon ...... Compile `chicon`'
	@echo '  package ..... Compile `chicon` and archive to chicon.zip'
	@echo '  install ..... Compile `chicon` and install to /usr/local/bin'
	@echo '  uninstall ... Remove `chicon` from /usr/local/bin'
	@echo '  clean ....... Remove build files'
	@echo '  help ........ Display this usage help'

.PHONY: all build package install uninstall clean help
