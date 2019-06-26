#!/bin/bash

#round 1
python3 checker.py run -a fd00:1337:1:420::1 -r 1 -f ENOTEST1 -F 1 -i 1 putflag
python3 checker.py run -a fd00:1337:1:420::1 -r 1 -f ENOTEST1 -F 1 -i 1 getflag

python3 checker.py run -a fd00:1337:1:420::1 -r 1 -f ENONOISE1 -F 1 -i 0 putnoise
python3 checker.py run -a fd00:1337:1:420::1 -r 1 -f ENONOISE1 -F 1 -i 0 getnoise

#round 2
python3 checker.py run -a fd00:1337:1:420::1 -r 2 -f ENOTEST2 -F 2 -i 1 putflag
python3 checker.py run -a fd00:1337:1:420::1 -r 2 -f ENOTEST1 -F 1 -i 1 getflag
python3 checker.py run -a fd00:1337:1:420::1 -r 2 -f ENOTEST2 -F 2 -i 1 getflag

python3 checker.py run -a fd00:1337:1:420::1 -r 2 -f ENONOISE2 -F 2 -i 0 putnoise
python3 checker.py run -a fd00:1337:1:420::1 -r 2 -f ENONOISE1 -F 1 -i 0 getnoise
python3 checker.py run -a fd00:1337:1:420::1 -r 2 -f ENONOISE2 -F 2 -i 0 getnoise

#round 3
python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENOTEST3 -F 3 -i 1 putflag
python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENOTEST1 -F 1 -i 1 getflag
python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENOTEST2 -F 2 -i 1 getflag
python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENOTEST3 -F 3 -i 1 getflag

python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENONOISE3 -F 3 -i 0 putnoise
python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENONOISE1 -F 1 -i 0 getnoise
python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENONOISE2 -F 2 -i 0 getnoise
python3 checker.py run -a fd00:1337:1:420::1 -r 3 -f ENONOISE3 -F 3 -i 0 getnoise



