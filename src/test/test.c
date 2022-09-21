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

#include "test.h"

#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <stdarg.h>

typedef struct {
    int failures;
    int verbose;
} test_t;
typedef void (*testfunction)(test_t* t);

static char test_syms[] = ""
#ifndef TEST_SYMS
#error You must #define TEST_SYMS as a list of test symbols (eg: "TestFoo", "TestBar", ...)
#else
	TEST_SYMS
#endif
;

#define VADE_VERSION_ STRINGIFY_(VADE_VERSION)

void test_Fail(void *opaque) {
    test_t *t = opaque;
    t->failures++;
}

void test_Logf(void *opaque, const char *fmt, ...) {
    test_t *t = opaque;
    if (t->verbose) {
        va_list ap;
        va_start(ap, fmt);
        vprintf(fmt, ap);
        va_end(ap);
    }
}

int main(int argc, char *argv[]) {
    int arg = 1;
    int verbose = 0;
    if (arg < argc) {
        if (!strcmp(argv[arg], "--version")) {
            printf("test version %s\n", VADE_VERSION_);
            exit(0);
        }
        if (!strcmp(argv[arg], "-v")) {
            verbose = 1;
        }
    }
    void *handle = dlopen(0, RTLD_NOW | RTLD_GLOBAL);
    char *token = test_syms;
    printf("[==========] Running tests from test suite.\n");
    printf("[----------] Global test environment set-up.\n");
    struct timespec ts0, ts1;
    clock_gettime(CLOCK_MONOTONIC, &ts0);
    int ntests = 0;
    int failed = 0;
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
                test_t t = { .verbose = verbose };
                printf("[ RUN      ] %s\n", buf);
                struct timespec tsa, tsb;
                clock_gettime(CLOCK_MONOTONIC, &tsa);
                testfunction tf = (testfunction)sym;
                clock_gettime(CLOCK_MONOTONIC, &tsb);
                long ns = 1000000000 * (tsb.tv_sec - tsa.tv_sec) + tsb.tv_nsec - tsa.tv_nsec;
                long ms = ns / 1000000;
                tf(&t);
                int is_fail = t.failures > 0;
                if (is_fail) {
                    failed++;
                }
                printf("[ %s ] %s (%ld ms)\n", is_fail ? " FAILED " : "      OK", buf, ms);
            } else {
                printf("error: %s\n", dlerror());
            }
        }
        token = tokend;
        ntests++;
    }
    clock_gettime(CLOCK_MONOTONIC, &ts1);
    long ns = 1000000000 * (ts1.tv_sec - ts0.tv_sec) + ts1.tv_nsec - ts0.tv_nsec;
    long ms = ns / 1000000;
    printf("[----------] Global test environment tear-down\n");
    int passed = ntests - failed;
    printf("[==========] %d tests from test suite ran. (%ld ms total)\n", ntests, ms);
    if (passed)
        printf("[  PASSED  ] %d tests.\n", passed);
    if (failed)
        printf("[  FAILED  ] %d tests.\n", failed);
    dlclose(handle);
    return failed > 0;
}
