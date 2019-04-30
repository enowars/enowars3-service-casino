using AES
using MD5

function padMessage(message)
    cur_nr_of_blocks = length(message)%16
    nr_of_fill_zeros = (cur_nr_of_blocks+1)*16-length(message)
    fill_zeros = zeros(UInt8, nr_of_fill_zeros)
    return vcat(message, fill_zeros)
end

function encryptMessage(mode::Int, message::String, key, iv)
    message = Array{UInt8, 1}(message)
    message = padMessage(message)

    if mode == 1
        println("AES CBC:")
        AESCBC(message, key, iv, true)
    elseif mode == 2
        println("AES CFB:")
        AESCFB(message, key, iv, true)
    elseif mode == 3
        println("AES CTR:")
        AESCTR(message, key, iv)
    elseif mode == 4
        println("AES ECB:")
        AESECB(message, key, true)
    else
        println("AES OFB:")
        AESOFB(message, key, iv)
    end

end

function generate_cryptomaterial()
    key = md5("This secret is deliviered by the flagbot")
    iv = rand(UInt8, 16)
    key = vcat(key, md5(iv))

    return key, iv
end



function sendSecret(mode::Int)
    println("I will now send you the message in the choose mode.")

    messages = ["ATOM-BOMB-CODE-START",
                "FLAG",
                "ATOM-BOMB-CODE-END"]

    key, iv = generate_cryptomaterial()

    for cur_message in messages
        enc_Msg = encryptMessage(mode, cur_message, key, iv)
        #print iv if needed
        println("Message:")
        println(enc_Msg)
        println(iv)
    end

    println("Sending finished")

end
