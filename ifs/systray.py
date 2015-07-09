import pygtk
pygtk.require("2.0")
import gtk
import os
import gobject
import appindicator
import gio
import signal
import subprocess
import os.path
import gettext
icon = '/usr/share/idiomind/images/tray.xpm'

class MiroAppIndicator:

    cfg = os.getenv('HOME') + '/.config/idiomind/s/7.cfg'
    def __init__(self):
        self.indicator = appindicator.Indicator(icon, icon, appindicator.CATEGORY_APPLICATION_STATUS)
        self.indicator.set_status(appindicator.STATUS_ACTIVE)
        self.menu_items = []
        self.stts = 0
        self.change_label()
        self._on_menu_update()
        
    def _on_menu_update(self):
        self.change_label()
    
    def create_menu_label(self, label):
        item = gtk.ImageMenuItem()
        item.set_label(label)
        return item

    def create_menu_icon(self, label, icon_name):
        image = gtk.Image()
        image.set_from_icon_name(icon_name, 24)
        item = gtk.ImageMenuItem()
        item.set_label(label)
        item.set_image(image)
        item.set_always_show_image(True)
        return item

    def make_menu_items(self):
        menu_items = []
        menu_items.append(("Add", self.on_Add_click))
        if self.stts == 0:
            menu_items.append(("Play", self.on_play))
        elif self.stts == 1:
            menu_items.append(("Stop", self.on_stop))
            #menu_items.append(("Next", self.on_next))
        return menu_items
        
    def change_label(self):
        menu_items = self.make_menu_items()
        try:
            m = open(self.cfg).readlines()
            menutopic = m
        except IOError:
            menutopic = []
        popup_menu = gtk.Menu()
        
        for label, callback in menu_items:
            if not label and not callback:
                item = gtk.SeparatorMenuItem()
            else:
                item = gtk.ImageMenuItem(label)
                item.connect('activate', callback)
            popup_menu.append(item)
        
        for bm in menutopic:
            label = bm.rstrip('\n')
            if not label:
                label = ""
            item = self.create_menu_icon(label, "gtk-home")
            item.connect("activate", self.on_Home)
            popup_menu.append(item)
        
        item = gtk.SeparatorMenuItem()
        popup_menu.append(item)
        item = self.create_menu_label("Topics")
        item.connect("activate", self.on_Topics_click)
        popup_menu.append(item)
        item = self.create_menu_label("Settings")
        item.connect("activate", self.on_Settings_click)
        popup_menu.append(item)
        item = self.create_menu_label("Quit")
        item.connect("activate", self.on_Quit_click)
        popup_menu.append(item)
        
        popup_menu.show_all()
        self.indicator.set_menu(popup_menu)
        self.menu_items = menu_items

    def on_Home(self, widget):
        os.system("idiomind topic")

    def on_Add_click(self, widget):
        os.system("'/usr/share/idiomind/add.sh' 'new_items'")
        
    def on_Topics_click(self, widget):
        subprocess.Popen('/usr/share/idiomind/chng.sh')
        
    def on_Settings_click(self, widget):
        subprocess.Popen('/usr/share/idiomind/cnfg.sh')

    def on_play(self, widget):
        self.stts = 1
        os.system("'/usr/share/idiomind/bcle.sh' &")
        self._on_menu_update()
        
    def on_stop(self, widget):
        self.stts = 0
        os.system("'/usr/share/idiomind/stop.sh' 2 &")
        self._on_menu_update()

    def on_next(self, widget):
        os.system("killall play")

    def on_Quit_click(self, widget):
        os.system("/usr/share/idiomind/stop.sh 1")
        gtk.main_quit()
    
    def on_Topic_Changed(self, filemonitor, file, other_file, event_type):
        if event_type == gio.FILE_MONITOR_EVENT_CHANGES_DONE_HINT:
            self._on_menu_update()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda signal, frame: gtk.main_quit())
    i = MiroAppIndicator()
    file = gio.File(i.cfg)
    monitor = file.monitor_file()
    monitor.connect("changed", i.on_Topic_Changed)      
    gtk.main()
