from kivy.uix.screenmanager import Screen, ScreenManager, SlideTransition
from kivy.properties import StringProperty
from kivy.app import App
from kivy.clock import Clock
from ui.custom_widgets import CScreen, PForm, TForm, WForm

IGNORELOGIN = True


class MainMenuScreen(CScreen):
    pass


class LoginScreen(CScreen):
    user = StringProperty('')
    password = StringProperty('')

    failed_label = None

    def find_fail(self):
        for w in self.walk():
            try:
                if w.idn == "failure_label":
                    self.failed_label = w
                    break
            except:
                continue

    def we_failed(self):
        if self.failed_label is None:
            self.find_fail()
        self.failed_label.size_hint = (.8, .2)
        self.failed_label.pos_hint = {"center_x": .5, "center_y": .125}
        Clock.schedule_once(lambda dt: self.clear_failed(), 8)

    def clear_failed(self):
        self.failed_label.size_hint = (0, 0)
        self.failed_label.pos_hint = {'x': 0, 'y': 1}

    def attempt_login(self):
        result = self.callbacks['login'](self.user, self.password)
        if not result:
            self.we_failed()
        else:
            self.callbacks['switch']('main_menu')
        if IGNORELOGIN:
            Clock.schedule_once(
                lambda dt: self.callbacks['switch']('main_menu'), 1)

        return result


class CreateScreen(CScreen):
    p_form = None
    w_form = None
    t_form = None
    l_form = None

    def __init__(self, callbacks, **kwargs):
        super(CreateScreen, self,).__init__(callbacks, **kwargs)
        self.create_forms()

    def get_common(self):
        w = None
        for widget in self.walk():
            try:
                if widget.idn == 'common_form':
                    w = widget
                    break
            except:
                continue
        return w.get_common()

    def get_form(self):
        values = self.l_form.get_values()
        common = self.get_common()
        d = {'val': values, 'common': common}
        return d

    def set_form_type(self, ftype):
        # Remove the last form
        if self.l_form != None:
            self.remove_widget(self.l_form)

        if ftype == 'Precipitation':
            print('P form')
            self.add_widget(self.p_form)
            self.l_form = self.p_form
        elif ftype == 'Wind':
            print('W form')
            self.add_widget(self.w_form)
            self.l_form = self.w_form
        elif ftype == 'Temperature':
            print('T form')
            self.add_widget(self.t_form)
            self.l_form = self.t_form

        self.l_form.size_hint = 1, .45
        self.l_form.pos_hint = {'center_x': .5, 'center_y': .325}

    def create_forms(self):
        self.p_form = PForm()
        self.w_form = WForm()
        self.t_form = TForm()

    def validate_data(self):
        form = self.get_form()
        val = form['val']
        com = form['common']
        ftype = None
        for key in val:
            if key == 'level':
                ftype = 'p'
                break
            elif key == 'peak_speed':
                ftype = 'w'
                break
            elif key == 'max':
                ftype = 't'
                break
        for key in val:
            if val[key] == -1:
                return False
        for key in com:
            if com[key] == -1:
                return False
        return ftype, form

    def submit_command(self):
        if not self.validate_data():
            print("Must fill out full form")
            return False
        ftype, form = self.validate_data()
        val = form['val']
        com = form['common']
        procedure = None
        date = com['date']
        sid = com['sid']
        t_type = com['t_type']
        if ftype == 'p':
            level = val['level']
            procedure = "CALL add_precipitation_read('{}', '{}', {}, {})".format(
                date, t_type.lower(), sid, level)
        elif ftype == 'w':
            ps = val['peak_speed']
            pd = val['peak_dir']
            asp = val['avg_speed']
            ss = val['sust_speed']
            sd = val['sust_dir']
            procedure = "CALL add_wind_read('{}', '{}', {}, {}, {}, {}, {}, {})".format(
                date, t_type.lower(), sid, ps, pd, ss, sd, asp
            )
        elif ftype == 't':
            mx = val['max']
            mn = val['min']
            avg = val['avg']
            procedure = "CALL add_temperature_read('{}', '{}', {}, {}, {}, {})".format(
                date, t_type.lower(), sid, mx, mn, avg
            )
        App.get_running_app().call_procedure(procedure)


class MainManager(ScreenManager):
    '''
    Class responsible for managing the screens of the game and swapping
    between them as needed
    '''
    wds = {}  # Dictionary of registered screens
    dbm = None
    r_app = None

    def __init__(self, **kwargs):
        # Initialize the super class
        ScreenManager.__init__(self)

        # Store the running app for easy access from this level
        self.r_app = App.get_running_app()

        # Set the visual transition for the screens, I just like this one
        self.transition = SlideTransition(direction='up')

        # Initialize the screens and pass them some useful callbacks to have
        # access to internally
        self.add_screen('login', LoginScreen(
            {
                'login': self.login_to_db,
                'switch': self.select_screen}))
        self.add_screen('main_menu', MainMenuScreen(
            {
                'switch': self.select_screen}))
        self.add_screen('create', CreateScreen(
            {
                'switch': self.select_screen}))

        # Start the app on the login screen
        self.select_screen('login')

    def add_screen(self, name, scr):
        '''
        Adds a new screen to the custom screenmanager
        '''
        self.wds[name] = scr
        scr.name = name
        self.add_widget(scr)

    def select_screen(self, name):
        '''
        Selects the current screen
        '''
        self.current = name

    def login_to_db(self, user, password):
        '''
        Attempts a login to the database
        '''
        print("Login attempted:")
        print("Username: {}".format(user))
        print("Password: {}".format(password))
        return self.r_app.attempt_db_login(user=user, password=password)
