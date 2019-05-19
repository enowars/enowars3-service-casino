import requests
import json
import random
import string
import time
from enochecker import BaseChecker, BrokenServiceException, run
from enochecker.utils import *

session = requests.Session()

def generate_random_string(length = 3):
    alphabet = string.ascii_letters + string.digits
    return ''.join(random.choice(alphabet) for i in range(length))

class CasinoChecker(BaseChecker):

    with open('../service/casino/data/strings.json', 'r') as f:
        dictionary = json.load(f)

    port = 6969  # default port to send requests to.

    def putflag(self):
        t = self.connect()
        self.debug("connected to {}".format(self.address))
        print(readline_expect(t, "Entering..."))
        print(readline_expect(t, self.dictionary["spacer"]))
        print(readline_expect(t, self.dictionary["welcome"], read_until = self.dictionary["welcome"][-10:] + "\n"))
        print(readline_expect(t, self.dictionary["spacer"]))
        print(readline_expect(t, "Your balance is: 0"))
        print(readline_expect(t, self.dictionary["reception_0"], read_until = self.dictionary["reception_0"][-10:] + "\n"))
        if self.flag_idx == 0:
            #table-flag

            #change to games
            t.write("g\n")
            print(readline_expect(t, self.dictionary["spacer"]))
            print(readline_expect(t, self.dictionary["gamble_0"], read_until = self.dictionary["gamble_0"][-10:] + "\n"))
            print(readline_expect(t, "black_jack\nslot_machine\nroulette", read_until = "roulette\n"))
            print(readline_expect(t, self.dictionary["gamble_1"], read_until = self.dictionary["gamble_1"][-10:] + "\n"))
            #change to black_jack
            t.write("black_jack\n")
            print(readline_expect(t, self.dictionary["spacer"]))
            print(readline_expect(t, self.dictionary["table_0"], read_until = self.dictionary["table_0"][-10:] + "\n"))
            #create a new table
            t.write("c\n")
            print(readline_expect(t, self.dictionary["table_12"], read_until = self.dictionary["table_12"][-10:] + "\n"))
            t.write(generate_random_string(10) + "\n")
            print(readline_expect(t, self.dictionary["table_6"], read_until = self.dictionary["table_6"][-10:] + "\n"))
            t.write(self.flag + "\n")
            print(readline_expect(t, self.dictionary["table_8"], read_until = self.dictionary["table_8"][-10:] + "\n"))
            t.write("1000000000\n")
            print(readline_expect(t, self.dictionary["table_10"], read_until = self.dictionary["table_10"][-10:] + "\n"))
            t.write(generate_random_string(20) + "\n")
            print(readline_expect(t, self.dictionary["table_15"], read_until = self.dictionary["table_15"][-10:] + "\n"))
        elif self.flag_idx == 1:
            #cryptomat-flag
            pass

    def getflag(self):
        pass

    def putnoise(self):
        pass

    def getnoise(self):
        pass

    def havoc(self):
        pass


app = CasinoChecker.service
if __name__ == "__main__":
    run(CasinoChecker)
