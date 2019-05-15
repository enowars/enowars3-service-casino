#!/usr/bin/env python3

from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256
import json

def sign_message(msg):
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





print(sign_message("TESTFLAG!§$%&/{}"))
