import requests
import json
import random
import string
import time
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256
from enochecker import BaseChecker, BrokenServiceException, run
from enochecker.utils import *

session = requests.Session()

#TODO: change for use in the checker
def rsa_decoder(enc_msg_json):
    with open("assets/private.pem") as aeskey_file:
    	key = RSA.import_key(aeskey_file.read(), passphrase="enowars")

    data = json.load(enc_msg_json)

    print("Data:" , data)
    #convert int list to bytes
    enc_msg_aes = bytes(data[0])
    enc_aes_key = bytes(data[1])

    cipher_rsa = PKCS1_OAEP.new(key)
    enc_key_bytes = cipher_rsa.decrypt(enc_aes_key)
    #TODO:

    enc_key_list = []
    #convert back to int list

    for b in enc_key_bytes:
    	enc_key_list.append(int.from_bytes([b], byteorder='big', signed=False))

    print(enc_key_list)

def rsa_sign_message(msg):
    with open("assets/private.pem") as aeskey_file:
    	key = RSA.import_key(aeskey_file.read(), passphrase="enowars")

    msg_bytes = bytearray()
    msg_bytes.extend(map(ord, msg))
    hash = SHA256.new(msg_bytes)
    signature = pkcs1_15.new(key).sign(hash)

    hash_list = []
    #convert back to int list

    for b in signature:

        hash_list.append(int.from_bytes([b], byteorder='big', signed=False))
    #print(enc_key_list)
    return json.dumps([msg,hash_list])

def readline_expect_multiline(telnet_session, msg, pls_print=False):
    for m in msg.split('\n'):
        if print:
            print(readline_expect(telnet_session, m))
        else:
            readline_expect(telnet_session, m)


def generate_random_string(length = 3):
    alphabet = string.ascii_letters + string.digits
    return ''.join(random.choice(alphabet) for i in range(length))



class CasinoChecker(BaseChecker):
    debug = True

    def intro(self, t):
        readline_expect_multiline(t, "Entering...", self.debug)
        readline_expect_multiline(t, self.dictionary["spacer"], self.debug)
        readline_expect_multiline(t, self.dictionary["welcome"], self.debug)
        readline_expect_multiline(t, self.dictionary["spacer"], self.debug)
        readline_expect_multiline(t, "Your balance is: 0", self.debug)
        readline_expect_multiline(t, self.dictionary["reception_0"], self.debug)


    def goto_cryptomat(self, t):
        t.write("b\n")
        readline_expect_multiline(t, self.dictionary["reception_2"], self.debug)
        readline_expect_multiline(t, self.dictionary["spacer"], self.debug)
        readline_expect_multiline(t, self.dictionary["bathroom_0"], self.debug)
        t.write("w\n")
        readline_expect_multiline(t, self.dictionary["bathroom_1"], self.debug)
        readline_expect_multiline(t, self.dictionary["bathroom_4"], self.debug)
        t.write("v\n")
        readline_expect_multiline(t, self.dictionary["spacer"], self.debug)
        readline_expect_multiline(t, self.dictionary["cryptomat_0"], self.debug)

    def goto_games(self, t):
        t.write("g\n")
        readline_expect_multiline(t, self.dictionary["spacer"], self.debug)
        readline_expect_multiline(t, self.dictionary["gamble_0"], self.debug)
        readline_expect_multiline(t, "black_jack\nslot_machine\nroulette", self.debug)
        readline_expect_multiline(t, self.dictionary["gamble_1"], self.debug)
        
    def insert_table_flag(self, t):
        identifier = generate_random_string(10)
        minimum = "1000000000"
        passphrase = generate_random_string(20)

        t.write("c\n")
        readline_expect_multiline(t, self.dictionary["table_12"], self.debug)
        t.write(identifier + "\n")
        readline_expect_multiline(t, self.dictionary["table_6"], self.debug)
        t.write(self.flag + "\n")
        readline_expect_multiline(t, self.dictionary["table_8"], self.debug)
        t.write(minimum + "\n")
        readline_expect_multiline(t, self.dictionary["table_10"], self.debug)
        t.write(passphrase + "\n")
        readline_expect_multiline(t, self.dictionary["table_15"], self.debug)

        self.team_db[self.flag] = (identifier, minimum, passphrase)
    
    with open('../service/casino/data/strings.json', 'r') as f:
        dictionary = json.load(f)

    port = 6969  # default port to send requests to.

    def putflag(self):
        t = self.connect()
        self.debug("connected to {}".format(self.address))
        self.intro(t)

        if self.flag_idx == 0:
            #table-flag

            #change to games
            self.goto_games(t)
            
            #change to black_jack
            t.write("black_jack\n")
            readline_expect_multiline(t, self.dictionary["spacer"], self.debug)
            readline_expect_multiline(t, self.dictionary["table_0"], self.debug)
            
            #create a new table
            self.insert_table_flag(t)
            
        elif self.flag_idx == 1:
            #cryptomat-flag
            self.goto_cryptomat(t)
            t.write("o\n")
            readline_expect_multiline(t, self.dictionary["cryptomat_os_update_1"], self.debug)
            t.write(rsa_sign_message(self.flag)+"\n")
            readline_expect_multiline(t, self.dictionary["cryptomat_os_update_accept_format"], self.debug)
            readline_expect_multiline(t, self.dictionary["cryptomat_os_update_accept_signature"], self.debug)
            readline_expect_multiline(t, "Updating...\n", self.debug)
            readline_expect_multiline(t, "Updated\n", self.debug)


        t.close()

    def getflag(self):
        t = self.connect()
        self.debug("connected to {}".format(self.address))
        self.intro(t)

        if self. flag_idx == 0:
            #change to games
            self.goto_games(t)
            
            #change to black_jack
            t.write("black_jack\n")
            readline_expect_multiline(t, self.dictionary["spacer"], self.debug)
            readline_expect_multiline(t, self.dictionary["table_0"], self.debug)
            
            #join a table
            t.write("j\n")
            #readline_expect_multiline(t, self.dictionary[])
            identifier, minimum, passphrase = self.team_db[self.flag]
            pass
        elif self.flag_idx == 1:
            self.goto_cryptomat(t)
            t.write("")

        t.close()


    def putnoise(self):
        pass

    def getnoise(self):
        pass

    def havoc(self):
        pass


app = CasinoChecker.service
if __name__ == "__main__":
    run(CasinoChecker)
