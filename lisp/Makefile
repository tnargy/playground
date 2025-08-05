CC = cc
CFLAGS = -std=c99 -Wall -g -ledit
OBJ = lispy.o

.PHONY: clean all

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

lispy: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f $(OBJ) lispy