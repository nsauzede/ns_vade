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

#ifndef TESTING_H__
#define TESTING_H__

/* In order to use lightwheight testing framework, for example to test the package 'foo/foo.c'
you must create a separate file 'foo/foo_test.c' that includes both 'foo/foo.h' and 'testing/testing.h'

testing/testing is provided in vade install tree

The usage is simple :
Create test APIs, like :
void foo_TestFoo(void *opaque);

where opaque is a testing private pointer, that must be passed to testing APIs.

*/

// testing APIs include :

#ifdef __cplusplus
extern "C" {
#endif
void testing_Logf(void *opaque, const char *fmt, ...);		// printf-like API to output error message format

void testing_Errorf(void *opaque, const char *fmt, ...);	// printf-like API to output error message format and indicate test failure
void testing_Fail(void *opaque);			// indicate a test failure
// else test pass

//typedef int Test;
#ifdef __cplusplus
}
#endif

#endif/*TESTING_H__*/
