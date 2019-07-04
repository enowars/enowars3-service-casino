using JSON
using MD5
using Sockets


function formatError(p, incNr)
    write(p.socket, "You deliviered the wrong format. This incident will be reported. $incNr\n")
end

function updateNote(p::Player, codetype)
    if codetype == "bombcode"
        notename = "note"
    elseif codetype == "cheesecode"
        notename = "leaflet"
    end


    if !(isfile(string("data/.", notename)))
        #println("No notes files found")
        notes = []
    else
        #println("Notes file found")
        f = open_file_try(string("data/.", notename), "r")
        notes = JSON.parse(read(f, String))
        close(f)
    end

    current_length = length(notes)

    new_notes = [p.dimension]
    if (0 <= current_length < note_max_length)
        append!(new_notes, notes)
    elseif (current_length == note_max_length)
        append!(new_notes, notes[1:note_max_length-1])

        old_path = string("data/.", codetype, "_", notes[note_max_length])
        rm(old_path)
    else
        return
    end

    f = open_file_try(string("data/.", notename), "w")
    write(f, JSON.json(new_notes))
    close(f)

end

function updateOS(p::Player)
    print_dict(p, "cryptomat_os_update_mode")
    user_input = readline(p.socket)
    while true
        if (user_input == "💣" || user_input == "🧀")
            break
        elseif (user_input == "l")
            return
        else
            print_dict("crpytomat_os_update_invalid_mode")
            return
        end
    end
    mode = user_input

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
    f = open_file_try("cryptomat/.signature.json", "w")
    write(f, JSON.json(new_os))
    close(f)

    cd("cryptomat")
        run(`./rsa_sig.py`)
    cd("..")
    f = open_file_try("cryptomat/.signature.answer", "r")
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
    if mode == "💣"
        codetype = "bombcode"
    elseif mode == "🧀"
        codetype = "cheesecode"
    end
    path = string("data/.", codetype ,"_", p.dimension)
    f = open_file_try(path, "w")
    write(f, os_string)
    close(f)

    updateNote(p, codetype)
    write(p.socket, "Updated\n")


end
