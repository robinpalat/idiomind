#!/usr/bin/env python3
# -*- ENCODING: UTF-8 -*-
#
# Presentación fullscreen de Play.
#
# Recibe bloques de notas por un FIFO (<target>\n<source>\n<image>\n---\n)
# y los muestra en una ventana fullscreen sin decoración. Envía los comandos
# "advance" (Espacio) y "stop" (botón STOP) por otro FIFO al motor Play.
# El motor sigue siendo el responsable de playlists, audio y avance.

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf
import os
import sys
import html


class PlayPresent(Gtk.Window):
    def __init__(self, fifo_in, fifo_out):
        super().__init__()
        self.fifo_in = fifo_in
        self.fifo_out = fifo_out
        self.buf = ""

        self.set_decorated(False)
        self.set_title("Idiomind")
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_keep_above(True)
        self.fullscreen()
        self.set_app_paintable(True)
        self.override_background_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(0.05, 0.05, 0.07, 1.0))

        css = b"""
        window { background-color: #0d0d12; }
        button {
            font-family: Sans;
            font-weight: bold;
            font-size: 24px;
            padding: 14px 40px;
            background: #a02020;
            color: #ffffff;
            border: none;
            border-radius: 6px;
        }
        button:hover { background: #c03030; }
        """
        prov = Gtk.CssProvider()
        prov.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=24)
        outer.set_valign(Gtk.Align.CENTER)
        outer.set_halign(Gtk.Align.CENTER)
        self.add(outer)

        self.target = Gtk.Label()
        self.target.set_line_wrap(True)
        self.target.set_markup('<span font="Sans Bold 64" color="#ffffff"></span>')
        outer.pack_start(self.target, False, False, 0)

        self.source = Gtk.Label()
        self.source.set_line_wrap(True)
        self.source.set_markup('<span font="Sans 40" color="#b8b8b8"></span>')
        outer.pack_start(self.source, False, False, 0)

        self.image = Gtk.Image()
        outer.pack_start(self.image, False, False, 0)

        self.stop_btn = Gtk.Button(label="STOP")
        self.stop_btn.connect("clicked", self.on_stop)
        outer.pack_start(self.stop_btn, False, False, 0)

        self.connect("key-press-event", self.on_key)
        self.connect("destroy", self.on_destroy)

        self.fd = os.open(self.fifo_in, os.O_RDONLY | os.O_NONBLOCK)
        GLib.io_add_watch(self.fd, GLib.IO_IN | GLib.IO_HUP, self.on_fifo)

    def on_key(self, widget, event):
        if event.keyval == Gdk.KEY_space:
            self.send_cmd("advance")
            return True
        if event.keyval == Gdk.KEY_Escape:
            self.on_stop()
            return True
        return False

    def send_cmd(self, cmd):
        try:
            fd = os.open(self.fifo_out, os.O_WRONLY | os.O_NONBLOCK)
            os.write(fd, (cmd + "\n").encode("utf-8"))
            os.close(fd)
        except OSError:
            pass

    def on_stop(self, *args):
        # Integración con el mecanismo de parada existente.
        try:
            os.system('"%s/stop.sh" 2 >/dev/null 2>&1 &' % os.environ.get("DS", "/usr/share/idiomind"))
        except Exception:
            pass
        Gtk.main_quit()

    def on_destroy(self, *args):
        Gtk.main_quit()

    def on_fifo(self, fd, condition):
        try:
            data = os.read(fd, 65536)
        except OSError:
            return False
        if not data:
            return False
        self.buf += data.decode("utf-8", "replace")
        while "\n---\n" in self.buf:
            block, self.buf = self.buf.split("\n---\n", 1)
            self.apply_block(block)
        return True

    def apply_block(self, block):
        lines = block.split("\n")
        target = lines[0] if len(lines) > 0 else ""
        source = lines[1] if len(lines) > 1 else ""
        image = lines[2] if len(lines) > 2 else ""
        self.target.set_markup(
            '<span font="Sans Bold 64" color="#ffffff">%s</span>' % html.escape(target))
        self.source.set_markup(
            '<span font="Sans 40" color="#b8b8b8">%s</span>' % html.escape(source))
        if image and os.path.isfile(image):
            try:
                screen = Gdk.Screen.get_default()
                max_w = int(screen.get_width() * 0.70)
                max_h = int(screen.get_height() * 0.45)
                pb = GdkPixbuf.Pixbuf.new_from_file(image)
                w, h = pb.get_width(), pb.get_height()
                scale = min(max_w / w, max_h / h, 1.0)
                if scale < 1.0:
                    pb = pb.scale_simple(int(w * scale), int(h * scale),
                                         GdkPixbuf.InterpType.BILINEAR)
                self.image.set_from_pixbuf(pb)
                self.image.show()
            except Exception:
                self.image.hide()
        else:
            self.image.hide()

    def run(self):
        self.show_all()
        self.image.hide()
        Gtk.main()


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1)
    PlayPresent(sys.argv[1], sys.argv[2]).run()
