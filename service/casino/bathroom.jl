function bathroom(p::Player)
    if p.diarrhea == true
        diarrhea(p)
        return
    end
    print_dict(p, "spacer")
    print_dict(p, "bathroom_0")
    s = readline(p.socket)
    if s == "w"
        print_dict(p, "bathroom_1")
    elseif s == "l"
        print_dict(p, "bathroom_2")
    else
        print_dict(p, "bathroom_3")
        return
    end

    print_dict(p, "bathroom_4")

    s = readline(p.socket)
    if s == "v"
        print_dict(p, "spacer")
        use_cryptomat(p)
    elseif s == "r"
        p.status = reception
    end

    print_dict(p, "bathroom_5")
end

function code(p::Player)
    path = string("data/.cheesecode_", p.dimension)
    if !(isfile(path))
        code = "CASINO_ROYALE"
    else
        f = open_file_try(path, "r")
        code = read(f, String)
        close(f)
    end
    return md5(code * string(p.dimension))
end

function diarrhea(p::Player)
    print_dict(p, "bathroom_diarrhea")
    while true
        user_input = readline(p.socket)
        if user_input == "r"
            print_dict(p, "bathroom_stall_walls")
            write(p.socket, JSON.json(code(p)) * "\n")
            break
        elseif user_input == "l"
            break
        end
    end
    print_dict(p, "bathroom_diarrhea_leave")
    while true
        user_input = readline(p.socket)
        if user_input == "c"
            use_cryptomat(p)
            break
        elseif user_input == "r"
            break
        end
    end

end
