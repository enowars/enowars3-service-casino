#!/usr/bin/env python3

import os

flag_count = 2
noise_count = 1
havoc_count = 0

rounds = 10

address = "fd00:1337:1:420::1"
nr_of_past_rounds_flag_check = 3


def execCommand(round_id, flag, related_round, mode_id, mode):
	command = "python3 checker.py run -a {address} -r {round_id} -f {flag} -F {related_round} -i {mode_id} {mode}".format(address=address, round_id=round_id, flag=flag, related_round=related_round, mode_id=mode_id, mode=mode)
	print("Executing: ", command)
	os.system(command)


for round in range(rounds):
	#start with flags
	#putflag
	mode = "putflag"
	for flag_id in range(flag_count):
		flag = "ENOTESTFLAG" + str(round)
		execCommand(round, flag, round, flag_id, mode)

	#put noise
	mode = "putnoise"
	for noise_id in range(noise_count):
		flag = "ENOTESTNOISE" + str(round)
		execCommand(round, flag, round, noise_id, mode)


	#iterate through this and the last n (default=3) rounds. Because the gameengine checks the flags for the last three rounds
	for related_round in range(round, max(round-nr_of_past_rounds_flag_check, -1), -1):
		#getflag
		mode = "getflag"
		for flag_id in range(flag_count):
			flag = "ENOTESTFLAG" + str(related_round)
			execCommand(round, flag, related_round, flag_id, mode)

		#getnoise
		mode = "getnoise"
		for noise_id in range(noise_count):
			flag = "ENOTESTNOISE" + str(round)
			execCommand(round, flag, round, noise_id, mode)


	#havoc
	mode = "havoc"
	for havoc_id in range(havoc_count):
		execCommand(round, "", round, havoc_id, mode)
