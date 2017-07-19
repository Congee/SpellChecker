CC=cc
LD=cc
RELEASE= -DNDEBUG -O2
CFLAGS= $(RELEASE) -c -Wall -fPIC -DMAJOR_VERSION=0 -DMINOR_VERSION=1 `python3-config --cflags`
LDFLAGS= -shared `python3-config --ldflags` -framework AppKit

all:
	$(CC) $(CFLAGS) -o spellcheck.{o,m}
	$(LD) $(LDFLAGS) -o spellcheck.{so,o}

clean:
	rm -rf spellcheck *.o *.so *.dSYM
