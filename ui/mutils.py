from kivy.lang import Builder
from kivy.config import Config
from kivy.core.window import Window
import os


def load_resources():
    Builder.load_file('kv_files/custom_widgets.kv')
    Builder.load_file('kv_files/main.kv')
    Builder.load_file('kv_files/screens/*.kv')
    dir_path = os.path.dirname(os.path.realpath(__file__))
    kv_path = os.path.join(dir_path, 'kv_files')
    screens = os.path.join(kv_path, 'screens')


def set_config(width=1280, height=800, resizable=False):
    # Set the size of the window to the touchscreen resolution and lock size
    Window.size = width, height
    Window.borderless = True
    Window.top = 0
    Window.left = 0

    # Set the keyboard mode
    # TODO: Currently Not In Use
    Config.set('kivy', 'keyboard_mode', 'dock')
