#include "minigrep.h"
#include "fs.h"
#include "os_compat.h"

#include <string.h>
#include <stdlib.h>

#define PANIC(fmt, ...) do{printf("%s:%d:%s:", __FILE__, __LINE__, __func__);printf(fmt, __VA_ARGS__);exit(1);}while(0)
#define P99_PROTECT(...) __VA_ARGS__
#define UNUSED(X) (const void*){0}=(X)

typedef struct {
    char *ptr;
    int len;
} str_t;
#define CSTR(s) {s, strlen(s)}

int str_cmp(str_t s1, str_t s2) {
    int len = s1.len;
    if (len != s2.len) {
        return 1;
    }
    return strncmp(s1.ptr, s2.ptr, len);
}

typedef struct {
    int len;
    int len_elem;
    void (*free)(void *);
    void (*free_elem)(void *);
    void *ptr;
} arr_t;
#define ARR_(name, type, arr) arr_t name = {sizeof(arr)/sizeof(arr[0]), 0, 0, 0, arr}
#define ARR(name, type, ...) ARR_(name, type, (type[])P99_PROTECT(__VA_ARGS__))

#define ARR_PUSH_BACK(name,elem) do{typeof(elem) name ## _elem = elem;arr_push_back(&name, &name ## _elem, sizeof(elem));}while(0)
#define ARR_ITER(name, i, type, arr) i = 0;for (type arr = (type)(name.ptr); i < (name).len; i++)

#define ARR_STRCMP_(name, arrstr) ({\
int name ## _i;char *name ## _arrstr[] = arrstr;int name ## _res = 1;\
if (name.len == (sizeof(name ## _arrstr)/sizeof(name ## _arrstr[0]))) {\
    name ## _res = 0; ARR_ITER(name, name ## _i, str_t *, arr) {\
        if ((int)strlen(name ## _arrstr[name ## _i]) == arr[name ## _i].len) {\
        if (strncmp(name ## _arrstr[name ## _i], arr[name ## _i].ptr, arr[name ## _i].len)){\
            name ## _res=1;break;\
        }}\
    }\
}name ## _res;})
#define ARR_STRCMP(name, ...) ARR_STRCMP_(name, P99_PROTECT(__VA_ARGS__))

#define ARR_CSTRCMP_(name, arrstr) ({\
int name ## _i;char *name ## _arrstr[] = arrstr;int name ## _res = 1;\
if (name.len == (sizeof(name ## _arrstr)/sizeof(name ## _arrstr[0]))) {\
    name ## _res = 0; ARR_ITER(name, name ## _i, char **, arr) {\
        if (strcmp(name ## _arrstr[name ## _i], arr[name ## _i])){\
            name ## _res=1;break;\
        }\
    }\
}name ## _res;})
#define ARR_CSTRCMP(name, ...) ARR_CSTRCMP_(name, P99_PROTECT(__VA_ARGS__))

arr_t arr_new(int len_elem) {
    arr_t v;
    memset(&v, 0, sizeof(v));
    v.free = free;
    v.len_elem = len_elem;
    return v;
}

arr_t arr_newdyn(int len_elem) {
    arr_t v = arr_new(len_elem);
    v.free_elem = free;
    return v;
}

void arr_free(arr_t v) {
    if (v.free_elem) {
        int i;
        ARR_ITER(v, i, void **, arr) {
            v.free_elem(arr[i]);
        }
    }
    if (v.free) {
        v.free(v.ptr);
    }
}

void arr_push_back(arr_t *v, void *ptr, int len_elem) {
    if (v) {
        if (v->len_elem != len_elem) {
            PANIC("PANIC! v.len_elem=%d len=%d\n", v->len_elem, len_elem);
        }
        v->ptr = reallocarray(v->ptr, len_elem, v->len + 1);
        memcpy(v->ptr + (v->len++ * len_elem), ptr, len_elem);
    }
}

arr_t search(const char *query, const char *contents) {
    arr_t v1 = arr_new(sizeof(str_t));
    if (!query || !contents) {
        return v1;
    }
    char *hit = strstr(contents, query);
    if (!hit) {
        return v1;
    }
    const char *begin = contents;
    while (1) {
        hit = strstr(begin, query);
        char *end = strchrnul(begin, '\n');
        if (hit && hit <= end) {
            str_t s = {(char *)begin, end - begin};
            arr_push_back(&v1, &s, sizeof(s));
        }
        if (!*end) {
            break;
        }
        begin = end + 1;
    }
    return v1;
}

arr_t search_case_insensitive(const char *query, const char *contents) {
    UNUSED(query), UNUSED(contents);
    arr_t v1 = arr_new(sizeof(str_t));
    return v1;
}

const char *minigrep_config_build(minigrep_config_t *config, int argc, char *argv[]) {
    if (argc < 3) {
        return "not enough arguments";
    }
    config->query = argv[1];
    config->file_path = argv[2];
    return 0;
}

const char *minigrep_run(minigrep_config_t *config) {
    char *contents = 0;
    const char *err;
    if (0 != (err = fs_read_to_string(&contents, config->file_path))) {
        return err;
    }
    arr_t v = search(config->query, contents);
    int i;
    ARR_ITER(v, i, str_t *, arr) {
        char *s = strndup(arr[i].ptr, arr[i].len);
        printf("%s\n", s);
        free(s);
    }
    free(contents);
    return 0;
}

#define ARR_STRCMP_OR_(name, arrstr) ({\
int name ## _i;char *name ## _arrstr[] = arrstr; assert_result_t name ## _res = {0, "<uninitialized>"};\
printf("  left: `[");\
printf("]`',\n");\
printf(" right: `[");\
printf("]`',\n");\
if (name.len == (sizeof(name ## _arrstr)/sizeof(name ## _arrstr[0]))) {\
    name ## _res.v = 1; ARR_ITER(name, name ## _i, str_t *, arr) {\
        if ((int)strlen(name ## _arrstr[name ## _i]) == arr[name ## _i].len) {\
        if (strncmp(name ## _arrstr[name ## _i], arr[name ## _i].ptr, arr[name ## _i].len)){\
            name ## _res.v=0;break;\
        }}\
    }\
}name ## _res;})
#define ARR_STRCMP_OR(name, ...) ARR_STRCMP_OR_(name, P99_PROTECT(__VA_ARGS__))

//#define ENABLE_TESTS
#ifdef ENABLE_TESTS
#include "test/test.h"
#if 0
TEST(bb_vec, test_001_search_case_insensitive) {
    const char *query = "rUsT";
    const char *contents = "\
Rust:\n\
safe, fast, productive.\n\
Pick three.\n\
Trust me.";
    arr_t res = search_case_insensitive(query, contents);
#if 1
    ASSERT_OR(ARR_STRCMP_OR(res, {"Rust:", "Trust me.",}));
#endif
    ASSERT_TRUE(0 == ARR_STRCMP(res, {"Rust:", "Trust me.",}));
    arr_free(res);
}
#endif
TEST_F(v4d3, minigrep_test_001_str_slc) {
    str_t s1 = CSTR("toto");
    char buf[] = "tata";
    str_t s2 = CSTR(buf);
    EXPECT_TRUE(0 != str_cmp(s1, s2));
    s2.ptr[1] = 'o';
    s2.ptr[3] = 'o';
    EXPECT_TRUE(0 == str_cmp(s1, s2));
}
TEST_F(v4d3, bb_vec_test_001_search) {
    const char *query = "duct";
    const char *contents = "\
Rust:\n\
safe, fast, productive.\n\
Pick three.\n\
Duct tape.";
    arr_t res = search(query, contents);
    EXPECT_TRUE(0 == ARR_STRCMP(res, {"safe, fast, productive.",}));
    arr_free(res);
}
const char *poem = "\
I'm nobody! Who are you?\n\
Are you nobody, too?\n\
Then there's a pair of us - don't tell!\n\
They'd banish us, you know.\n\
\n\
How dreary to be somebody!\n\
How public, like a frog\n\
To tell your name the livelong day\n\
To an admiring bog!";
TEST_F(v4d3, minigrep_test_002_search) {
    arr_t res;
    res = search("frog", poem);
    EXPECT_TRUE(0 == ARR_STRCMP(res, {"How public, like a frog",}));
    arr_free(res);
    res = search("body", poem);
    EXPECT_TRUE(0 == ARR_STRCMP(res, {"I'm nobody! Who are you?", "Are you nobody, too?", "How dreary to be somebody!"}));
    arr_free(res);
    res = search("monomorphization", poem);
    EXPECT_TRUE(0 == res.len);
    arr_free(res);
}
TEST_F(v4d3, bb_vec_test_001_arr_static) {
    ARR(arr_str, char *, { "one", "two", "three" });
    EXPECT_TRUE(3 == arr_str.len);
    ARR(arr_int, int, {1, 2, 3, 4});
    EXPECT_TRUE(4 == arr_int.len);
    const char *strings[] = { "one", "two", "three" };
    int i;
    int sum = 0;
    ARR_ITER(arr_int, i, int *, arr) {
        sum += arr[i];
    }
    EXPECT_TRUE(10 == sum);
    ARR_ITER(arr_str, i, char **, arr) {
        EXPECT_TRUE(0 == strcmp(strings[i], arr[i]));
    }
    EXPECT_TRUE(0 == ARR_CSTRCMP(arr_str, { "one", "two", "three" }));
}
TEST_F(v4d3, bb_vec_test_02_vec_stat) {
    arr_t v1 = arr_new(sizeof(char*));
    EXPECT_TRUE(0 == v1.len);
    ARR_PUSH_BACK(v1, (char*)"one");
    EXPECT_TRUE(1 == v1.len);
    ARR_PUSH_BACK(v1, (char*)"two");
    EXPECT_TRUE(2 == v1.len);
    ARR_PUSH_BACK(v1, (char*)"three");
    EXPECT_TRUE(3 == v1.len);
    EXPECT_TRUE(0 == strcmp("one", ((char **)v1.ptr)[0]));
    EXPECT_TRUE(0 == strcmp("two", ((char **)v1.ptr)[1]));
    EXPECT_TRUE(0 == strcmp("three", ((char **)v1.ptr)[2]));
    EXPECT_TRUE(0 == ARR_CSTRCMP(v1, { "one", "two", "three" }));
    arr_free(v1);
}
TEST_F(v4d3, bb_vec_test_010_vec_dyn) {
    arr_t v1 = arr_newdyn(sizeof(char*));
    EXPECT_TRUE(0 == v1.len);
    ARR_PUSH_BACK(v1, strdup("one"));
    EXPECT_TRUE(1 == v1.len);
    ARR_PUSH_BACK(v1, strdup("two"));
    EXPECT_TRUE(2 == v1.len);
    ARR_PUSH_BACK(v1, strdup("three"));
    EXPECT_TRUE(3 == v1.len);
    EXPECT_TRUE(0 == strcmp("one", ((char **)v1.ptr)[0]));
    EXPECT_TRUE(0 == strcmp("two", ((char **)v1.ptr)[1]));
    EXPECT_TRUE(0 == strcmp("three", ((char **)v1.ptr)[2]));
    EXPECT_TRUE(0 == ARR_CSTRCMP(v1, { "one", "two", "three" }));
    arr_free(v1);
}
typedef struct {
    char *city;
    int temp;
} city_temp_t;
TEST_F(v4d3, cityTemp_test_010_city_temp) {
    ARR(temperatures, city_temp_t, {
        {"City1", 19},
        {"City2", 22},
        {"City3", 21},
    });
    arr_t filtered_temps = arr_new(sizeof(city_temp_t));
    int i;
    ARR_ITER(temperatures, i, city_temp_t *, arr) {
        if (arr[i].temp > 20) {
            city_temp_t filtered = {arr[i].city, arr[i].temp};
            ARR_PUSH_BACK(filtered_temps, filtered);
        }
    }
    EXPECT_TRUE(2 == filtered_temps.len);
    arr_free(filtered_temps);
}

#endif

#include "test/test.h"
#include <inttypes.h>
typedef struct {
    uint64_t tt, drec;
} race_t;
ARR(INP01, race_t, { {7, 9}, {15, 40}, {30, 200} });
const uint64_t RES01 = 288;
ARR(INP1, race_t, { {41, 249}, {77, 1362}, {70, 1127}, {96, 1011} });
const uint64_t RES1 = 771628;
ARR(INP02, race_t, { {71530, 940200} });
const uint64_t RES02 = 71503;
ARR(INP2, race_t, { {41777096, 249136211271011} });
const uint64_t RES2 = 27363861;
uint64_t compute(arr_t inp) {
    uint64_t res = 1;
    int i;
    ARR_ITER(inp, i, race_t *, arr) {
        uint64_t tt = arr[i].tt;
        uint64_t drec = arr[i].drec;
        //printf("tt=%" PRIu64 " drec=%" PRIu64 "\n", arr[i].tt, arr[i].drec);
        uint64_t th1;
        for (th1 = 0; th1 < tt; th1++) {
            if (th1 * (tt - th1) > drec) {
                break;
            }
        }
        uint64_t th2;
        for (th2 = tt - 1; th2 != 0; th2--) {
            if (th2 * (tt - th2) > drec) {
                break;
            }
        }
        if (th2 > th1) {
            res *= th2 - th1 + 1;
        }
    }
    return res;
}
TEST_F(v4d3, part1_inp01) {
    uint64_t result = compute(INP01);
    EXPECT_EQ(RES01, result);
}
TEST_F(v4d3, part1_inp1) {
    uint64_t result = compute(INP1);
    EXPECT_EQ(RES1, result);
}
TEST_F(v4d3, part2_inp02) {
    uint64_t result = compute(INP02);
    EXPECT_EQ(RES02, result);
}
TEST_F(v4d3, part2_inp2) {
    uint64_t result = compute(INP2);
    EXPECT_EQ(RES2, result);
}
