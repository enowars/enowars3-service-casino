#!/usr/bin/env python3

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import json
import sys

file_mode = False

if len(sys.argv) == 1:
	file_mode = True

with open("assets/public.pem") as aeskey_file:
	key = RSA.import_key(aeskey_file.read())


if file_mode:
	with open("cryptomat/.aeskey.json") as json_file:
		data = json.load(json_file)
else:
	data = json.loads(sys.argv[1])

#convert int list to bytes
data = bytes(data)

cipher_rsa = PKCS1_OAEP.new(key)
enc_key_bytes = cipher_rsa.encrypt(data)

enc_key_list = []
#convert back to int list

for b in enc_key_bytes:
	enc_key_list.append(int.from_bytes([b], byteorder='big', signed=False))

if file_mode:
	#print(enc_key_list)
	with open("cryptomat/.aeskey_enc.json", 'w') as enc_file:
		enc_file.write(json.dumps(enc_key_list))
else:
	print(json.dumps(enc_key_list))
