#include "open_close.h"
#include <stdlib.h>
#include <string.h>

printer_t *printer() {
    printer_t *p = calloc(1, sizeof(printer_t));
    p->text = calloc(1, 1);
}
void printer_free(printer_t *p) {
    if (p) {
        free(p->text);
        free(p);
    }
}
void printer_print(printer_t *p, char *s) {
    p->text = realloc(p->text, strlen(p->text) + strlen(s) + 1);
    strcat(p->text, s);
}

#include "test/test.h"
TEST_F(open_close, Printer_001_empty) {
    printer_t *p = printer();
    EXPECT_STREQ("", p->text);
    printer_free(p);
}

TEST_F(open_close, Printer_002_one_print) {
    printer_t *p = printer();
    printer_print(p, "hello");
    EXPECT_STREQ("hello", p->text);
    printer_free(p);
}

TEST_F(open_close, Printer_003_two_prints) {
    printer_t *p = printer();
    printer_print(p, "hello");
    printer_print(p, " world!\n");
    EXPECT_STREQ("hello world!\n", p->text);
    printer_free(p);
}
