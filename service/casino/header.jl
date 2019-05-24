using Sockets

@enum Status reception gambling
@enum Game black_jack slot_machine roulette

mutable struct Player
    balance :: Int64
    status :: Status
    socket :: TCPSocket
    dimension :: Int
    msg :: String
end
