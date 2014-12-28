#!/usr/bin/python
# -*- coding: utf-8 -*-

import wx, os

class new(wx.Frame):
    """make a frame, inherits wx.Frame, add a panel and button"""
    def __init__(self):
        # create a frame, no parent, default to wxID_ANY
        wx.Frame.__init__(self, None, wx.ID_ANY, '',
            pos=(1750, 300), size=(67, 165),
            style = wx.CAPTION|wx.CLOSE_BOX|wx.FRAME_NO_TASKBAR|wx.STAY_ON_TOP)
        # panel needed to display button correctly
        self.panel1 = wx.Panel(self, -1)
        
        # pick a button image file you have (.bmp .jpg .gif or .png)
        img = "/usr/share/idiomind/icon/add.png"
        image1 = wx.Image(img, wx.BITMAP_TYPE_ANY).ConvertToBitmap()
        self.button1 = wx.BitmapButton(self.panel1, id=-1, bitmap=image1,
            pos=(0, 0), size = (image1.GetWidth()+35, image1.GetHeight()+30))
        self.button1.Bind(wx.EVT_BUTTON, self.button1Click)
        
        img = "/usr/share/idiomind/icon/tpc.png"
        image2 = wx.Image(img, wx.BITMAP_TYPE_ANY).ConvertToBitmap()
        self.button2 = wx.BitmapButton(self.panel1, id=-1, bitmap=image2,
            pos=(0, 54), size = (image2.GetWidth()+35, image2.GetHeight()+30))
        self.button2.Bind(wx.EVT_BUTTON, self.button2Click)
        
        img = "/usr/share/idiomind/icon/nte.png"
        image3 = wx.Image(img, wx.BITMAP_TYPE_ANY).ConvertToBitmap()
        self.button3 = wx.BitmapButton(self.panel1, id=-1, bitmap=image3,
            pos=(0, 108), size = (image3.GetWidth()+35, image3.GetHeight()+30))
        self.button3.Bind(wx.EVT_BUTTON, self.button3Click)
        
        # show the frame
        self.Show(True)

    def button1Click(self,event):
        os.system ("/usr/share/idiomind/add n_i &")
        
    def button2Click(self,event):
        os.system ("/usr/share/idiomind/add n_t &")
        
    def button3Click(self,event):
        os.system ("/usr/share/idiomind/ifs/tls nt &")
        
application = wx.PySimpleApp()
# call class MyFrame
window = new()
# start the event loop
application.MainLoop()
