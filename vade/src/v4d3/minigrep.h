#ifndef MINIGREP_H
#define MINIGREP_H

typedef struct {
    char *query;
    char *file_path;
} minigrep_config_t;

extern const char *minigrep_config_build(minigrep_config_t *config, int argc, char *argv[]);
extern const char *minigrep_run(minigrep_config_t *config);

#endif/*MINIGREP_H*/
