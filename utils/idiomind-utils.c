#include "html_view.h"
#include "tray.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int usage(const char *program)
{
    fprintf(stderr,
        "Usage:\n"
        "  %s html <target> [query]\n"
        "  %s html <target> <title> <width> <height> [query]\n"
        "  %s tray\n"
        "\n"
        "Available utilities:\n"
        "  html          Open an HTML file or URL in a GTK/WebKit window\n"
        "  tray          Run the Idiomind system tray\n",
        program, program, program
    );

    return EXIT_FAILURE;
}

int main(int argc, char **argv)
{
    if (argc < 2)
        return usage(argv[0]);

    if (strcmp(argv[1], "tray") == 0)
        return tray_run();

    if (strcmp(argv[1], "html") == 0)
        return html_view_run(argc - 1, argv + 1);

    fprintf(stderr, "Unknown utility: %s\n\n", argv[1]);
    return usage(argv[0]);
}
