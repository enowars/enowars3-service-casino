println("foobar")

#exit = false
#print(exit)
function foo()
    exit=false
    while (exit == false)
        if exit == false
            println(exit)
        end
        println("What you wanna do?")
        user_input = readline()
        println(user_input)
        if(user_input == "Q")
            print(exit)
            exit = true
            print("fool")
        end
    end
end

foo()

print("Good Bye")
