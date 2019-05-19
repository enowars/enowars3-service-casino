import requests
import json
import random
import string
from enochecker import BaseChecker, BrokenServiceException, run
from enochecker.utils import *

session = requests.Session()

class CasinoChecker(BaseChecker):

    with open('../service/casino/data/strings.json', 'r') as f:
        dictionary = json.load(f)

    port = 6969  # default port to send requests to.

    def putflag(self):
        t = self.connect()
        self.debug("connected to {}".format(self.address))
        readline_expect(t, "Entering...")
        readline_expect(t, self.dictionary["welcome"], read_until = self.dictionary["welcome"][-10:])
        if self.flag_idx == 0:
            #table-flag

            #change to games
            t.write("g")
            #readline_expect(t, self.dictionary["withdraw_0"], read_until = self.dictionary["withdraw_0"][-10])
            
            #change to black_jack
            t.write("black_jack")

            #create a new table
            t.write("c")
            t.write("1337")
            t.write("ENOawecopaiwjencao2983ncaownecaow=")
            t.write("1000000000")
            t.write("password")
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
