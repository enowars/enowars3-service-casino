import requests
import json
import random
import string
from enochecker import BaseChecker, BrokenServiceException, run

session = requests.Session()


class CasinoChecker(BaseChecker):

    port = 6969  # default port to send requests to.

    def putflag(self):
        t = self.connect()
        self.debug("connected to {}".format(self.address))
        
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
    run(CasninoChecker)
