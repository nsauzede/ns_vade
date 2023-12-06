#ifndef OS_COMPAT_H
#define OS_COMPAT_H

#ifdef WIN32
#include <string.h>
void *reallocarray(void *ptr, size_t nmemb, size_t size) {
    return realloc(ptr, nmemb * size);
}
char *strchrnul(const char *s, int c) {
    char *ret = strchr(s, c);
    if (!ret) {
        ret = (char *)s + strlen(s);
    }
    return ret;
}
char *strndup(const char s[], size_t n) {
    size_t len = 0;
    for (size_t i = 0; i < n; i++) {
        if (!s[i]) {
            break;
        }
        len++;
    }
    char *res = calloc(len + 1, 1);
    for (size_t i = 0; i < len; i++) {
        res[i] = s[i];
    }
    return res;
}
#endif

#endif/*OS_COMPAT_H*/
