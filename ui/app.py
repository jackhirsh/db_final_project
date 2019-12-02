from kivy.app import App
from ui.screen_manager import MainManager
from ui.mutils import load_resources
from src import db_manager
from kivy.config import Config
Config.set('input', 'mouse', 'mouse,multitouch_on_demand')
load_resources()


class ClimateApp(App):
    dbm = None

    # Create the app for our specific case "Piano App"
    def __init__(self, **kwargs):
        App.__init__(self)

        # Initialize the screen manager
        self.dbm = db_manager.DBManager()
        self.manager = MainManager()

    def build(self):
        return self.manager

    def attempt_db_login(self, user, password, host='localhost', db='climate'):
        '''
        Attempts to establish a connection to the database, returns True if 
        connection created, false if an error was encountered
        '''
        self.dbm.set_login(user=user, password=password, host=host, db=db)
        return self.dbm.create_connection()

    def get_stations(self):
        return ('1', '2', '3', '42')
