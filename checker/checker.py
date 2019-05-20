import requests
import json
import random
import string
import time
import os
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256
from Crypto.Cipher import AES
from enochecker import BaseChecker, BrokenServiceException, run
from enochecker.utils import *

session = requests.Session()

def bytes_arr_to_int_arr(bytes_arr):
    result = []
    for b in bytes_arr:
    	result.append(int.from_bytes([b], byteorder='big', signed=False))
    return result

def decrypt_aes(key, iv, enc_msg):
    #aesSuite = AES.new(key, AES.MODE_CTR, nonce=iv[:8], initial_value=iv[8:])
    #return aesSuite.decrypt(enc_msg)


    with open(".aes_msg_enc","w") as f:
        f.write(json.dumps([bytes_arr_to_int_arr(key), bytes_arr_to_int_arr(iv), bytes_arr_to_int_arr(enc_msg)]))

    #TODO: subprocess and stdout
    exit_code = os.system("julia aes_decryptor.jl")

    print(exit_code)
    if exit_code != 0:
        raise BrokenServiceException

    with open(".aes_msg", "r") as f:
        msg = json.loads(f.read())

    return bytes(msg).decode('utf-8').rstrip('\x00')


#TODO: change for use in the checker
def decode_crypto_msg(enc_msg_json):

    data = json.loads(enc_msg_json)

    #convert int list to bytes
    enc_msg_aes = bytes(data[0])
    iv = bytes(data[1])
    enc_aes_key = bytes(data[2])

    print("Encrypted AES msg:", enc_msg_aes)
    print("IV:", iv)
    print("Encrypted AES key:", enc_aes_key)

    #TODO: validate input
    aes_key = rsa_decode(enc_aes_key)

    decoded_msg = decrypt_aes(aes_key, iv, enc_msg_aes)

    return decoded_msg

def rsa_decode(enc_aes_key):
    with open("assets/private.pem") as aeskey_file:
    	key = RSA.import_key(aeskey_file.read(), passphrase="enowars")

    cipher_rsa = PKCS1_OAEP.new(key)
    #TODO: try - invalid input?
    enc_key_bytes = cipher_rsa.decrypt(enc_aes_key)

    return enc_key_bytes


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


    def intro(self, t):
        print(readline_expect(t, "Entering..."))
        print(readline_expect(t, self.dictionary["spacer"]))
        print(readline_expect(t, self.dictionary["welcome"], read_until = self.dictionary["welcome"][-10:] + "\n"))
        print(readline_expect(t, self.dictionary["spacer"]))
        print(readline_expect(t, "Your balance is: 0"))
        print(readline_expect(t, self.dictionary["reception_0"], read_until = self.dictionary["reception_0"][-10:] + "\n"))


    def goto_cryptomat(self, t):
        t.write("b\n")
        print(readline_expect(t, self.dictionary["reception_2"]))
        print(readline_expect(t, self.dictionary["spacer"]))
        readline_expect_multiline(t, self.dictionary["bathroom_0"], True)
        t.write("w\n")
        print(readline_expect(t, self.dictionary["bathroom_1"]))
        print(readline_expect(t, self.dictionary["bathroom_4"]))
        t.write("v\n")
        print(readline_expect(t, self.dictionary["spacer"]))
        readline_expect_multiline(t, self.dictionary["cryptomat_0"], True)

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
            self.goto_cryptomat(t)
            t.write("o\n")
            print(readline_expect(t, self.dictionary["cryptomat_os_update_1"]))
            t.write(rsa_sign_message(self.flag)+"\n")
            print(readline_expect(t, self.dictionary["cryptomat_os_update_accept_format"]))
            print(readline_expect(t, self.dictionary["cryptomat_os_update_accept_signature"]))
            print(readline_expect(t, "Updating...\n"))
            print(readline_expect(t, "Updated\n"))

        #TODO: better leaving
        t.close()

    def getflag(self):
        t = self.connect()
        self.debug("connected to {}".format(self.address))
        self.intro(t)

        if self. flag_idx == 0:
            pass
        elif self.flag_idx == 1:
            self.goto_cryptomat(t)
            #get note
            t.write("◈\n".encode("utf-8"))
            #retrieve correct dimension
            print(readline_expect(t, self.dictionary["cryptomat_3"]))
            r = t.read_until("\n")[:-1]
            notes = json.loads(r.decode('utf-8'))
            #TODO: adjust to round
            dimension = notes[0]
            #set dimension
            t.write("🕐\n".encode("utf-8"))
            t.write(str(dimension)+"\n")

            t.write("3\n")

            print(readline_expect(t, self.dictionary["cryptomat_sender_1"]))

            for i in range(0,3):
                print(readline_expect(t, "AES CTR:\n"))
                print(readline_expect(t, "Message:\n"))
                msg = t.read_until("\n")[:-1].decode('utf-8')

                decrypted_msg = decode_crypto_msg(msg)
                print("Decrypted message: ", decrypted_msg)
                if i == 0:
                    assert_equals(decrypted_msg , "ATOM-BOMB-CODE-START", autobyteify=True)
                elif i == 1:
                    assert_equals(decrypted_msg , self.flag, autobyteify=True)
                elif i == 2:

                    assert_equals(decrypted_msg , "ATOM-BOMB-CODE-END", autobyteify=True)

        #todo: better leaving
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
