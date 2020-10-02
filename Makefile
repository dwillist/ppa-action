BINDIR := /usr/bin

all:
	go build -o go-hello

install:
	mkdir -p ${DESTDIR}${BINDIR}
	cp go-hello ${DESTDIR}${BINDIR}/

