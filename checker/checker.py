# -*- coding: utf-8 -*-

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

#session = requests.Session()

def bytes_arr_to_int_arr(bytes_arr):
    result = []
    for b in bytes_arr:
        result.append(int.from_bytes([b], byteorder='big', signed=False))
    return result




def generate_random_string(length = 3):
    alphabet = string.ascii_letters + string.digits
    return ''.join(random.choice(alphabet) for i in range(length))



class CasinoChecker(BaseChecker):
    debug_print = True
    flag_count = 2
    noise_count = 0
    havoc_count = 0

    def put_crypto(self, t, mode):
        self.debug("Putflag - Cryptomat")

        #cryptomat-flag
        self.debug("Going to Cryptomat")
        self.goto_cryptomat(t)
        t.write("o\n")
        self.readline_expect_multiline(t, string_dictionary["cryptomat_os_update_mode"])
        if(mode == "OFB"):
            t.write("💣\n".encode("utf-8"))
        elif(mode == "CBC"):
            t.write("🧀\n".encode("utf-8"))

        self.readline_expect_multiline(t, string_dictionary["cryptomat_os_update_1"])
        try:
            t.write(self.rsa_sign_message(self.flag)+"\n")
        except:
            raise BrokenServiceException("rsa error")
        self.readline_expect_multiline(t, string_dictionary["cryptomat_os_update_accept_format"])
        self.readline_expect_multiline(t, string_dictionary["cryptomat_os_update_accept_signature"])
        self.readline_expect_multiline(t, "Updating...")
        self.readline_expect_multiline(t, "Updated")


    def get_crypto(self, t, mode):
        self.goto_cryptomat(t)
        #get note
        t.write("◈\n".encode("utf-8"))
        #retrieve correct dimension
        self.readline_expect_multiline(t, string_dictionary["cryptomat_3"])
        r = t.read_until("\n")[:-1]
        try:
            self.debug("Starting to work on the found notes")
            self.debug("Trying to load notes as JSON")
            notes = json.loads(r.decode('utf-8'))
            self.debug("Notes successfully loaded as JSON")
            #TODO: adjust to round

            difference = self.round - self.flag_round
            self.debug("Difference between roung and flag_round is:" + str(difference))

            dimension = notes[difference]
            self.debug("Flag dimension: " + str(dimension))
        except Exception as e:
            self.debug(e)
            raise BrokenServiceException("Notes Error")
        #set dimension
        t.write("🕐\n".encode("utf-8"))
        self.debug("Setting dimension: " + str(dimension))
        t.write(str(dimension)+"\n")

        self.debug("Dimension set(?). Starting AES-" + mode)
        if(mode == "OFB"):
            mode_nr = "3"
        elif(mode == "CBC"):
            mode_nr = "1"
        t.write(mode_nr+"\n")

        self.readline_expect_multiline(t, string_dictionary["cryptomat_sender_1"])
        self.debug("Starting to work on AES messages")
        for i in range(0,3):
            self.debug("AES message Nr: " + str(i))
            #self.readline_expect_multiline(t, "AES CTR:")
            self.readline_expect_multiline(t, "Message:")
            self.debug("Starting to read AES message")
            msg = t.read_until("\n")[:-1].decode('utf-8')
            self.debug(msg)

            try:
                decrypted_msg = self.decode_crypto_msg(msg, mode="OFB")
            except Exception as e:
                self.debug(e)
                raise BrokenServiceException("decrypting of message failed")
                print("Decrypted message: ", decrypted_msg)
            if i == 0:
                assert_equals(decrypted_msg , "ATOM-BOMB-CODE-START", autobyteify=True)
            elif i == 1:
                assert_equals(decrypted_msg , self.flag, autobyteify=True)
            elif i == 2:
                assert_equals(decrypted_msg , "ATOM-BOMB-CODE-END", autobyteify=True)


    def decrypt_aes(self, key, iv, enc_msg, mode):
        #aesSuite = AES.new(key, AES.MODE_CTR, nonce=iv[:8], initial_value=iv[8:])
        #return aesSuite.decrypt(enc_msg)

        if(mode=="OFB"):
            cipher = AES.new(key, AES.MODE_OFB, iv=iv)
            msg=cipher.decrypt(enc_msg)
        elif(mode=="CBC"):
            pass
            #TODO
        else:
            print("Invalid mode")

        return msg.decode('utf-8').rstrip('\x00')


    #TODO: change for use in the checker
    def decode_crypto_msg(self, enc_msg_json, mode="ofb"):

        self.debug("Starting the decode the message function. Trying to load message as JSON")
        data = json.loads(enc_msg_json)
        self.debug("Successfully loaded as JSON.")

        self.debug("Splitting the JSON into message part and converting them to Bytes...")
        #convert int list to bytes
        enc_msg_aes = bytes(data[0])
        self.debug("Encrypted message AES okay")
        iv = bytes(data[1])
        self.debug("IV okay")
        enc_aes_key = bytes(data[2])
        self.debug("Encrypted AES key okay")

        self.debug("Encrypted AES msg:" + str(enc_msg_aes))
        self.debug("IV:" + str(iv))
        self.debug("Encrypted AES key:" + str(enc_aes_key))

        #TODO: validate input
        self.debug("Trying to decode the AES key with RSA")
        aes_key = self.rsa_decode(enc_aes_key)
        self.debug("Successfully decoded AES key")

        self.debug("Trying to decode message")
        decoded_msg = self.decrypt_aes(aes_key, iv, enc_msg_aes, mode=mode)
        self.debug("Successfully decoded message")


        return decoded_msg

    def rsa_decode(self, enc_aes_key):
        with open("assets/private.pem") as aeskey_file:
            key = RSA.import_key(aeskey_file.read(), passphrase="enowars")

        cipher_rsa = PKCS1_OAEP.new(key)
        #TODO: try - invalid input?
        enc_key_bytes = cipher_rsa.decrypt(enc_aes_key)

        return enc_key_bytes


    def rsa_sign_message(self, msg):
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


    def readline_expect_multiline(self, telnet_session, msg):
        for m in msg.split('\n'):
            if self.debug_print:
                tmp = telnet_session.readline_expect(m)
                #print(tmp)
                self.debug(tmp)
            else:
                telnet_session.readline_expect(m)


    def intro(self, t):
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["welcome"])
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, "Your balance is: 0")
        self.readline_expect_multiline(t, string_dictionary["reception_0"])


    def goto_cryptomat(self, t):
        t.write("b\n")
        self.readline_expect_multiline(t, string_dictionary["reception_2"])
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["bathroom_0"])
        t.write("w\n")
        self.readline_expect_multiline(t, string_dictionary["bathroom_1"])
        self.readline_expect_multiline(t, string_dictionary["bathroom_4"])
        t.write("v\n")
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["cryptomat_0"])

    def goto_games(self, t):
        t.write("g\n")
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["gamble_0"])
        self.readline_expect_multiline(t, "black_jack\nslot_machine\nroulette")
        self.readline_expect_multiline(t, string_dictionary["gamble_1"])

    def insert_table_flag(self, t):
        identifier = generate_random_string(20)
        minimum = "1000000000000000000"
        passphrase = generate_random_string(20)

        t.write("c\n")
        self.readline_expect_multiline(t, string_dictionary["table_12"])
        t.write(identifier + "\n")
        self.readline_expect_multiline(t, string_dictionary["table_6"])
        t.write(self.flag + "\n")
        self.readline_expect_multiline(t, string_dictionary["table_8"])
        t.write(minimum + "\n")
        self.readline_expect_multiline(t, string_dictionary["table_10"])
        t.write(passphrase + "\n")
        self.readline_expect_multiline(t, string_dictionary["table_15"])

        self.team_db[self.flag] = (identifier, minimum, passphrase)


    port = 6969  # default port to send requests to.

    def putflag(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug(e)
            raise(e)
        try:
            self.debug("connected to {}".format(self.address))
            self.intro(t)

            if self.flag_idx == 0:
                #table-flag

                #change to games
                self.goto_games(t)

                #change to black_jack
                t.write("black_jack\n")
                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, string_dictionary["table_0"])

                #create a new table
                self.insert_table_flag(t)

            elif self.flag_idx == 1:
                self.put_crypto(t, mode="OFB")
            #TODO: better leaving
            #print(self.flag_round)
            t.close()
        except:
            raise BrokenServiceException("putflag didnt work")

    def getflag(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug(e)
            raise(e)
        try:
            self.debug("connected to {}".format(self.address))
            self.intro(t)

            if self.flag_idx == 0:
                #change to games
                self.goto_games(t)

                #change to black_jack
                t.write("black_jack\n")
                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, string_dictionary["table_0"])

                #join a table
                t.write("j\n")
                #self.readline_expect_multiline(t, string_dictionary[])
                identifier, minimum, passphrase = self.team_db[self.flag]

                t.read_until(string_dictionary["table_2"] + "\n")
                t.write(identifier + "\n")
                self.readline_expect_multiline(t, string_dictionary["table_4"])
                t.write(passphrase + "\n")
                self.readline_expect_multiline(t, "You approach the black_jack table " + self.flag + ". The dealer smiles at you and slightly nods his head as a greeting.")
                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, "How much are you willing to bet?")
                self.readline_expect_multiline(t, "Your balance is: 0")
                t.write("0\n")

                self.readline_expect_multiline(t, "Sorry but this is not a childs game. You can leave now.")
                self.readline_expect_multiline(t, string_dictionary["gamble_4"])
                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, "Your balance is: 0")
                self.readline_expect_multiline(t, string_dictionary["reception_0"])

                t.write("l\n")


            elif self.flag_idx == 1:
                self.get_crypto(t, "OFB")
            #todo: better leaving
            t.close()
        except Exception as e:
            self.debug("getflag - Exception catched")
            self.debug(e)
            raise BrokenServiceException("getflag did not work ~ checker author fault DAR+HAS!")

    def exploit(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug(e)
            raise(e)

    def putnoise(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug(e)
            raise(e)

    def getnoise(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug(e)
            raise(e)

    def havoc(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug(e)
            raise(e)

with open('assets/strings.json', 'r') as f:
    string_dictionary = json.load(f)

app = CasinoChecker.service
if __name__ == "__main__":
    run(CasinoChecker)
