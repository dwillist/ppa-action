BINDIR := /usr/bin

all:
	go build main.go

install:
	mkdir -p ${DESTDIR}${BINDIR}
	cp my_hello_world ${DESTDIR}${BINDIR}/

