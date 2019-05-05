#!/usr/bin/env python3

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import json

with open("../assets/public.pem") as aeskey_file:
	key = RSA.import_key(aeskey_file.read())

with open(".aeskey.json") as json_file:
	data = json.load(json_file)

#convert int list to bytes
data = bytes(data)

cipher_rsa = PKCS1_OAEP.new(key)
enc_key_bytes = cipher_rsa.encrypt(data)

enc_key_list = []
#convert back to int list

for b in enc_key_bytes:
	enc_key_list.append(int.from_bytes([b], byteorder='big', signed=False))

print(enc_key_list)
with open(".aeskey_enc.json", 'w') as enc_file:
	enc_file.write(json.dumps(enc_key_list))
