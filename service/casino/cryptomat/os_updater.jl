using JSON
using MD5


function formatError(incNr)
    println("You deliviered the wrong format. This incident will be reported. ", incNr)
end

function updateOS()
    println("Insert the new OS here:")
    new_os = readline()

    #validate input
    try
        new_os = JSON.parse(new_os)
    catch y
        formatError(0)
        return
    end

    if !(isa(new_os, Array{Any, 1})
        && length(new_os) == 2
        && isa(new_os[1], String)
        && isa(new_os[2], Array{Any, 1}))
        formatError(1)
        return
    end


    for a in new_os[2]
        if !isa(a, Int)
            formatError(2)
            return
        end
    end

    println("Accepted format")
    open("cryptomat/.signature.json", "w") do f
        write(f, JSON.json(new_os))
    end
    cd("cryptomat")
        run(`./rsa_sig.py`)
    cd("..")
    f = open("cryptomat/.signature.answer", "r")
    answer = read(f, String)
    close(f)

    println(answer)
    if answer != "+"
        println("Not accepting this signature")
        return
    end

    println("Signature valid")

    os_string = new_os[1]

    println("Upating...")
    println(os_string)
    #TODO update accoridng file, if okay

end
