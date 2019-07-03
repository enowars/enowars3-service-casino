using AES


#AES CBC PoC IV reuse

function xorUIntVector(a::Vector{UInt8}, b::Vector{UInt8})
        min_len = min(length(a), length(b))
        result = Vector{UInt8}(undef, min_len)
        for i = 1:min_len
                result[i] = xor(a[i],b[i])
        end
        return result
end

#usually this has nothing to do with passphrases and salts
key = rand(UInt8, div(256, 8))
iv = rand(UInt8, 16)

println("Key: ", key)
println("IV: ", iv)

plain1 = Vector{UInt8}("This plaintext is known and at least as long as the flag.")
plain2 = Vector{UInt8}("I am the flag")

enc1 = AESOFB(plain1, key, iv)
println("Encrypted 1: ", enc1)
println("IV: ", iv)

enc2 = AESOFB(plain2, key, iv)
println("Encrypted 2: ",  enc2)
println("IV: ", iv)

#only using the plain1 to get plain2


keystream = xorUIntVector(Vector{UInt8}(plain1), enc1)
hacked_text = xorUIntVector(keystream, enc2)

println(Vector{UInt8}(hacked_text))
println(Vector{UInt8}(plain2))
