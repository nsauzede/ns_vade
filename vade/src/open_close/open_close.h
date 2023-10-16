typedef struct {
    char *text;
} printer_t;
extern printer_t *printer();
extern void printer_print(printer_t *p, char *s);
