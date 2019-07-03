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
    noise_count = 1
    havoc_count = 2

    balance = 0

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
        if(mode== "CBC"):
            t.write("r\n")
            self.readline_expect_multiline(t, string_dictionary["restaurant_intro"])
            t.write("🧀\n".encode("utf-8"))
            self.readline_expect_multiline(t, string_dictionary["restaurant_cheese"])
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
            t.write("l\n")

            self.readline_expect_multiline(t, string_dictionary["spacer"])
            self.readline_expect_multiline(t, "Your balance is: 0")
            self.readline_expect_multiline(t, string_dictionary["reception_0"])

        self.goto_cryptomat(t)
        #get note
        if(mode=="OFB"):
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
                decrypted_msg = self.decode_crypto_msg(msg, mode=mode)
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
            cipher = AES.new(key, AES.MODE_CBC, iv=iv)
            msg = cipher.decrypt(enc_msg)
        else:
            print("Invalid mode")

        return msg.decode('utf-8').rstrip('\x00')


    #TODO: change for use in the checker
    def decode_crypto_msg(self, enc_msg_json, mode="OFB"):

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
        self.balance = 0
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

    def withdraw_chips(self, t, amount):
        t.write("w\n")
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["withdraw_0"])

        t.write('%d\n' %(amount))
        self.readline_expect_multiline(t, string_dictionary["withdraw_3"])
        self.readline_expect_multiline(t, string_dictionary["spacer"])

        self.debug("reading the captcha")
        try:
            captcha = t.read_until(string_dictionary["spacer"] + "\n")
            captcha = captcha.decode("utf-8")
        except Exception as e:
            self.debug("something went wrong while trying to read the captcha..")
            self.debug("%s" %(e))
            raise BrokenServiceException("withdraw_chips - Exception catched; Flag ID: " + str(self.flag_idx))

        self.debug("\n%s" %(captcha))
        self.debug("calculating captcha")
        sum = 0
        for c in captcha:
            if c == 'T':
                sum += 10
            elif c == 'J':
                sum += 11
            elif c == 'Q':
                sum += 12
            elif c == 'K':
                sum += 13
            elif c == 'A':
                sum += 14
            elif c.isdigit():
                sum += int(c)

        sum /= 3
        self.debug("the sum should be: %d" %(sum))
        t.write('%d\n' %(sum))
        self.readline_expect_multiline(t, string_dictionary["withdraw_4"])

        self.balance += amount
        if self.balance > 10000:
            self.readline_expect_multiline(t, string_dictionary["withdraw_2"])
            self.balance = 10000

        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, "Your balance is: %d" %(self.balance))
        self.readline_expect_multiline(t, string_dictionary["reception_0"])

    def play_slot_machine(self, t, rounds):
        self.debug("playing %d rounds at the slot_machine" %(rounds))
        t.write("slot_machine\n")
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["slot_machine_welcome"])

        for i in range(0, rounds):
            self.readline_expect_multiline(t, string_dictionary["spacer"])
            self.readline_expect_multiline(t, string_dictionary["slot_machine_0"])

            chips = random.choice([5, 10, 50])
            t.write("%s\n" %(chips))
            if self.balance < chips:
                self.debug("slot_machine - not enough chips to play on. balance: %d chips: %d" %(self.balance, chips))
                if chips == 5:
                    self.readline_expect_multiline(t, string_dictionary["slot_machine_1"])
                    weird_guy = True
                    chips = 1
                else:
                    self.readline_expect_multiline(t, string_dictionary["slot_machine_2"])
                    t.write("\n")
                    self.readline_expect_multiline(t, string_dictionary["gamble_4"])
                    return
            else:
                weird_guy = False
            self.readline_expect_multiline(t, string_dictionary["slot_machine_3"])

            result = t.read_until("\n")
            result = result.decode("utf-8")

            if result == string_dictionary["slot_machine_4"] + "\n":
                self.balance += chips
                self.debug("slot_machine - you win. balance: %d" %(self.balance))
            elif result == string_dictionary["slot_machine_5"] + "\n":
                self.balance -= chips
                self.debug("slot_machine - you lose. balance: %d" %(self.balance))
            else:
                self.debug("slot_machine - got: %s expected: slot_machine_4 or slot_machine_5" %(result))
                raise(BrokenServiceException("slot_machine - win/lose message was tempered with."))

            if weird_guy:
                if self.balance < 0:
                    self.readline_expect_multiline(t, string_dictionary["debt_0"])
                    self.readline_expect_multiline(t, string_dictionary["gamble_4"])
                    return

            self.readline_expect_multiline(t, string_dictionary["gamble_2"])
            if rounds-1 == i:
                t.write("n\n")
                self.readline_expect_multiline(t, string_dictionary["gamble_3"])
            else:
                t.write("y\n")

    def play_roulette(self, t, rounds):
        self.debug("playing %d rounds of roulette" %(rounds))
        t.write("roulette\n")
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["table_0"])

        self.join_any_table(t)

        t.read_until("The dealer smiles at you and slightly nods his head as a greeting.\n")
        self.readline_expect_multiline(t, string_dictionary["roulette_welcome"])

        for i in range(0, rounds):
            self.readline_expect_multiline(t, string_dictionary["spacer"])
            self.readline_expect_multiline(t, string_dictionary["roulette_0"])
            self.readline_expect_multiline(t, "Your balance is: %d" %(self.balance))
            self.readline_expect_multiline(t, string_dictionary["roulette_1"])
            self.readline_expect_multiline(t, string_dictionary["roulette_2"])

            if self.balance <= 0:
                t.write("d\n")
                self.readline_expect_multiline(t, string_dictionary["roulette_3"])
                self.readline_expect_multiline(t, string_dictionary["gamble_4"])
                return

            chips = random.randint(1, self.balance)
            target = random.choices(population=['red', 'black', '1-12', '13-24', '25-36', '1', '3' , '7', '36'], weights=[18,18,12,12,12,1,1,1,1])[0]
            t.write("%d %s\n" %(chips, target))

            self.readline_expect_multiline(t, string_dictionary["roulette_2"])
            t.write("d\n")

            self.readline_expect_multiline(t, string_dictionary["roulette_5"])
            t.read_until("Your total winnings are: ")
            winnings = int(t.read_until("\n").rstrip())
            self.balance += winnings

            self.readline_expect_multiline(t, string_dictionary["gamble_2"])
            if rounds-1 == i:
                t.write("n\n")
                self.readline_expect_multiline(t, string_dictionary["gamble_3"])
            else:
                t.write("y\n")

    def play_black_jack(self, t, rounds):
        self.debug("playing %d rounds of black_jack" %(rounds))
        t.write("black_jack\n")
        self.readline_expect_multiline(t, string_dictionary["spacer"])
        self.readline_expect_multiline(t, string_dictionary["table_0"])

        self.join_any_table(t)

        t.read_until("The dealer smiles at you and slightly nods his head as a greeting.\n")
        self.readline_expect_multiline(t, string_dictionary["black_jack_welcome"])

        for i in range(0, rounds):
            self.readline_expect_multiline(t, string_dictionary["spacer"])
            self.readline_expect_multiline(t, string_dictionary["black_jack_3"])
            self.readline_expect_multiline(t, "Your balance is: %d" %(self.balance))

            if self.balance <= 0:
                t.write("0\n")
                self.readline_expect_multiline(t, string_dictionary["black_jack_5"])
                self.readline_expect_multiline(t, string_dictionary["gamble_4"])
                return
            chips = random.randint(1, self.balance)

            self.debug("black_jack - investing: %d" %(chips))
            t.write("%d\n" %(chips))

            #TODO: what happens if you get a black_jack?
            t.read_until("\n")
            t.read_until("\n")
            line = t.read_until("\n").decode("utf-8").rstrip()
            if line == string_dictionary["black_jack_0"]:
                natural = True
            elif line == string_dictionary["black_jack_1"]:
                self.balance += int(chips/2)
                natural = True
            elif line == string_dictionary["black_jack_2"]:
                self.balance -= chips
                natural = True
            elif line == string_dictionary["black_jack_6"]:
                natural = False
                pass
            else:
                self.debug("black_jack - got: %s expected: black_jack_0, black_jack_1, black_jack_2 or black_jack_6" %(line))
                raise(BrokenServiceException("black_jack - natural blackjack or hit/stand choice was tempered with."))

            if not natural:
                t.write("s\n")

                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, string_dictionary["black_jack_8"])

                result = t.read_until(string_dictionary["gamble_2"] + "\n").decode("utf-8").split("\n")
                print(result)

                if result[len(result) - 3] == 'Better luck next time!':
                    self.balance -= chips
                elif result[len(result) - 3] == 'Congratulations!':
                    self.balance += chips
                elif result[len(result) - 3] == 'Well played!':
                    pass
                else:
                    self.debug("black_jack - got: %s expected: \"Better luck next time!\", \"Congratulations!\" or \"Well played!\"." %(line))
                    raise(BrokenServiceException("black_jack - you either win, lose or standoff."))
            else:
                self.readline_expect_multiline(t, string_dictionary["gamble_2"])

            if rounds-1 == i:
                t.write("n\n")
                self.readline_expect_multiline(t, string_dictionary["gamble_3"])
            else:
                t.write("y\n")

    def join_any_table(self, t):
        t.write("j\n")
        tables = t.read_until(string_dictionary["table_2"] + "\n")
        tables = tables.decode("utf-8")
        tables = tables.split("\n")

        if tables[0] == string_dictionary["table_1"]:
            self.debug("join_any_table - tables available.. joining")

            table_identifier = tables[random.randint(1, len(tables) - 3)]
            t.write(table_identifier + "\n")

        elif tables[0] == string_dictionary["table_3"]:
            self.debug("join_any_table - no tables available.. creating")

            identifier = generate_random_string(20)
            name = random.choice(['1337', '1', '1234', 'test', 'name', 'lol', 'wow'])
            if self.balance <= 1:
                minimum = "1"
            else:
                minimum = "%d" %(random.randint(1,self.balance))
            passphrase = random.choice(['1234', 'password', 'password1', '1', 'test', '1234567890'])
            self.create_table(t, identifier, name, minimum, passphrase)

        else:
            self.debug("join_any_table - got: %s expected: table_1 or table_3" %(tables[0]))
            raise(BrokenServiceException("join_any_table - join_table was tempered with."))

    def create_table(self, t, identifier, name, minimum, passphrase):
        t.write("c\n")
        self.readline_expect_multiline(t, string_dictionary["table_12"])
        t.write(identifier + "\n")
        try:
            self.readline_expect_multiline(t, string_dictionary["table_6"])
        except:
            self.debug("create_table - the identifier is already in use (which is higly improbable)")
            raise(BrokenServiceException("create_table - the identifier is already in use (which is highly improbable"))

        t.write(name + "\n")
        self.readline_expect_multiline(t, string_dictionary["table_8"])
        t.write(minimum + "\n")
        self.readline_expect_multiline(t, string_dictionary["table_10"])
        t.write(passphrase + "\n")
        self.readline_expect_multiline(t, string_dictionary["table_15"])


    def insert_table_flag(self, t):
        identifier = "ENO" + generate_random_string(20)
        minimum = "1000000000000000000"
        passphrase = generate_random_string(20)

        self.create_table(t, identifier, self.flag, minimum, passphrase)
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
            self.debug("Putflag success before closing")
            t.close()
        except:
            self.debug("putflag - Exception catched; Flag ID: " + str(self.flag_idx))
            self.debug(e)
            raise BrokenServiceException("putflag did not work; Flag ID: " + str(self.flag_idx))

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
                try:
                    identifier, minimum, passphrase = self.team_db[self.flag]
                except Exception as e:
                    self.debug("getflag - flag was not found in the database..")
                    raise(e)

                t.read_until(string_dictionary["table_2"] + "\n")
                t.write(identifier + "\n")
                self.readline_expect_multiline(t, string_dictionary["table_4"])
                t.write(passphrase + "\n")
                self.readline_expect_multiline(t, "You approach the black_jack table " + self.flag + ". The dealer smiles at you and slightly nods his head as a greeting.")
                self.readline_expect_multiline(t, string_dictionary["black_jack_welcome"])
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
                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, string_dictionary["exit"])


            elif self.flag_idx == 1:
                self.get_crypto(t, "OFB")
            #todo: better leaving
            self.debug("Getflag success before closing")
            t.close()
        except Exception as e:
            self.debug("getflag - Exception catched; Flag ID: " + str(self.flag_idx))
            self.debug(e)
            raise BrokenServiceException("getflag did not work; Flag ID: " + str(self.flag_idx))

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
        try:
            self.debug("connected to {}".format(self.address))
            self.intro(t)
            if self.flag_idx == 0:
                self.put_crypto(t, "CBC")
            self.debug("Putnoise success before closing")
            t.close()
        except Exception as e:
            self.debug("putnoise - Exception catched; Noise ID: " + str(self.flag_idx))
            self.debug(e)
            raise BrokenServiceException("getnoise did not work; Noise ID: " + str(self.flag_idx))

    def getnoise(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug(e)
            raise(e)
        try:
            self.debug("connected to {}".format(self.address))
            self.intro(t)

            if self.flag_idx == 0:
                self.get_crypto(t, "CBC")
            self.debug("Getnoise success before closing")
            t.close()
        except Exception as e:
            self.debug("getnoise - Exception catched; Noise ID: " + str(self.flag_idx))
            self.debug(e)
            raise BrokenServiceException("getnoise did not work; Noise ID: " + str(self.flag_idx))


    def havoc(self):
        try:
            t = self.connect()
        except Exception as e:
            self.debug("havoc - Exception catched while connecting to the service; Havoc ID: " + str(self.flag_idx))
            self.debug(e)
            raise(e)
        try:
            self.debug("connected to {}".format(self.address))

            self.intro(t)

            if self.flag_idx == 0:
                #randomly choose between playing a game (and withdrawing money), going to the bathroom or to the restaurant
                c = random.choices(population=['b', 'w', 'r'], weights=[0, 1, 0])[0]

                if c == 'b':
                    pass
                elif c == 'w':
                    self.debug('havoc - withdrawing money')
                    self.withdraw_chips(t, random.choice([1337,10000,1000,420,9999, random.randint(1,4), random.randint(5000,1000000)]))
                    self.debug("successfully withdrew chips, current balance is: %d" %(self.balance))

                    self.goto_games(t)

                    g = random.choices(population=['slot_machine', 'roulette', 'black_jack'], weights=[1, 1, 1])[0]

                    if g == 'slot_machine':
                        self.play_slot_machine(t, random.randint(1,5))
                    elif g == 'roulette':
                        self.play_roulette(t, random.randint(1,5))
                    elif g == 'black_jack':
                        self.play_black_jack(t, random.randint(1,5))
                elif c == 'r':
                    pass
                else:
                    self.debug("havoc - unknown choice : %s.. exiting" %(c))
                    return

                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, "Your balance is: %d" %(self.balance))
                self.readline_expect_multiline(t, string_dictionary["reception_0"])
                t.write("l\n")
                self.readline_expect_multiline(t, string_dictionary["spacer"])
                if self.balance < 0:
                    self.readline_expect_multiline(t, string_dictionary["debt_1"])
                else:
                    self.readline_expect_multiline(t, string_dictionary["exit"])

            if self.flag_idx == 1:
                t.write("r\n")
                self.readline_expect_multiline(t, string_dictionary["restaurant_intro"])
                t.write("🧀\n".encode("utf-8"))
                self.readline_expect_multiline(t, string_dictionary["restaurant_cheese"])
                r = t.read_until("\n")[:-1]
                try:
                    self.debug("Starting to work on the found notes")
                    self.debug("Trying to load notes as JSON")
                    notes = json.loads(r.decode('utf-8'))
                    self.debug("Notes successfully loaded as JSON")

                    if len(notes) == notes:
                        flag_dimension = random.randint(-pow(2,31), pow(2,31))
                        self.debug("Empty notes - Generated random dimension: ", dim)
                    else:
                        #TODO: adjust to round
                        difference = self.round - self.flag_round
                        self.debug("Difference between round and flag_round is:" + str(difference))

                        flag_dimension = notes[difference]
                        self.debug("Havoc dimension: " + str(flag_dimension))
                except Exception as e:
                    self.debug(e)
                    raise BrokenServiceException("Notes Error")
                t.write("l\n")

                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, "Your balance is: 0")
                self.readline_expect_multiline(t, string_dictionary["reception_0"])

                self.goto_cryptomat(t)

                #figure out code
                fool_dimension = random.randint(-pow(2,31)+1, pow(2,31)-1)

                self.debug("Fool dimension: " + str(fool_dimension))

                code = "CASINO_ROYALE"

                x = abs(fool_dimension) % len(code)+1
                code = code[x:len(code)] + code[0:x]

                self.debug("Using code: " + str(code))

                t.write("u\n")
                self.readline_expect_multiline(t, string_dictionary["cryptomat_1"])
                t.write(code+"\n")
                self.readline_expect_multiline(t, string_dictionary["cryptomat_0"])
                t.write("🕐\n".encode("utf-8"))
                self.debug("Setting dimension: " + str(fool_dimension))
                t.write(str(fool_dimension)+"\n")

                t.write("g\n")
                self.readline_expect_multiline(t, string_dictionary["crpytomat_generating_token"])
                self.readline_expect_multiline(t, string_dictionary["cryptomat_get_token"])

                t.write("l\n")

                self.readline_expect_multiline(t, string_dictionary["cryptomat_5"])
                self.readline_expect_multiline(t, string_dictionary["bathroom_5"])
                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, "Your balance is: 0")
                self.readline_expect_multiline(t, string_dictionary["reception_0"])

                t.write("r\n")
                self.readline_expect_multiline(t, string_dictionary["restaurant_intro"])
                t.write("c\n")
                self.readline_expect_multiline(t, string_dictionary["restaurant_counter"])
                self.readline_expect_multiline(t, string_dictionary["restaurant_menu"])

                t.write("c\n")
                self.readline_expect_multiline(t, string_dictionary["restaurant_casino_royale"])
                self.readline_expect_multiline(t, string_dictionary["restaurant_intro"])
                t.write("l\n")

                self.readline_expect_multiline(t, string_dictionary["spacer"])
                self.readline_expect_multiline(t, "Your balance is: 0")
                self.readline_expect_multiline(t, string_dictionary["reception_0"])

                t.write("b\n")

                self.readline_expect_multiline(t, string_dictionary["reception_2"])
                self.readline_expect_multiline(t, string_dictionary["bathroom_diarrhea"])

                t.write("r\n")

                self.readline_expect_multiline(t, string_dictionary["bathroom_stall_walls"])
                hash_msg = t.read_until("\n")[:-1].decode('utf-8')
                if len(json.loads(hash_msg)) != 16:
                    raise BrokenServiceException("Hash message too small")

            self.debug("Havoc success before closing")
            t.close()

        except Exception as e:
            self.debug("havoc - Exception catched; Havoc ID: " + str(self.flag_idx))
            self.debug(e)
            raise BrokenServiceException("havoc did not work; Havoc ID: " + str(self.flag_idx))


with open('assets/strings.json', 'r') as f:
    string_dictionary = json.load(f)

app = CasinoChecker.service
if __name__ == "__main__":
    run(CasinoChecker)
