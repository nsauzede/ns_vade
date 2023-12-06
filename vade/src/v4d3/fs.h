#ifndef MINIGREP_FS_H
#define MINIGREP_FS_H

#include <malloc.h>
#include <stdio.h>

const char *fs_read_to_string(char **_result, const char *path) {
    FILE *in = fopen(path, "rt");
    if (!in) {
        return "No such file or directory (os error 2)";
    }
    fseek(in, 0, SEEK_END);
    long size = ftell(in);
    rewind(in);
    *_result = malloc(size);
    fread(*_result, size, 1, in);
    fclose(in);
    return 0;
}

#endif/*MINIGREP_FS_H*/
