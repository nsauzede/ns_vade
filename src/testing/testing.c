/*
    Vade - Go Methodology for C/C++ using GNU Make
    Copyright (C) 2017  Nicolas Sauzede <nsauzede@laposte.net>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <stdarg.h>

#include "testing.h"

typedef int Test;
typedef void (*testfunction)(Test* t);

static char testing_syms[] = ""
#ifndef TESTING_SYMS
#error You must #define TESTING_SYMS as a list of test symbols (eg: "TestFoo", "TestBar", ...)
#else
	TESTING_SYMS
#endif
;

void testing_Logf(const void *opaque, const char *fmt, ...) {
	if (opaque) {
		printf("%s: opaque=%p fmt=%s\n", __func__, opaque, fmt);
	}
	va_list ap;
	va_start(ap, fmt);
	vprintf(fmt, ap);
	va_end(ap);
}

int main(int argc, char *argv[]) {
	int arg = 1;
	if (arg < argc) {
		if (strcmp(argv[arg], "--version")) {
			printf("test version 0.0\n");
			exit(0);
		}
	}
	void *handle = dlopen(0, RTLD_NOW | RTLD_GLOBAL);
	char *token = testing_syms;
	while (*token) {
		char *tokend = strchr(token, ' ');
		if (tokend) {
			*tokend++ = 0;
		} else {
			tokend = token + strlen(token);
		}
		const char *buf = token;
		if (buf[0]) {
			void *sym = dlsym(handle, buf);
			if (sym) {
				testfunction tf = (testfunction)sym;
				tf(0);
			} else {
				printf("error: %s\n", dlerror());
			}
		}
		token = tokend;
	}
	dlclose(handle);
	return 0;
}
