from src import db_manager as dbm
from getpass import getpass, getuser

class App:
    manager = None
    def __init__(self, **kwargs):
        self.manager = dbm.DBManager()

    def start(self):
        print("Welcome to the Climate Database Access Tool")
        self.get_user_login()

    def basic_prompt(self):
        pass

    def get_user_login(self):
        user = input("Username: ")
        password = getpass(prompt='Password: ', stream=None)
        self.manager.set_login(user, password)
        try:
            self.manager.create_connection()
        except:
            print("CONNECTION FAILED - Try Again?")
            response = input("[Yes/y Or No/n]: ")
            response = response.lower()
            if response == 'y' or response == 'yes':
                self.get_user_login()
            else:
                exit(RuntimeError("Unable to connect to database"))