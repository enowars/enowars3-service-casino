#!/usr/bin/env python3

from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256
import json
import sys

file_mode = False

if len(sys.argv) == 1:
	file_mode = True

with open("assets/public.pem") as aeskey_file:
	key = RSA.import_key(aeskey_file.read())

if file_mode:
	with open("cryptomat/.signature.json") as json_file:
		data = json.load(json_file)
else:
	data = json.loads(sys.argv[1])

#convert int list to bytes
msg = data[0]
signature = bytes(data[1])

msg_bytes = bytearray()
msg_bytes.extend(map(ord, msg))

hash = SHA256.new(msg_bytes)

try:
	pkcs1_15.new(key).verify(hash, signature)
	answer = "+"
except (TypeError):
	print("py - TypeError")
	answer = "-"
except (ValueError):
	answer = "-"

if not file_mode:
	if answer == "+":
		exit()
	else:
		exit(1)

#print(enc_key_list)
if len(sys.argv) == 1:
	with open("cryptomat/.signature.answer", 'w') as ans_file:
		ans_file.write(answer)
