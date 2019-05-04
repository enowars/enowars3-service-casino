using AES
using MD5
using JSON

function padMessage(message)
    cur_nr_of_blocks = length(message)÷16
    nr_of_fill_zeros = (cur_nr_of_blocks+1)*16-length(message)
    fill_zeros = zeros(UInt8, nr_of_fill_zeros)
    return vcat(message, fill_zeros)
end

function encryptMessage(mode::Int, message::String, cryptomaterial::Array{Array{UInt8,1},1})
    message = Array{UInt8, 1}(message)
    #println("Prepad message: ", message)
    #println("Prepad message length: ", length(message))
    message = padMessage(message)
    #println("Postpad message: ", message)
    #println("Postpad message length: ", length(message))
    if mode == 1
        println("AES CBC:")
        AESCBC(message, cryptomaterial[1], cryptomaterial[2], true)
    elseif mode == 2
        println("AES CFB:")
        AESCFB(message, cryptomaterial[1], cryptomaterial[2], true)
    elseif mode == 3
        println("AES CTR:")
        AESCTR(message, cryptomaterial[1], cryptomaterial[2])
    elseif mode == 4
        println("AES ECB:")
        AESECB(message, cryptomaterial[1], true)
    else
        println("AES OFB:")
        AESOFB(message, cryptomaterial[1], cryptomaterial[2])
    end

end

function generate_cryptomaterial()
    #TODO: insert symmetric key here
    cryptomaterial = Array{Array{UInt8,1}, 1}(undef, 2)
    key = md5("This is the symmetric key. Need to be computed once for each team.")
    cryptomaterial[2] = rand(UInt8, 16)
    cryptomaterial[1] = vcat(key, md5(cryptomaterial[2]))
    return cryptomaterial
end



function sendSecret(mode::Int)
    println("I will now send you the message in the choosen mode.")

    #insert flag here
    messages = ["ATOM-BOMB-CODE-START",
                "FLAG",
                "ATOM-BOMB-CODE-END"]

    cryptomaterial = generate_cryptomaterial()

    for cur_message in messages
        println("\n", cur_message)
        enc_Msg = encryptMessage(mode, cur_message, cryptomaterial)
        #print iv if needed
        full_Msg = [enc_Msg, cryptomaterial[2]]
        println("Message:")
        println(JSON.json(full_Msg))
    end

    println("Sending finished")

end
