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

TEST_F(foo, Foo) {
    int bar = 1;
    int foo = foo_Foo(bar);
    EXPECT_EQ(foo, 42);
}

TEST_F(foo, Foo2) {
    int bar = 2;
    int foo = foo_Foo(bar);
    EXPECT_EQ(foo, 84);
}
