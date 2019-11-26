from src import db_manager as dbm
from getpass import getpass, getuser

help_list = {
    "quit or exit:": "Exits the program",
    "Weather Measurement Types:" : "p=precipitation --- t=temperature --- w=wind",
    "Date Format:": "year-month-day EX: december 22th 2019 -> 2019-12-22",
    "printAll(weatherType):": "Prints all items of a given weather type",
    "printRange(weatherType, startDate, endDate)": "Prints all items of given weather type in date range",
    "addReading(date, station, lvl)": "Adds a precipitation reading to the database"
}

weather_type = {
    "p":"precipitation",
    "w":"wind",
    "t":"temperature",
    "precipitation":"precipitation",
    "wind":"wind",
    "temperature":"temperature"
}

class App:
    manager = None
    def __init__(self, **kwargs):
        self.manager = dbm.DBManager()

    def start(self):
        print("Welcome to the Climate Database Access Tool")
        self.get_user_login()
        print("Login Succesful, command stream active(try help if you're lost)...")
        while True:
            self.basic_prompt()

    def basic_prompt(self):
        command = input()
        command = command.lower()
        if command == "help":
            self.print_help()
        elif command == "quit" or command == "exit":
            exit("User exited program")
        elif "printall" in command:
            arg_start = command.find("printall(") + len("printall(")
            arg = command[arg_start:command.find(")")]
            if arg in weather_type:
                self.manager.print_all_info(weather_type[arg])
            else:
                print("Invalid argument")
        elif "addreading" in command:
            print("adding reading")
            arg_start = command.find("addReading(") + len("addReading(")
            arg_set = command[arg_start:command.find(")")]
            args = self.get_args(arg_set)
            if len(args) != 3:
                print("Incorrect number of arguments")
            else:
                try:
                    

    def get_args(self, arg_set):
        # Feed this an arg set (arg, arg, arg, arg,...) and it will return a list of args
        un_parsed = arg_set.strip('()').lower().replace(' ', '')
        args = []
        print(un_parsed)
        while len(un_parsed) > 0:
            comma = un_parsed.find(',')
            if comma == -1:
                c_arg = un_parsed[0:]
                args.append(c_arg)
                un_parsed = ''
                break
            c_arg = un_parsed[0:comma]
            args.append(c_arg)
            un_parsed = un_parsed[comma+1:len(un_parsed)]
            print(un_parsed)
        return args

    def print_help(self):
        print("Help Menu ---------")
        for key in help_list:
            print(key)
            print("\t" + help_list[key])

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