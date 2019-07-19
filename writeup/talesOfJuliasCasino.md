# Tales of Julias Casino
# Writeup and more

## 1. Introduction

This is a writeup of the service Julias Casino from the CTF ENOWARS3. Julias Casino was a text-based RPG and was created by
two students from the TU Berlin. All in all the service had two vulnerability. The first vulnerability was an integer over-/underflow
and the second one an IV reuse in AES-OFB. In this writeup we will describe the vulnerabilities but will also tell some stories around
the creation of the service.

At first we will give a brief inside of our intention and how we came up with the idea. Afterwars...
#TODO: Intro entsprechend des Ablaufs anpassen


## 2. The Idea

The idea originated from two perspectives.
The first one was to create a beginner-friendly service. After one of us played his first CTF during the preparation and thought
that a service could be nice where a beginner just can try things and really "play" something, the idea of a casino came up. 
#TODO: hanno perspective


On the other side, after reimplementing the WiFi KRACK vulnerability in the previous semester
the other one of us had the idea to use a part of KRACK as a service vulnerability, namely the AES-CTR IV reuse. But nowadays in
most established programming languages (and preferably more high-level ones) the crypto-libraries makes it not easy
for one to reuse the IV in the according AES modes. And even if one did, it felt kind of obvious during experimenting.
Therefore this was the perfect moment  to try a new programming language. After some research for some new and promising language and
a language with a AES library, we ended up with Julia. Julia just reached 1.0 in October 2018 and we thought this was the perfect
moment to test the language. Additionally Julia is kind of easy to learn and to read. Nevertheless we knew that there would be
obstacles and pitfalls in our way but we didn't expected such things... 

Anyways, we merged the two ideas and ended up with a beginner-friendly text-baed RPG service called Julias Casino.



## X. The vulnerabilities

### Integer over-/underflow

### AES OFB IV reuse

The second vulnerability is a typical crypto vulnerability. The basic idea is that if the IV is reused for multiple messages in
AES OFB mode(same goes for the CTR mode) AND you know the content of one plain text message you can decrpyt the other one.

Under the hood in AES-OFB and -CTR a keystram is generated and XOR'd with the plaintext message. The sole purpose of the IV is to provide "randomness"
to this key stream (Note that the IV always needs to be transmitted with the message). So if one reuses the IV, the keystream is also the same. Now one can appy the following:

```
Notation:
A	- plain text of message A
B	- plain text of message B
A'	- encrypted message A
B'	- encrypted message B
K_A	- Keystream of A'
K_B	_ Keysteam of B'

We want:
B

We know:
Plaintext A

A' = A XOR K_A
B' = B XOR K_B

IV reuse => K_A = K_B; which is K from now on

=>
A' = A XOR K
B' = B XOR K

Due to the fact that we know A, we can calculate K:
K = A' XOR A

And then can calculate B from that:
B = B' XOR K
```

One have to keep in mind the keysteam we extract only is as lon as A. That mean that the plaintext A needs to be at least as long as B so that is able to decrypt
B completely. An examplary exploit can be found in in the `exploit` (flag_idx 1) function of `checker/checker.py`.
The vuln itself happens due to that part of `service/casino/cryptomat/sender.jl`:

```
    cryptomaterial = generate_cryptomaterial(p::Player)

    for cur_message in messages
        #println("\n", cur_message)
        enc_Msg = encryptMessage(p, mode, cur_message, cryptomaterial)

	...

    end
```
So this basically generates the cryptomaterial (cryptomaterial[1] is key, and [2] is IV #distraction) one time for all message. For the key this is fine but that means that all messages use the same IV. To patch
this just change the IV between messages or generate the cryptomaterial every time new. Important to note is that an established crypto library like 
pycrypto usually changes/increments the IV for you in between the messages. One reason to choose a new/niche programming language.



## The Casino Royale with Cheese distraction
TODO: CASINO Royale -> Hash; AES CBC IV reuse


Outline:
#Intro
 - what was our first intetntion | done
 - explenation of the service (including the distraction)
 - vulns
 - restaurant burger
 - open source contribution
 - python cryptodome AES-CTR vs julia AES lib
 - mysterious file not found in docker
 - multi threaded tcp server story
 - why string.json?
 - RSA encryption
 - dimensions
 - cryptomaterial
 - scopes
#future ideas?
 - module, \, \div symbols

