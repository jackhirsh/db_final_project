from kivy.properties import NumericProperty, StringProperty, DictProperty, ListProperty
from kivy.uix.button import Button
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.uix.image import Image
from kivy.uix.spinner import Spinner
from kivy.uix.textinput import TextInput
from kivy.utils import get_color_from_hex
from kivy.app import App

import pprint


class CButton(Button):
    idn = StringProperty('')
    idt = StringProperty('')


class CScreen(Screen):
    idn = StringProperty('')
    idt = StringProperty('')
    callbacks = DictProperty({})

    def __init__(self, callbacks, **kwargs):
        super(CScreen, self).__init__(**kwargs)
        # Set the callbacks to the dict passed by the manager
        self.callbacks = callbacks
        self.callbacks['print_widg'] = self.print_widgets

    def print_widgets(self):
        print("Printing widgets for {}:".format(self.idn))
        pp = pprint.PrettyPrinter(indent=4)
        [pp.pprint(widget.idn + ":" + widget.idt) for widget in self.walk()]


class CFlay(FloatLayout):
    idn = StringProperty('')
    idt = StringProperty('')


class CLabel(Label):
    idn = StringProperty('')
    idt = StringProperty('')
    header_size = NumericProperty(52)
    block_size = NumericProperty(24)


class CInput(TextInput):
    idn = StringProperty('')
    idt = StringProperty('')


class CForm(CFlay):

    def get_common(self):
        result = {}
        w = self.find_widgets()
        result['date'] = w['picker'].get_date()
        result['sid'] = w['sid'].text
        result['t_type'] = w['t_type'].text
        if result['sid'] == 'Station ID':
            result['sid'] = -1
        if result['t_type'] == 'Time Type':
            result['t_type'] = -1

        return result

    def find_widgets(self):
        w = {}
        for widget in self.walk():
            try:
                if widget.idt == 'DatePicker':
                    w['picker'] = widget
                if widget.idn == 's_id':
                    w['sid'] = widget
                if widget.idn == 't_type':
                    w['t_type'] = widget
            except:
                continue
        return w


class PForm(CFlay):

    def get_values(self):
        d = {}
        for w in self.walk():
            try:
                if w.idn == 'p_lvl':
                    d['level'] = w.text
                    return d
            except:
                continue
        return -1


class WForm(CFlay):

    def get_values(self):
        d = {}
        for w in self.walk():
            try:
                if w.idn == 'pspd':
                    d['peak_speed'] = (w.text if len(w.text) > 0 else -1)
                elif w.idn == 'pdir':
                    d['peak_dir'] = (w.text if len(w.text) > 0 else -1)
                elif w.idn == 'aspd':
                    d['avg_speed'] = (w.text if len(w.text) > 0 else -1)
                elif w.idn == 'sspeed':
                    d['sust_speed'] = (w.text if len(w.text) > 0 else -1)
                elif w.idn == 'sdir':
                    d['sust_dir'] = (w.text if len(w.text) > 0 else -1)
            except:
                continue
        return d


class TForm(CFlay):
    def get_values(self):
        d = {}
        for w in self.walk():
            try:
                if w.idn == 'max':
                    d['max'] = w.text if len(w.text) > 0 else -1
                elif w.idn == 'min':
                    d['min'] = (w.text if len(w.text) > 0 else -1)
                elif w.idn == 'avg':
                    d['avg'] = (w.text if len(w.text) > 0 else -1)
            except:
                continue
        return d


class CSpinner(Spinner):
    idn = StringProperty('')
    idt = StringProperty('')

    def get_range(self, start, end):
        x = []
        for i in range(start, end+1):
            x.append(str(i))
        return tuple(x)


class DatePicker(CFlay):
    day = StringProperty('')
    month = StringProperty('')
    year = StringProperty('')

    def get_date(self):
        if self.day != '' and self.month != '' and self.year != '':
            return self.day + '/' + self.month + '/' + self.year
        return -1
