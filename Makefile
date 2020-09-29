BINDIR := /usr/bin

all:
	go build -o go-hello

install:
	mkdir -p ${DESTDIR}${BINDIR}
	cp my_hello_world ${DESTDIR}${BINDIR}/

