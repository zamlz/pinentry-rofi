VERSION = 1.0
GIT_COMMIT=$(shell test -d .git && git describe --always 2>/dev/null)

ifneq "$(GIT_COMMIT)" ""
	VERSION=$(GIT_COMMIT)
endif

SRCS = src/pinentry-rofi.sh
EXEC = pinentry-rofi

PREFIX?=/usr
BINDIR=${PREFIX}/bin

install: ${SRCS}
	install -D -m 755 ${SRCS} ${DESTDIR}${BINDIR}/${EXEC}

uninstall:
	rm -f ${DESTDIR}${BINDIR}/${EXEC}

.PHONY: install uninstall
