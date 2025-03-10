LIBTOOL=libtool
STATIC=-static
LIBFOO_A=../bin/libraylib_macos_pbhelper_x64.a
SRC=../pbhelper/*.c

OBJ=$(SRC:.c=.o)
LIBFOOCFLAGS=-mmacosx-version-min=10.1

TESTSRC=test.c
TESTCFLAGS=-mmacosx-version-min=10.7

$(LIBFOO_A): $(OBJ)
    $(LIBTOOL) $(STATIC) -o $@ $(OBJ)

%.o: %.c
    $(CC) $(LIBFOOCFLAGS) -c -o $@ $<

    
