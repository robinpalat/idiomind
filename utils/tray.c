#include "tray.h"

#include <gtk/gtk.h>
#include <gio/gio.h>
#include <glib.h>
#include <gmodule.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

/*
 * Idiomind tray
 *
 * Runtime backends:
 *   1. Ayatana AppIndicator3
 *   2. legacy AppIndicator3
 *   3. GTK3 StatusIcon fallback
 *
 * AppIndicator libraries are loaded dynamically so the binary does not
 * require either library to be present at link time. GTK3 remains the
 * common fallback/runtime dependency.
 */

typedef struct _AppIndicator AppIndicator;

typedef AppIndicator *(*IndicatorNewFunc)(const gchar *,
                                           const gchar *,
                                           gint);
typedef void (*IndicatorSetStatusFunc)(AppIndicator *, gint);
typedef void (*IndicatorSetTitleFunc)(AppIndicator *, const gchar *);
typedef void (*IndicatorSetMenuFunc)(AppIndicator *, GtkMenu *);

enum {
    INDICATOR_CATEGORY_OTHER = 2,
    INDICATOR_STATUS_ACTIVE = 1
};

typedef struct {
    GModule *module;
    AppIndicator *indicator;
    IndicatorSetMenuFunc set_menu;
    IndicatorSetStatusFunc set_status;
    IndicatorSetTitleFunc set_title;
    gboolean available;
} IndicatorBackend;

typedef struct {
    GtkWidget *menu;
    GtkStatusIcon *status_icon;
    IndicatorBackend indicator;
    gboolean use_indicator;

    gchar *dirt;
    gchar *tpc;
    gchar *playlck;
    gchar *tasks_file;

    gchar *lbl1;
    gchar *lbl2;
    gchar *lbl3;
    gchar *lbl4;
    gchar *lbl5;
    gchar *lbl8;
    gchar *lbl9;
    gchar *lbl10;

    gint stts;
    GFileMonitor *monitor;
} TrayContext;

static TrayContext *ctx = NULL;

/* ------------------------------------------------------------------------- */
/* Environment                                                               */
/* ------------------------------------------------------------------------- */

static const gchar *env_or_empty(const gchar *name)
{
    const gchar *v = g_getenv(name);
    return v ? v : "";
}

static gchar *read_file_lines(const gchar *path)
{
    gchar *contents = NULL;
    gsize length = 0;

    if (!path || !g_file_get_contents(path, &contents, &length, NULL))
        return g_strdup("");

    return contents;
}

static void write_pid_file(void)
{
    gchar *path;
    gchar *pid;

    path = g_build_filename(ctx->dirt, "tray.pid", NULL);
    pid = g_strdup_printf("%ld\n", (long)getpid());

    if (!g_file_set_contents(path, pid, -1, NULL))
        g_printerr("Idiomind tray: could not write %s\n", path);

    g_free(pid);
    g_free(path);
}

/* ------------------------------------------------------------------------- */
/* External commands                                                         */
/* ------------------------------------------------------------------------- */

static void spawn_async(const gchar *program, gchar *const argv[])
{
    GError *error = NULL;

    if (!g_spawn_async(NULL,
                       argv,
                       NULL,
                       G_SPAWN_SEARCH_PATH |
                       G_SPAWN_STDOUT_TO_DEV_NULL |
                       G_SPAWN_STDERR_TO_DEV_NULL,
                       NULL,
                       NULL,
                       NULL,
                       &error)) {
        g_printerr("Idiomind tray: %s\n", error->message);
        g_error_free(error);
    }
}

static void run_command_async(const gchar *command)
{
    gchar *argv[] = { (gchar *)"sh", (gchar *)"-c", (gchar *)command, NULL };
    spawn_async("sh", argv);
}

/* ------------------------------------------------------------------------- */
/* AppIndicator runtime loading                                              */
/* ------------------------------------------------------------------------- */

static gboolean load_indicator_library(const gchar *library)
{
    IndicatorBackend *b = &ctx->indicator;

    b->module = g_module_open(library, G_MODULE_BIND_LAZY);
    if (!b->module)
        return FALSE;

    IndicatorNewFunc indicator_new = NULL;

    if (!g_module_symbol(b->module, "app_indicator_new",
                         (gpointer *)&indicator_new) ||
        !g_module_symbol(b->module, "app_indicator_set_status",
                         (gpointer *)&b->set_status) ||
        !g_module_symbol(b->module, "app_indicator_set_menu",
                         (gpointer *)&b->set_menu) ||
        !g_module_symbol(b->module, "app_indicator_set_title",
                         (gpointer *)&b->set_title)) {
        g_module_close(b->module);
        memset(b, 0, sizeof(*b));
        return FALSE;
    }

    b->indicator = indicator_new("idiomind", "idiomind",
                                 INDICATOR_CATEGORY_OTHER);

    if (!b->indicator) {
        g_module_close(b->module);
        memset(b, 0, sizeof(*b));
        return FALSE;
    }

    b->available = TRUE;
    b->set_status(b->indicator, INDICATOR_STATUS_ACTIVE);
    b->set_title(b->indicator, "Idiomind");

    return TRUE;
}

static gboolean init_indicator_backend(void)
{
    /*
     * Prefer Ayatana, then legacy AppIndicator.
     *
     * The exact soname is intentionally not hard-coded as a single choice:
     * distributions may package different sonames.
     */
    static const gchar *libraries[] = {
        "libayatana-appindicator3.so.1",
        "libayatana-appindicator3.so",
        "libappindicator3.so.1",
        "libappindicator3.so",
        NULL
    };

    for (gint i = 0; libraries[i]; ++i) {
        if (load_indicator_library(libraries[i]))
            return TRUE;
    }

    return FALSE;
}

/* ------------------------------------------------------------------------- */
/* Menu helpers                                                              */
/* ------------------------------------------------------------------------- */

static GtkWidget *menu_item_with_callback(const gchar *label,
                                          GCallback callback)
{
    GtkWidget *item = gtk_menu_item_new_with_label(label ? label : "");
    g_signal_connect(item, "activate", callback, NULL);
    return item;
}

static void on_topic(GtkMenuItem *item, gpointer data)
{
    (void)data;
    const gchar *command = "idiomind topic &";
    (void)item;
    run_command_async(command);
}

static void add_topics(GtkWidget *menu)
{
    gchar *contents;
    gchar **lines;

    contents = read_file_lines(ctx->tpc);
    lines = g_strsplit(contents, "\n", -1);

    for (gint i = 0; lines[i]; ++i) {
        if (lines[i][0] == '\0')
            continue;

        GtkWidget *item = gtk_menu_item_new_with_label(lines[i]);
        GtkWidget *image = gtk_image_new_from_icon_name(
            "go-home", GTK_ICON_SIZE_MENU);

        GtkWidget *box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);
        gtk_box_pack_start(GTK_BOX(box), image, FALSE, FALSE, 0);
        gtk_box_pack_start(GTK_BOX(box),
                           gtk_label_new(lines[i]),
                           FALSE, FALSE, 0);

        gtk_container_add(GTK_CONTAINER(item), box);
        g_object_set_data_full(G_OBJECT(item), "topic",
                               g_strdup(lines[i]), g_free);

        g_signal_connect(item, "activate",
                         G_CALLBACK(on_topic), NULL);

        gtk_menu_shell_append(GTK_MENU_SHELL(menu), item);
    }

    g_strfreev(lines);
    g_free(contents);
}

static void on_task(GtkMenuItem *item, gpointer data)
{
    (void)data;

    const gchar *task = g_object_get_data(G_OBJECT(item), "task");
    if (!task)
        return;

    gchar *script = g_build_filename("/usr/share/idiomind",
                                     "ifs", "tasks.sh", NULL);

    gchar *argv[] = {
        script,
        (gchar *)task,
        NULL
    };

    spawn_async(script, argv);
    g_free(script);
}

static void add_tasks(GtkWidget *menu)
{
    if (!g_file_test(ctx->tasks_file, G_FILE_TEST_EXISTS))
        return;

    gchar *contents = read_file_lines(ctx->tasks_file);
    gchar **lines = g_strsplit(contents, "\n", -1);

    GtkWidget *submenu = gtk_menu_new();
    GtkWidget *parent = gtk_menu_item_new_with_label(ctx->lbl9);

    for (gint i = 0; lines[i]; ++i) {
        if (lines[i][0] == '\0')
            continue;

        GtkWidget *item = gtk_menu_item_new_with_label(lines[i]);
        g_object_set_data_full(G_OBJECT(item), "task",
                               g_strdup(lines[i]), g_free);

        g_signal_connect(item, "activate",
                         G_CALLBACK(on_task), NULL);

        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
    }

    gtk_menu_item_set_submenu(GTK_MENU_ITEM(parent), submenu);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), parent);

    g_strfreev(lines);
    g_free(contents);
}

/* ------------------------------------------------------------------------- */
/* Actions                                                                   */
/* ------------------------------------------------------------------------- */

static void on_home(GtkMenuItem *item, gpointer data)
{
    (void)item;
    (void)data;
    run_command_async("idiomind topic &");
}

static void on_add(GtkMenuItem *item, gpointer data)
{
    (void)item;
    (void)data;
    run_command_async("/usr/share/idiomind/add.sh new_items &");
}

static void on_topics(GtkMenuItem *item, gpointer data)
{
    (void)item;
    (void)data;
    run_command_async("/usr/share/idiomind/chng.sh &");
}

static void on_play(GtkMenuItem *item, gpointer data)
{
    (void)item;
    (void)data;

    ctx->stts = 0;
    run_command_async("/usr/share/idiomind/bcle.sh &");
}

static void on_stop(GtkMenuItem *item, gpointer data)
{
    (void)item;
    (void)data;

    ctx->stts = 1;
    run_command_async("/usr/share/idiomind/stop.sh 2 &");
}

static void on_quit(GtkMenuItem *item, gpointer data)
{
    (void)item;
    (void)data;

    run_command_async("/usr/share/idiomind/stop.sh 1 &");
    gtk_main_quit();
}

/* ------------------------------------------------------------------------- */
/* State                                                                      */
/* ------------------------------------------------------------------------- */

static void update_status(void)
{
    gchar *contents = read_file_lines(ctx->playlck);

    ctx->stts = 1;

    gchar **lines = g_strsplit(contents, "\n", -1);
    for (gint i = 0; lines[i]; ++i) {
        if (g_strcmp0(lines[i], "0") == 0)
            ctx->stts = 1;
        else if (lines[i][0] != '\0')
            ctx->stts = 0;
    }

    g_strfreev(lines);
    g_free(contents);
}

/* ------------------------------------------------------------------------- */
/* Menu construction                                                         */
/* ------------------------------------------------------------------------- */

static GtkWidget *build_menu(void)
{
    GtkWidget *menu = gtk_menu_new();

    gtk_menu_shell_append(
        GTK_MENU_SHELL(menu),
        menu_item_with_callback(ctx->lbl1, G_CALLBACK(on_add)));

    if (ctx->stts == 0)
        gtk_menu_shell_append(
            GTK_MENU_SHELL(menu),
            menu_item_with_callback(ctx->lbl3, G_CALLBACK(on_stop)));
    else
        gtk_menu_shell_append(
            GTK_MENU_SHELL(menu),
            menu_item_with_callback(ctx->lbl2, G_CALLBACK(on_play)));

    add_topics(menu);
    add_tasks(menu);

    gtk_menu_shell_append(
        GTK_MENU_SHELL(menu),
        menu_item_with_callback(ctx->lbl5, G_CALLBACK(on_topics)));

    gtk_menu_shell_append(
        GTK_MENU_SHELL(menu),
        gtk_separator_menu_item_new());

    gtk_menu_shell_append(
        GTK_MENU_SHELL(menu),
        menu_item_with_callback(ctx->lbl8, G_CALLBACK(on_quit)));

    gtk_widget_show_all(menu);

    return menu;
}

static void rebuild_menu(void)
{
    update_status();

    GtkWidget *new_menu = build_menu();

    if (ctx->use_indicator) {
        ctx->indicator.set_menu(ctx->indicator.indicator,
                                GTK_MENU(new_menu));

        if (ctx->menu)
            gtk_widget_destroy(ctx->menu);

        ctx->menu = new_menu;
    } else {
        gtk_menu_popup_at_pointer(GTK_MENU(new_menu), NULL);

        if (ctx->menu)
            gtk_widget_destroy(ctx->menu);

        ctx->menu = new_menu;
    }
}

/* ------------------------------------------------------------------------- */
/* GTK StatusIcon fallback                                                    */
/* ------------------------------------------------------------------------- */

static void on_status_popup(GtkStatusIcon *status_icon,
                            guint button,
                            guint activate_time,
                            gpointer data)
{
    (void)status_icon;
    (void)button;
    (void)activate_time;
    (void)data;

    update_status();

    GtkWidget *menu = build_menu();
    ctx->menu = menu;

    gtk_menu_popup_at_pointer(GTK_MENU(menu), NULL);
}

static void on_status_activate(GtkStatusIcon *status_icon, gpointer data)
{
    (void)status_icon;
    (void)data;

    update_status();

    GtkWidget *menu = build_menu();
    ctx->menu = menu;

    gtk_menu_popup_at_pointer(GTK_MENU(menu), NULL);
}

static gboolean init_status_icon(void)
{
    ctx->status_icon = gtk_status_icon_new_from_icon_name("idiomind");

    if (!ctx->status_icon)
        return FALSE;

    gtk_status_icon_set_tooltip_text(ctx->status_icon, "Idiomind");

    g_signal_connect(ctx->status_icon, "popup-menu",
                     G_CALLBACK(on_status_popup), NULL);

    g_signal_connect(ctx->status_icon, "activate",
                     G_CALLBACK(on_status_activate), NULL);

    return TRUE;
}

/* ------------------------------------------------------------------------- */
/* File monitor                                                              */
/* ------------------------------------------------------------------------- */

static void on_directory_changed(GFileMonitor *monitor,
                                  GFile *file,
                                  GFile *other_file,
                                  GFileMonitorEvent event,
                                  gpointer data)
{
    (void)monitor;
    (void)file;
    (void)other_file;
    (void)data;

    if (event == G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT ||
        event == G_FILE_MONITOR_EVENT_CREATED ||
        event == G_FILE_MONITOR_EVENT_DELETED ||
        event == G_FILE_MONITOR_EVENT_CHANGED) {

        update_status();

        if (ctx->use_indicator && ctx->indicator.indicator) {
            GtkWidget *menu = build_menu();
            ctx->indicator.set_menu(ctx->indicator.indicator,
                                    GTK_MENU(menu));

            if (ctx->menu)
                gtk_widget_destroy(ctx->menu);

            ctx->menu = menu;
        }
    }
}

/* ------------------------------------------------------------------------- */
/* Lifecycle                                                                 */
/* ------------------------------------------------------------------------- */

static void cleanup(void)
{
    if (!ctx)
        return;

    if (ctx->monitor)
        g_object_unref(ctx->monitor);

    if (ctx->indicator.module)
        g_module_close(ctx->indicator.module);

    if (ctx->status_icon)
        g_object_unref(ctx->status_icon);

    g_free(ctx->dirt);
    g_free(ctx->tpc);
    g_free(ctx->playlck);
    g_free(ctx->tasks_file);

    g_free(ctx->lbl1);
    g_free(ctx->lbl2);
    g_free(ctx->lbl3);
    g_free(ctx->lbl4);
    g_free(ctx->lbl5);
    g_free(ctx->lbl8);
    g_free(ctx->lbl9);
    g_free(ctx->lbl10);

    g_free(ctx);
    ctx = NULL;
}

static void init_context(void)
{
    const gchar *home = g_get_home_dir();

    ctx = g_new0(TrayContext, 1);

    ctx->dirt = g_strdup(env_or_empty("dirt"));
    ctx->tpc = g_build_filename(home, ".config", "idiomind", "tpc", NULL);
    ctx->playlck = g_build_filename(ctx->dirt, "playlck", NULL);
    ctx->tasks_file = g_build_filename(ctx->dirt, "tasks", NULL);

    ctx->lbl1 = g_strdup(env_or_empty("lbl1"));
    ctx->lbl2 = g_strdup(env_or_empty("lbl2"));
    ctx->lbl3 = g_strdup(env_or_empty("lbl3"));
    ctx->lbl4 = g_strdup(env_or_empty("lbl4"));
    ctx->lbl5 = g_strdup(env_or_empty("lbl5"));
    ctx->lbl8 = g_strdup(env_or_empty("lbl8"));
    ctx->lbl9 = g_strdup(env_or_empty("lbl9"));
    ctx->lbl10 = g_strdup(env_or_empty("lbl10"));

    ctx->stts = 1;
}

static gboolean on_startup_timeout(gpointer data)
{
    (void)data;
    update_status();
    return G_SOURCE_REMOVE;
}

int tray_run(void)
{
    init_context();
    write_pid_file();

    gtk_init(NULL, NULL);

    /*
     * Runtime fallback order:
     *
     *   Ayatana AppIndicator
     *   legacy AppIndicator
     *   GTK StatusIcon
     */
    if (init_indicator_backend()) {
        ctx->use_indicator = TRUE;

        GtkWidget *menu = build_menu();
        ctx->indicator.set_menu(ctx->indicator.indicator,
                                GTK_MENU(menu));
        ctx->menu = menu;
    } else {
        ctx->use_indicator = FALSE;

        if (!init_status_icon()) {
            g_printerr("Idiomind tray: no supported tray backend found.\n");
            cleanup();
            return EXIT_FAILURE;
        }
    }

    if (ctx->dirt[0] != '\0') {
        GFile *directory = g_file_new_for_path(ctx->dirt);
        GError *error = NULL;

        ctx->monitor = g_file_monitor_directory(
            directory,
            G_FILE_MONITOR_NONE,
            NULL,
            &error);

        if (ctx->monitor) {
            g_signal_connect(ctx->monitor, "changed",
                             G_CALLBACK(on_directory_changed), NULL);
        } else if (error) {
            g_printerr("Idiomind tray: directory monitor: %s\n",
                       error->message);
            g_error_free(error);
        }

        g_object_unref(directory);
    }

    g_timeout_add(500, on_startup_timeout, NULL);

    gtk_main();

    cleanup();
    return EXIT_SUCCESS;
}
