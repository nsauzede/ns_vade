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

#include "foo/foo.h"

#ifndef VADE_TEST_INCLUDED
#include "test/test.h"
#endif

class A {
public:
    A():num(0) {}
    A(int a):num(a) {}
    int a() const { return num; }
private:
    int num;
};

TEST_F(foo, FooCPP) {
    A a2(2);
    EXPECT_EQ(a2.a(), 2);
    A a;
    EXPECT_EQ(a.a(), 0);
}
