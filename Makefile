target   := nanoarch
sources  := nanoarch.c
CFLAGS   := -Wall -O2 -g
LFLAGS   := -static-libgcc
LIBS     := -ldl

# Straight up lifted from bsnes-libretro makefile
ifeq ($(platform),)
platform = unix
ifeq ($(shell uname -s),)
	platform = win
else ifneq ($(findstring MINGW,$(shell uname -s)),)
	platform = win
else ifneq ($(findstring Darwin,$(shell uname -s)),)
	platform = osx
else ifneq ($(findstring win,$(shell uname -s)),)
	platform = win
endif
endif

packages := glew glfw3
ifeq ($(platform),unix)
	packages += alsa gl
	CFLAGS += -DALSA=1
else ifeq ($(platform),win)
	LIBS += -lopengl32
endif

# do not edit from here onwards
objects := $(addprefix build/,$(sources:.c=.o))
ifneq ($(packages),)
    LIBS    += $(shell pkg-config --libs-only-l $(packages))
    LFLAGS  += $(shell pkg-config --libs-only-L --libs-only-other $(packages))
    CFLAGS  += $(shell pkg-config --cflags $(packages))
endif

.PHONY: all clean

all: $(target)
clean:
	-rm -rf build
	-rm -f $(target)

$(target): Makefile $(objects)
	$(CC) $(LFLAGS) -o $@ $(objects) $(LIBS)

build/%.o: %.c Makefile
	-mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -MMD -o $@ $<

-include $(addprefix build/,$(sources:.c=.d))

