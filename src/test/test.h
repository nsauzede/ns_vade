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

#ifndef TEST_H__
#define TEST_H__

#include <stdio.h>

/* In order to use lightwheight test framework, for example to test the package 'foo/foo.c'
you must create a separate file 'foo/foo_test.c' that includes both 'foo/foo.h' and 'test/test.h'

test/test is provided in vade install tree

The usage is simple :
Create tests using the TEST_F(package, test) macro.

Then call other API macros to drive the test (TEST_LOG, EXPECT_TRUE, EXPECT_EQ. etc..)

*/

#ifdef __cplusplus
extern "C" {
#endif

#define RED() "\x1b[31m"
#define GREEN() "\x1b[32m"
#define NRM() "\x1b[0m"

/* declare a package test function */
#define TEST_F(package, test) void package##_Test##test##_(void *test_opaque_)

#define TEST_LOG(...) test_Logf(test_opaque_, __VA_ARGS__)

#define EXPECT_OR(bool_expr, fmt, ...) \
    do { \
        int __func__##_bool_expr_ = bool_expr; \
        int __func__##_expected_ = 1; \
        if (__func__##_bool_expr_ != __func__##_expected_) { \
            printf("%s:%d: %sFailure%s\n", __FILE__, __LINE__, RED(), NRM()); \
            printf(fmt, __VA_ARGS__); \
            test_Fail(test_opaque_); \
        } else { \
            TEST_LOG("%s:%d: %sSuccess%s\n", __FILE__, __LINE__, GREEN(), NRM()); \
            TEST_LOG("Value of: %s\n", STRINGIFY_(bool_expr)); \
            TEST_LOG("  Actual: %d\n", __func__##_bool_expr_); \
            TEST_LOG("Expected: %d\n", __func__##_expected_); \
        } \
    } while(0)

#define EXPECT_TRUE(bool_expr) EXPECT_OR(bool_expr, "Value of: %s\n  Actual: %d\nExpected: %d\n", STRINGIFY_(bool_expr), __func__##_bool_expr_, __func__##_expected_)

#define EXPECT_FALSE(bool_expr) EXPECT_TRUE(!(bool_expr))

#define Z2EXPECT_EQ(val1, val2) EXPECT_OR(val1 == val2, "Expected equality of these values:\n  %s\n    Which is: %d\n  %s\n    Which is: %d\n", STRINGIFY_(val1), __func__##_val1_, STRINGIFY_(val2), __func__##_val2_)

#define EXPECT_EQ(val1, val2) \
    do { \
        int __func__##_val1_ = val1; \
        int __func__##_val2_ = val2; \
        EXPECT_OR(val1 == val2, "Expected equality of these values:\n  %s\n    Which is: %d\n  %s\n    Which is: %d\n", STRINGIFY_(val1), __func__##_val1_, STRINGIFY_(val2), __func__##_val2_); \
    } while(0)

#define Z1EXPECT_EQ(val1, val2) \
    do { \
        int __func__##_val1_ = val1; \
        int __func__##_val2_ = val2; \
        if (__func__##_val1_ != __func__##_val2_) { \
            printf("%s:%d: Failure\n", __FILE__, __LINE__); \
            printf("Expected equality of these values:\n"); \
            printf("  %s\n", STRINGIFY_(val1)); \
            printf("    Which is: %d\n", __func__##_val1_); \
            printf("  %s\n", STRINGIFY_(val2)); \
            printf("    Which is: %d\n", __func__##_val2_); \
            test_Fail(test_opaque_); \
        } else { \
            TEST_LOG("%s:%d: Success\n", __FILE__, __LINE__); \
            TEST_LOG("Equality of these values:\n"); \
            TEST_LOG("  %s\n", STRINGIFY_(val1)); \
            TEST_LOG("    Which is: %d\n", __func__##_val1_); \
            TEST_LOG("  %s\n", STRINGIFY_(val2)); \
            TEST_LOG("    Which is: %d\n", __func__##_val2_); \
        } \
    } while(0)

#define STRINGIFY_HELPER_(name, ...) #name
#define STRINGIFY_(...) STRINGIFY_HELPER_(__VA_ARGS__, )

void test_Logf(void *opaque, const char *fmt, ...);          // printf-like API to output log message (disabled by default)
void test_Fail(void *opaque);                                // indicate a test failure

#ifdef __cplusplus
}
#endif

#endif/*TEST_H__*/
