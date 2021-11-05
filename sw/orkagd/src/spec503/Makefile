all: main.out

main.out: main.c
        #-std=gnu99
	echo "make 'mini.out'"
        # be sure to add path to source to get access to header file
	gcc -O2 -std=gnu99 -L../ -I../ -lorkagd -o $@ $< ../mmgmt.c

clean:
	-@rm -f *.o *.so *.a *.out 2>/dev/null >/dev/null

run:
	LD_LIBRARY_PATH=.. ./main.out
