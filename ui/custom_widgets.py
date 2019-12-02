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

    def get_stations(self):
        # TODO don't hardcode this
        return [1, 2, 3, 4]


class CSpinner(Spinner):
    idn = StringProperty('')
    idt = StringProperty('')

    def get_range(self, start, end):
        x = []
        for i in range(start, end+1):
            x.append(str(i))
        return tuple(x)
