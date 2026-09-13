#include "html_view.h"

#include <gtk/gtk.h>
#include <webkit2/webkit2.h>
#include <stdlib.h>
#include <string.h>

static const char *target = NULL;
static const char *query = NULL;
static const char *window_title = "Idiomind";
static int window_width = 750;
static int window_height = 470;

static void activate(GtkApplication *app, gpointer user_data)
{
    (void)user_data;

    GtkWidget *window;
    WebKitWebView *webview;
    char *uri = NULL;
    char *full_uri = NULL;

    window = gtk_application_window_new(app);

    gtk_window_set_title(GTK_WINDOW(window), window_title);
    gtk_window_set_default_size(
        GTK_WINDOW(window),
        window_width,
        window_height
    );

    gtk_window_set_icon_from_file(
        GTK_WINDOW(window),
        "/usr/share/idiomind/images/logo.png",
        NULL
    );

    webview = WEBKIT_WEB_VIEW(webkit_web_view_new());

    if (g_str_has_prefix(target, "http://") ||
        g_str_has_prefix(target, "https://")) {

        uri = g_strdup(target);

    } else {

        if (!g_file_test(target, G_FILE_TEST_IS_REGULAR)) {
            g_printerr("File not found: %s\n", target);
            gtk_widget_destroy(window);
            return;
        }

        uri = g_filename_to_uri(target, NULL, NULL);

        if (uri == NULL) {
            g_printerr("Could not convert path to URI: %s\n", target);
            gtk_widget_destroy(window);
            return;
        }
    }

    if (query != NULL && query[0] != '\0') {
        full_uri = g_strdup_printf("%s?%s", uri, query);
        webkit_web_view_load_uri(webview, full_uri);
        g_free(full_uri);
    } else {
        webkit_web_view_load_uri(webview, uri);
    }

    g_free(uri);

    gtk_container_add(
        GTK_CONTAINER(window),
        GTK_WIDGET(webview)
    );

    gtk_widget_show_all(window);
}

int html_view_run(int argc, char **argv)
{
    GtkApplication *app;
    int status;

    /*
     * argv[0] = html
     * argv[1] = TARGET
     * argv[2] = QUERY                  (optional)
     *
     * Extended:
     * argv[1] = TARGET
     * argv[2] = TITLE
     * argv[3] = WIDTH
     * argv[4] = HEIGHT
     * argv[5] = QUERY                  (optional)
     */
    if (argc < 2 || argc > 6) {
        g_printerr(
            "Usage:\n"
            "  idiomind-utils html <target> [query]\n"
            "  idiomind-utils html <target> <title> <width> <height> [query]\n"
        );
        return EXIT_FAILURE;
    }

    target = argv[1];

    if (argc == 3) {
        query = argv[2];
    }

    if (argc >= 5) {
        window_title = argv[2];
        window_width = atoi(argv[3]);
        window_height = atoi(argv[4]);

        if (window_width <= 0)
            window_width = 750;

        if (window_height <= 0)
            window_height = 470;

        if (argc == 6)
            query = argv[5];
    }

    app = gtk_application_new(
        "org.idiomind.utils",
        G_APPLICATION_NON_UNIQUE
    );

    g_signal_connect(
        app,
        "activate",
        G_CALLBACK(activate),
        NULL
    );

    /* Pass only argv[0] to GTK; utility arguments were already parsed above. */
    status = g_application_run(
        G_APPLICATION(app),
        1,
        argv
    );

    g_object_unref(app);

    return status;
}
