#!/usr/bin/env python3

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import json

with open("assets/private.pem") as aeskey_file:
	key = RSA.import_key(aeskey_file.read(), passphrase="enowars")

with open("../casino/cryptomat/.aeskey_enc.json") as json_file:
	data = json.load(json_file)

print(data)
#convert int list to bytes
data = bytes(data)

cipher_rsa = PKCS1_OAEP.new(key)
enc_key_bytes = cipher_rsa.decrypt(data)

enc_key_list = []
#convert back to int list

for b in enc_key_bytes:
	enc_key_list.append(int.from_bytes([b], byteorder='big', signed=False))

print(enc_key_list)
