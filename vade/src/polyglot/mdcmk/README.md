//\\Polyglot: \#MD, #C and #Makefile<!--
#if 0
	@
\#MD,: all
ifdef 0
#endif/* -->
====================
Wait, what?
-----------
Well, a polyglot file with simultaneous MarkDown, C and Makefile contents.

How to test
-----------
```shell
$ make -f README.md
Hello MD from Makefile
cc -o README.md.out -x c README.md && ./README.md.out
Hello MD from C
```

Show me the code
----------------
<!--
*///\
-->//\
```c
#include <stdio.h>

int main() {
    printf("Hello MD from C\n");
    return 0;
}
//\
```
//\
<!--
#if 0
-->
Show me the Makefile
--------------------
<!--
endif #\
--> #\
```makefile
IN:=$(MAKEFILE_LIST)
OUT:=$(IN).out
all:
	@echo "Hello MD from Makefile"
	$(CC) -o $(OUT) -x c $(IN) && ./$(OUT)
clean:
	$(RM) $(OUT)
#\
```
#\
<!--
ifdef 0
endif
#endif