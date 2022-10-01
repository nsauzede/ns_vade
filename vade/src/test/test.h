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
#include <string.h>

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

#define EXPECT_OR(bool_expr, ...) \
    do { \
        int __func__##_bool_expr_ = bool_expr; \
        int __func__##_expected_ = 1; \
        int failed = 0; \
        if (__func__##_bool_expr_ != __func__##_expected_) { \
            printf("%s:%d: %sFailure%s\n", __FILE__, __LINE__, RED(), NRM()); \
            test_Fail(test_opaque_); \
            failed = 1; \
        } else { \
            TEST_LOG("%s:%d: %sSuccess%s\n", __FILE__, __LINE__, GREEN(), NRM()); \
        } \
        __VA_ARGS__ \
        if (failed) return; \
    } while(0)

#define EXPECT_TRUE(bool_expr) \
    EXPECT_OR(bool_expr, \
        TEST_LOG("Value of: %s\n  Actual: %d\nExpected: %d\n", \
            STRINGIFY_(bool_expr), __func__##_bool_expr_, __func__##_expected_ \
        ); \
    )

#define EXPECT_FALSE(bool_expr) EXPECT_TRUE(!(bool_expr))

#define EXPECT_EQ(val1, val2) \
    do { \
        int __func__##_val1_ = val1; \
        int __func__##_val2_ = val2; \
        EXPECT_OR(__func__##_val1_ == __func__##_val2_, \
            TEST_LOG("Expected equality of these values:\n  {%s}    Which is: %d\n  {%s}    Which is: %d\n", \
                STRINGIFY_(val1), __func__##_val1_, STRINGIFY_(val2), __func__##_val2_ \
            ); \
        ); \
    } while(0)

#define EXPECT_STREQ(s1, s2) \
    do { \
        const char *__func__##_s1_ = s1; \
        const char *__func__##_s2_ = s2; \
        EXPECT_OR(!strcmp(__func__##_s1_, __func__##_s2_), \
            TEST_LOG("Expected equality of these strings:\n  {%s}    Which is: [%s]\n  {%s}    Which is: [%s]\n", \
                STRINGIFY_(s1), __func__##_s1_, STRINGIFY_(s2), __func__##_s2_ \
            ); \
        ); \
    } while(0)

#define DUMP_MEM(name, ptr, sz) \
    do { \
        TEST_LOG("  {%s}    Which is: ", name); \
        for (size_t __func__##i = 0; __func__##i < sz; __func__##i++) { \
            TEST_LOG("%02x", ptr[__func__##i]); fflush(stdout); \
        } \
        TEST_LOG("\n"); \
    } while(0)

#define EXPECT_MEMEQ(s1, s2, sz) \
    do { \
        const unsigned char *__func__##_s1_ = s1; \
        const unsigned char *__func__##_s2_ = s2; \
        int __func__##_sz_ = sz; \
        EXPECT_OR(!memcmp(__func__##_s1_, __func__##_s2_, __func__##_sz_), \
            TEST_LOG("Expected equality of these data: (%d)\n", __func__##_sz_); \
            DUMP_MEM(STRINGIFY_(s1), __func__##_s1_, __func__##_sz_); \
            DUMP_MEM(STRINGIFY_(s2), __func__##_s2_, __func__##_sz_); \
        ); \
    } while(0)

#define STRINGIFY_HELPER_(name, ...) #name
#define STRINGIFY_(...) STRINGIFY_HELPER_(__VA_ARGS__, )

void test_Logf(void *opaque, const char *fmt, ...);          // printf-like API to output log message (disabled by default)
void test_Fail(void *opaque);                                // indicate a test failure

#ifdef __cplusplus
}
#endif

#endif/*TEST_H__*/
