import os
import gtk
import gio
import signal
import subprocess
import appindicator
import os.path
import gettext


icon = '/usr/share/idiomind/images/tray.xpm'
t = gettext.translation('idiomind', 'locale', fallback=True)
gettext = t.ugettext
Add = gettext('Add')
Topics = gettext('Topics')
Settings = gettext('Settings')
Quit = gettext('Quit')

class Indicator:

    cfg = os.getenv('HOME') + '/.config/idiomind/s/7.cfg'

    def __init__(self):
        self.ind = appindicator.Indicator(icon,
        icon, appindicator.CATEGORY_APPLICATION_STATUS)
        self.ind.set_status(appindicator.STATUS_ACTIVE)
        self.update_menu()

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

    def update_menu(self, widget = None, data = None):
        try:
            m = open(self.cfg).readlines()
            menutopic = m
            
        except IOError:
            menutopic = []
            
        menu = gtk.Menu()
        self.ind.set_menu(menu)
        
        item = self.create_menu_label("Add")
        item.connect("activate", self.on_Add_click)
        menu.append(item)
        for bm in menutopic:
            label = bm.rstrip('\n')
            if not label:
                label = ""
            item = self.create_menu_icon(label, "gtk-home")
            item.connect("activate", self.on_Home)
            menu.append(item)
        item = gtk.SeparatorMenuItem()
        menu.append(item)
        item = self.create_menu_label("Topics")
        item.connect("activate", self.on_Topics_click)
        menu.append(item)
        item = self.create_menu_label("Settings")
        item.connect("activate", self.on_Settings_click)
        menu.append(item)
        item = self.create_menu_label("Quit")
        item.connect("activate", self.on_Quit_click)
        menu.append(item)
        menu.show_all()

    def on_Home(self, widget):
        os.system("idiomind topic")

    def on_Add_click(self, widget):
        os.system("'/usr/share/idiomind/add.sh' 'new_items'")
        
    def on_Topics_click(self, widget):
        subprocess.Popen('/usr/share/idiomind/chng.sh')
        
    def on_Settings_click(self, widget):
        subprocess.Popen('/usr/share/idiomind/cnfg.sh')
    
    def on_Quit_click(self, widget):
        os.system("/usr/share/idiomind/stop.sh 1")
        gtk.main_quit()

    def on_Topic_Changed(self, filemonitor, file, other_file, event_type):
        if event_type == gio.FILE_MONITOR_EVENT_CHANGES_DONE_HINT:
            self.update_menu()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda signal, frame: gtk.main_quit())
    i = Indicator()
    file = gio.File(i.cfg)
    monitor = file.monitor_file()
    monitor.connect("changed", i.on_Topic_Changed)            
    gtk.main()
