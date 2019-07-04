using AES
using MD5
using JSON

function padMessage(message)
    cur_nr_of_blocks = length(message)÷16
    nr_of_fill_zeros = (cur_nr_of_blocks+1)*16-length(message)
    fill_zeros = zeros(UInt8, nr_of_fill_zeros)
    return vcat(message, fill_zeros)
end

function encryptMessage(p::Player, mode::Int, message::String, cryptomaterial::Array{Array{UInt8,1},1})
    message = Array{UInt8, 1}(message)
    #println("Prepad message: ", message)
    #println("Prepad message length: ", length(message))
    message = padMessage(message)
    #println("Postpad message: ", message)
    #println("Postpad message length: ", length(message))
    if mode == 1
        AESCBC(message, cryptomaterial[1], cryptomaterial[2], true)
    elseif mode == 2
        AESCFB(message, cryptomaterial[1], cryptomaterial[2], true)
    elseif mode == 3
		AESOFB(message, cryptomaterial[1], cryptomaterial[2])
    elseif mode == 4
        AESECB(message, cryptomaterial[1], true)
    else
		AESCTR(message, cryptomaterial[1], cryptomaterial[2])
    end

end

function generate_cryptomaterial(p::Player)
    cryptomaterial = Array{Array{UInt8,1}, 1}(undef, 2)

	global aesSeed
    key = md5(aesSeed)
    cryptomaterial[2] = rand(UInt8, 16)
	cryptomaterial[2][9] = UInt8(0x00)
    cryptomaterial[1] = vcat(key, md5(string(p.dimension)))
    return cryptomaterial
end



function sendSecret(p::Player, mode::Int, customMessage::String, tokenize::Bool=false)

	if !tokenize
		print_dict(p, "cryptomat_sender_1")
	end

	if customMessage == ""
		if mode == 1
			codetype = "cheesecode"
		elseif mode == 3
			codetype = "bombcode"
		end

		path = string("data/.", codetype, "_", p.dimension)
		if !(isfile(path))
			customMessage = string(rand(Int))
		else
			f = open_file_try(path, "r")
			customMessage = read(f, String)
			close(f)
		end
	end

	if tokenize
		messages = [customMessage]
	else
	    messages = ["ATOM:-:BOMB:-:CODE:-:START::SUPER:-:SAFE:-:CRYPTOMAT:-:PROTOCOL",
	                customMessage,
	                "ATOM:-:BOMB:-:CODE:-:END::SUPER:-:SAFE:-:CRYPTOMAT:-:PROTOCOL"]
	end
    cryptomaterial = generate_cryptomaterial(p::Player)

    for cur_message in messages
        #println("\n", cur_message)
        enc_Msg = encryptMessage(p, mode, cur_message, cryptomaterial)
        f = open_file_try("cryptomat/.aeskey.json", "w")
        write(f, JSON.json(cryptomaterial[1]))
        close(f)
		cd("cryptomat")
        	run(`./rsa.py`)
		cd("..")
        #TODO: check if file exists?
        f = open_file_try("cryptomat/.aeskey_enc.json", "r")
        enc_key = JSON.parse(read(f, String), inttype=UInt8)
        close(f)
        full_Msg = [enc_Msg, cryptomaterial[2], enc_key]
		if tokenize
			return JSON.json(full_Msg)
		end
		write(p.socket, "Message:\n$(JSON.json(full_Msg))\n")
    end

    write(p.socket, "Sending finished\n")

end
