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

#define _POSIX_C_SOURCE 199309L
#include <time.h>
#include <unistd.h>
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

void testing_Fail(void *opaque) {
    Test *t = opaque;
    *t = *t + 1;
//    printf("%s: t=%d\n", __func__, *t);
}

void testing_Logf(void *opaque, const char *fmt, ...) {
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
	printf("[==========] Running tests from test suite.\n");
//	printf("[----------] testing_syms=[%s].\n", testing_syms);
	printf("[----------] Global test environment set-up.\n");
	struct timespec ts0, ts1;
	clock_gettime(CLOCK_MONOTONIC, &ts0);
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
				Test t;
//				printf("[----------] 2 tests from %s\n", buf);
				printf("[ RUN      ] %s\n", buf);
				struct timespec tsa, tsb;
				clock_gettime(CLOCK_MONOTONIC, &tsa);
				testfunction tf = (testfunction)sym;
//				struct timespec sl = {0, 3500000};
//				nanosleep(&sl, 0);
				clock_gettime(CLOCK_MONOTONIC, &tsb);
				long ns = 1000000000 * (tsb.tv_sec - tsa.tv_sec) + tsb.tv_nsec - tsa.tv_nsec;
				long ms = ns / 1000000;
				tf(&t);
				if (t > 0)
					printf("[  FAILED  ] %s (%ld ms)\n", buf, ms);
				else
					printf("[       OK ] %s (%ld ms)\n", buf, ms);
			} else {
				printf("error: %s\n", dlerror());
			}
		}
		token = tokend;
	}
	clock_gettime(CLOCK_MONOTONIC, &ts1);
	long ns = 1000000000 * (ts1.tv_sec - ts0.tv_sec) + ts1.tv_nsec - ts0.tv_nsec;
	long ms = ns / 1000000;
	printf("[----------] Global test environment tear-down\n");
	printf("[==========] 2 tests from 1 test suite ran. (%ld ms total)\n", ms);
	printf("[  PASSED  ] 2 tests.\n");
	dlclose(handle);
	return 0;
}
