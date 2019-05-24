using JSON
using MD5
using Sockets


function formatError(p, incNr)
    write(p.socket, "You deliviered the wrong format. This incident will be reported. $incNr\n")
end

function updateNote(p::Player)
    if !(isfile("data/.note"))
        #println("No notes files found")
        notes = []
    else
        #println("Notes file found")
        f = open("data/.note", "r")
        notes = JSON.parse(read(f, String))
        close(f)
    end

    current_length = length(notes)

    new_notes = [p.dimension]
    if (0 <= current_length < note_max_length)
        append!(new_notes, notes)
    elseif (current_length == note_max_length)
        append!(new_notes, notes[1:note_max_length-1])

        old_path = string("data/.bombcode_", notes[note_max_length])
        rm(old_path)
    else
        return
    end

    open("data/.note", "w") do f
        write(f, JSON.json(new_notes))
    end

end

function updateOS(p::Player)
    print_dict(p, "cryptomat_os_update_1")
    new_os = readline(p.socket)

    #validate input
    try
        new_os = JSON.parse(new_os)
    catch y
        formatError(p, 0)
        return
    end

    if !(isa(new_os, Array{Any, 1})
        && length(new_os) == 2
        && isa(new_os[1], String)
        && isa(new_os[2], Array{Any, 1}))
        formatError(p, 1)
        return
    end


    for a in new_os[2]
        if !isa(a, Int)
            formatError(p, 2)
            return
        end
    end

    print_dict(p, "cryptomat_os_update_accept_format")
    open("cryptomat/.signature.json", "w") do f
        write(f, JSON.json(new_os))
    end
    cd("cryptomat")
        run(`./rsa_sig.py`)
    cd("..")
    f = open("cryptomat/.signature.answer", "r")
    answer = read(f, String)
    close(f)

    #println(answer)
    if answer != "+"
        write(p.socket, "Not accepting this signature\n")
        return
    end

    print_dict(p, "cryptomat_os_update_accept_signature")

    os_string = new_os[1]

    write(p.socket, "Updating...\n")
    #println(os_string)
    path = string("data/.bombcode_", p.dimension)
    f = open(path, "w")
    write(f, os_string)
    close(f)

    updateNote(p)
    write(p.socket, "Updated\n")


end
