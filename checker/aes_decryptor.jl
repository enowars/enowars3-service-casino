using AES
using JSON

f = open(".aes_msg_enc", "r")
data = JSON.parse(read(f, String), inttype=UInt8)
close(f)

key = Array{UInt8,1}(data[1])
iv = Array{UInt8,1}(data[2])
enc_msg = Array{UInt8,1}(data[3])
#print("IV: ", iv, "     length:", length(iv))

decoded_msg = AESCTR(enc_msg, key, iv)

f = open(".aes_msg", "w")
write(f, JSON.json(decoded_msg))
close(f)
