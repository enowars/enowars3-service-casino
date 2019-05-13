using JSON
using MD5


function formatError()
    println("You deliviered the wrong format. This incident will be reported.")
end

function updateOS()
    println("Insert the new OS here:")
    new_os = readline()

    #validate input
    try
        new_os = JSON.parse(new_os)
    catch y
        formatError()
        return
    end

    if !(isa(new_os, Array{Any, 1}) && isa(new_os[1], Array{Any, 1}) && isa(new_os[2], Array{Any, 1}) && length(new_os[2] == 1))
        formatError()
        return
    end

    #TODO check length of new_os[1]
    for a in new_os[1]
        if !isa(a, String)
            formatError()
            return
        end
    end

    for a in new_os[2]
        if !isa(a, Int)
            formatError
            return
        end
    end

    #check integrity
    hash = md5(JSON.json(new_os[1]))
    signature = JSON.json(new_os[2])
    open("crptomat/.signature", "w") do f
        write(f, signature)
    end
    #TODO: python
    f = open("cryptomat/.hash", "r")
    sig_hash = JSON.parse(read(f, String))
    close(f)
    #TODO: convert hashes to the same type

    #TODO: check if hashes are the same

    #TODO: integrity error if needed

    #TODO update accoridng file, if okay

end
