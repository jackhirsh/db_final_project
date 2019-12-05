from kivy.properties import NumericProperty, StringProperty, DictProperty, ListProperty
from kivy.uix.button import Button
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.uix.image import Image
from kivy.uix.spinner import Spinner
from kivy.uix.textinput import TextInput
from kivy.utils import get_color_from_hex
from kivy.app import App
import datetime

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

    def get_station_list(self):
        stations = App.get_running_app().get_stations()
        print("Stations: {}".format(stations))
        return stations


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
            return self.year + '-' + self.month + '-' + self.day
        return -1


class PRow(CFlay):
    date = StringProperty('')
    sid = StringProperty('')  # Station id
    ttype = StringProperty('')
    rid = StringProperty('')  # Reading id
    sname = StringProperty('')
    level = StringProperty('')
    elements = {}
    created = False
    font = None

    def __init__(self, dirty, font, **kwargs):
        super(CFlay, self).__init__(**kwargs)
        self.rid = str(dirty[0])
        self.ttype = str(dirty[7])
        self.level = str(dirty[5])
        self.sid = str(dirty[9])
        self.sname = str(dirty[10])
        # Format the date
        ddate = dirty[8]
        form_date = str(ddate.year) + '-' + \
            str(ddate.month) + '-' + str(ddate.day)
        self.date = str(form_date)
        self.font = font
        self.populate_elements()

    def populate_elements(self):
        self.elements['rid'] = (self.create_label(self.rid))
        self.elements['date'] = (self.create_label(self.date))
        self.elements['ttype'] = self.create_label(self.ttype)
        self.elements['sid'] = (self.create_label(self.sid))
        self.elements['sname'] = (self.create_label(self.sname))
        self.elements['level'] = (self.create_label(self.level))

    def create_label(self, text):
        lab = CLabel(text=text)
        lab.font_size = self.font
        return lab

    def create_self(self):
        n = 0
        if self.created:
            return False
        for key in self.elements:
            widg = self.elements[key]
            self.add_widget(widg)
            self.elements[key].size_hint = 1 / (len(self.elements) * 1.5), 1
            spacer = 1 / len(self.elements)
            self.elements[key].pos_hint = {'center_x': (spacer/2)+(spacer*n),
                                           'center_y': .5}

            n += 1
        self.created = True


class WRow(CFlay):
    date = StringProperty('')
    sid = StringProperty('')  # Station id
    ttype = StringProperty('')
    rid = StringProperty('')  # Reading id
    sname = StringProperty('')
    pspd = StringProperty('')
    pdir = StringProperty('')
    aspd = StringProperty('')
    sspd = StringProperty('')
    sdir = StringProperty('')
    elements = {}
    created = False
    font = None

    def __init__(self, dirty, font, **kwargs):
        super(CFlay, self).__init__(**kwargs)
        self.rid = str(dirty[0])
        # Format the date
        ddate = dirty[12]
        form_date = str(ddate.year) + '-' + \
            str(ddate.month) + '-' + str(ddate.day)
        self.date = str(form_date)
        self.pspd = str(dirty[5])
        self.pdir = str(dirty[6])
        self.sspd = str(dirty[7])
        self.sdir = str(dirty[8])
        self.aspd = str(dirty[9])
        self.ttype = str(dirty[11])
        self.sid = str(dirty[13])
        self.sname = str(dirty[14])

        self.font = font
        self.populate_elements()

    def populate_elements(self):
        self.elements['rid'] = (self.create_label(self.rid))
        self.elements['date'] = (self.create_label(self.date))
        self.elements['sid'] = (self.create_label(self.sid))
        self.elements['sname'] = (self.create_label(self.sname))
        self.elements['ttype'] = self.create_label(self.ttype)
        self.elements['peak_speed'] = self.create_label(self.pspd)
        self.elements['peak_dir'] = self.create_label(self.pdir)
        self.elements['avg_speed'] = self.create_label(self.aspd)
        self.elements['sust_speed'] = self.create_label(self.sspd)
        self.elements['sust_dir'] = self.create_label(self.sdir)

    def create_label(self, text):
        lab = CLabel(text=text)
        lab.font_size = self.font
        return lab

    def create_self(self):
        n = 0
        if self.created:
            return False
        for key in self.elements:
            print("doing: {}".format(key))
            widg = self.elements[key]
            self.add_widget(widg)
            self.elements[key].size_hint = 1 / (len(self.elements) * 1.5), 1
            spacer = 1 / len(self.elements)
            self.elements[key].pos_hint = {'center_x': (spacer/2)+(spacer*n),
                                           'center_y': .5}

            n += 1
        self.created = True


class TRow(CFlay):
    date = StringProperty('')
    sid = StringProperty('')  # Station id
    ttype = StringProperty('')
    rid = StringProperty('')  # Reading id
    sname = StringProperty('')
    _max = StringProperty('')
    _min = StringProperty('')
    _avg = StringProperty('')
    elements = {}
    created = False
    font = None

    def __init__(self, dirty, font, **kwargs):
        super(CFlay, self).__init__(**kwargs)
        self.rid = str(dirty[1])
        ddate = dirty[10]
        form_date = str(ddate.year) + '-' + \
            str(ddate.month) + '-' + str(ddate.day)
        self.date = form_date
        self.ttype = str(dirty[9])
        self.sname = str(dirty[12])
        self.sid = str(dirty[2])
        self._max = str(dirty[5])
        self._min = str(dirty[6])
        self._avg = str(dirty[7])
        self.font = font
        self.populate_elements()

    def populate_elements(self):
        self.elements['rid'] = (self.create_label(self.rid))
        self.elements['date'] = (self.create_label(self.date))
        self.elements['sid'] = (self.create_label(self.sid))
        self.elements['sname'] = (self.create_label(self.sname))
        self.elements['ttype'] = self.create_label(self.ttype)
        self.elements['max'] = self.create_label(self._max)
        self.elements['min'] = self.create_label(self._min)
        self.elements['avg'] = self.create_label(self._avg)

    def create_label(self, text):
        lab = CLabel(text=text)
        lab.font_size = self.font
        return lab

    def create_self(self):
        n = 0
        if self.created:
            return False
        for key in self.elements:
            print("doing: {}".format(key))
            widg = self.elements[key]
            self.add_widget(widg)
            self.elements[key].size_hint = 1 / (len(self.elements) * 1.5), 1
            spacer = 1 / len(self.elements)
            self.elements[key].pos_hint = {'center_x': (spacer/2)+(spacer*n),
                                           'center_y': .5}

            n += 1
        self.created = True


class HRow(CFlay):
    elements = []
    created = False
    font = None

    def __init__(self, items, font, **kwargs):
        super(CFlay, self).__init__(**kwargs)
        self.font = font
        self.populate_elements(items)

    def populate_elements(self, items):
        for i in range(0, len(items)):
            print(items[i])
            label = self.create_label(items[i])
            self.elements.append(label)

    def create_label(self, text):
        lab = CLabel(text=text)
        lab.font_size = self.font
        return lab

    def create_self(self):
        n = 0
        if self.created:
            return False
        for widg in self.elements:
            print("doing: {}".format(widg))
            self.remove_widget(widg)
            # self.add_widget(widg)
            widg.size_hint = 1 / (len(self.elements) * 1.5), 1
            spacer = 1 / len(self.elements)
            widg.pos_hint = {'center_x': (spacer/2)+(spacer*n),
                             'center_y': .5}

            n += 1
        self.created = True


class DataViewer(CFlay):
    p = []  # Rows of precip data
    w = []  # Rows of wind data
    t = []  # Rows of temp data
    p_h = None
    w_h = None
    t_h = None

    created = None
    h_created = None
    active_l = 0
    reach = 6
    ftype = None

    def __init__(self, **kwargs):
        super(CFlay, self).__init__(**kwargs)
        self.created = False
        self.h_created = False
        self.create_rows()

    def create_headers(self):
        if not self.h_created:
            p_items = ['Reading ID', 'Date', 'TType', "SID", 'Sname', 'Level']
            self.p_h = HRow(p_items, 13)
            self.add_widget(self.p_h)
            self.p_h.create_self()
            self.p_h.pos_hint = {'x': 1, 'y': 1}

            w_items = ['Reading ID', 'Date', "SID", 'Sname',  'TType', 'Pk Spd',
                       'Pk Dir', 'Avg Spd', 'Sust Spd', 'Sust Dir']
            self.w_h = HRow(w_items, 13)
            self.add_widget(self.w_h)
            self.w_h.create_self()
            self.w_h.pos_hint = {'x': 1, 'y': 1}

            t_items = ['Reading ID', 'Date', "SID", 'Sname',
                       'TType', 'Level', 'Max', 'Min', 'Avg']
            self.t_h = HRow(t_items, 13)
            self.add_widget(self.t_h)
            self.t_h.create_self()
            self.t_h.pos_hint = {'x': 1, 'y': 1}
            self.h_created = True

    def create_rows(self):
        if not self.created:
            n = 0
            dirtyp = App.get_running_app().print_all('p')
            if dirtyp:
                for row in dirtyp:
                    widg = PRow(row, 13)
                    self.p.append(widg)
                    self.add_widget(widg)
                    widg.create_self()
                    widg.pos_hint = {'x': 1, 'y': 1}
                n += 1

            dirtyw = App.get_running_app().print_all('w')
            if dirtyw:
                for row in dirtyw:
                    widg = WRow(row, 13)
                    self.w.append(widg)
                    self.add_widget(widg)
                    widg.create_self()
                    widg.pos_hint = {'x': 1, 'y': 1}
                n += 1

            dirtyt = App.get_running_app().print_all('t')
            if dirtyt:
                for row in dirtyt:
                    widg = TRow(row, 13)
                    self.t.append(widg)
                    self.add_widget(widg)
                    widg.create_self()
                    widg.pos_hint = {'x': 1, 'y': 1}
                n += 1

            if n == 3:
                self.created = True

    def display_rows(self, ftype):
        self.create_headers()
        self.ftype = ftype
        if self.h_created:
            self.p_h.pos_hint = {'center_x': 10, 'center_y': 10}
            self.w_h.pos_hint = {'center_x': 10, 'center_y': 10}
            self.t_h.pos_hint = {'center_x': 10, 'center_y': 10}
        for widg in self.walk():
            try:
                if widg.idt == 'PRow' or widg.idt == 'WRow' or widg.idt == 'TRow':
                    widg.pos_hint = {'x': 1, 'y': 1}
            except:
                continue
        n = 0
        if not self.created:
            self.create_rows()
        print('In DisplayRows')
        cur = None
        if ftype == '':
            return
        elif ftype == 'p':
            self.p_h.pos_hint = {'center_x': .5, 'center_y': .9}
            cur = self.p
        elif ftype == 'w':
            self.p_h.pos_hint = {'center_x': .5, 'center_y': .9}
            cur = self.w
        elif ftype == 't':
            cur = self.t
        if cur is None:
            return
        i = 0
        for n in range(self.active_l, self.active_l + self.reach):
            if n > len(cur) - 1:
                break
            row = cur[n]
            print("i = {}".format(i))
            row.pos_hint = {'center_x': .5, 'center_y': 1 - .1*i}
            row.size_hint = 1, .5
            i += 1

    def get_cur(self, i):
        cur = None
        if self.ftype == '':
            return None
        elif self.ftype == 'p':
            cur = self.p
        elif self.ftype == 'w':
            cur = self.w
        elif self.ftype == 't':
            cur = self.t
        if i + self.active_l >= len(cur):
            return None
        return cur[i+self.active_l]

    def delete(self, i):
        if i == 'Select Result':
            return
        i = int(i) - 1

        val = self.get_cur(i)
        if val is None:
            return
        App.get_running_app().delete(val.rid)

    def update(self, field, new_val, i):
        if i == 'Select Result':
            return
        i = int(i) - 1
        if field == 'Edit Field':
            return
        field = int(field)
        if new_val == '':
            return
        cur = self.get_cur(i)
        if cur is None:
            return
        print('Here')
        fn = App.get_running_app().update
        if self.ftype == 'p' and field == 6:
            fn(cur.rid, 1, new_val)
        elif self.ftype == 'w':
            # def update(self, idn, field_no, new_val):
            if field == 6:  # PK Spd Case
                fn(cur.rid, 1, new_val)
            elif field == 7:  # Pk Dir Case
                fn(cur.rid, 2, new_val)
            elif field == 8:  # Avg Spd Case
                fn(cur.rid, 3, new_val)
            elif field == 9:  # Sust Spd Case
                fn(cur.rid, 4, new_val)
            elif field == 10:  # Sust Dir Case
                fn(cur.rid, 5, new_val)
        elif self.ftype == 't':
            if field == 6:  # Max Case
                fn(cur.rid, 1, new_val)
            elif field == 7:  # Min Case
                fn(cur.rid, 2, new_val)
            elif field == 8:  # Avg Case
                fn(cur.rid, 3, new_val)
