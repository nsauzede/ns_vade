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

#include <stdio.h>

#include "foo/foo.h"
#include "testing/testing.h"

class A {
public:
	A() {
		printf("Hello C++\n");
	}
	A(int a) {
		printf("Hello C++ - a=%d\n", a);
	}
};

void TestFooCPP(Test* t) {
	A a2(2);
	printf("%s: t=%p\n", __func__, (void *)t);
	A a;
}
