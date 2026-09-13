CC ?= cc
CFLAGS += -Wall -Wextra -O2 $(shell pkg-config --cflags gtk+-3.0 webkit2gtk-4.0)
LDLIBS += $(shell pkg-config --libs gtk+-3.0 webkit2gtk-4.0)

TARGET = idiomind-utils
SOURCES = idiomind-utils.c html_view.c
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDLIBS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJECTS)
