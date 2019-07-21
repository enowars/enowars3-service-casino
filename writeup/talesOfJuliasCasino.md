# Tales of Julias Casino
# Writeup and more

## 1. Introduction

This is a writeup of the service Julias Casino from the CTF ENOWARS3. Julias Casino was a text-based RPG and was created by two students from the TU Berlin. All in all the service had two vulnerabilities. The first vulnerability was an integer over-/underflow and the second one an IV reuse in AES-OFB. In this writeup we will describe the vulnerabilities but will also tell some stories around the creation of the service.

At first we will give a brief inside of our intention and how we came up with the idea. Afterwards we will go into more detail about the two vulnerabilities.
#TODO: Intro entsprechend des Ablaufs anpassen


## 2. The Idea

The idea originated from two perspectives. The first one was to create a beginner-friendly service. After one of us played his first CTF during the preparation and thought that a service could be nice where a beginner could just try things and really "play" something, the idea of a casino came up. With a text-based RPG we could also highlight the dark and apocalyptic theme that we chose for ENOWARS3. As you leave the dark and greyish world where there are people on the verge of dying and heaps of foul-smelling heaps of trash, you enter Julias Casino a world of wonders, flashing lights and well-behaved concierges.

On the other side, after reimplementing the WiFi KRACK vulnerability in the previous semester the other one of us had the idea to use a part of KRACK as a service vulnerability, namely the AES-CTR IV reuse. But nowadays in most established programming languages (and preferably more high-level ones) the crypto-libraries makes it not easy for one to reuse the IV in the according AES modes. And even if one did, it felt kind of obvious during experimenting. Therefore this was the perfect moment  to try a new programming language. After some research for some new and promising language and a language with a AES library, we ended up with Julia. Julia just reached 1.0 in October 2018 and we thought this was the perfect moment to test the language. Additionally Julia is kind of easy to learn and to read. Nevertheless we knew that there would be obstacles and pitfalls in our way but we didn't expected such things... 

Anyways, we merged the two ideas and ended up with a beginner-friendly text-baed RPG service called Julias Casino.

## 3. The service


## 4. Writing the checker part 1 - Julia vs. Python Crypto Library & AES-CTR

So every service needs a checker of course and in our case this was pretty straight forward... or at least we thought. It took some time
to get used to the checker and the methods but all in all just as much as expected. Nevertheless the crypto part which should be uninformly
implemented in Julia and in Python made some troubles.

For Julia we used the only AES library/git repo we found (https://github.com/faf0/AES.jl). Apparently Julia and Crypto Libraries doesn't seem to
be best friends and if one finds one most often they are just calls of C libaries (which is totally fine). During the development
of the service we already needed to port the library from Julia 0.6 to Julia 1.0 and made an according pull request.
Those were just some minor fixes but hey, we contributed to an open source project (of course not completely altruistic).
But during the implementation of the checker which is written in Python and uses the pycrypto library something was weird because
the checker (Python) couldn't decrypt the service (Julia) messages accordingly. First let's have a look at the messages again:

Our messages consists out of the following informations:
* Message(sometimes Flag) itself encrypted via AES-CTR and AES-Key
* The Initialization Vector (IV)
* The AES-Key encrypted via RSA

So the idea is the AES-Key is encrypted via RSA in a way that only the checker can decrypt it (... in a reasonable amount of time ;) ).
So the checker decrypts the AES-Key and uses it with the IV to decrypt the message itself. But at this point AES-CTR was still used
and the IV in AES-CTR definition is a little bit more complicated than usual. Therefore I briefly have to give some background
informations.


#TODO: AES-CTR counter explenation
#TODO: Picture

## 5. netcat & Julia - Test-CTF

6 to 8 weeks before the Final CTF a test CTF was scheduled. At this points we had implemented both vulnerabilities and


## X. The vulnerabilities

### Integer over-/underflow
The first vulnerability was to have some kind of way to get a lot of money in an illegal fashion. As we are playing in a corrupt world the heart of the casino should also be rotten even if the concierges treat you very kindly. The idea was to have tables that only show up if you have enough money thus we could distribute flags in these tables and only have them show for people with huge piles of cash.
To reach these heights of opulence there are two different ways. One is to play games and to constantly continue winning but the chances of this happening are quite low. Though people who know a little bit about roulette could have probably programmed a bot that would win in the long term since the game was missing the 0. The other way was the integer over-/underflow vulnerability:
As you enter the casino you soon realise that you can withdraw chips from an unexhaustable account but that the maximum amount of money you can get is capped at 10000 chips and that you can't withdraw a negative amount.
```
amount = tryparse(Int64, s)
if amount == nothing || amount <= 0
    print_dict(p, "withdraw_1")
    return
end

p.balance += amount

if p.balance > 10000
    print_dict(p, "withdraw_2")
    p.balance = 10000
end
```
If you look closely you see that the amount is first added to the balance and then it is verified that the new balance is not above 10000. The trick for the first overflow is to already have some amount of chips (for example 1) and then ask for Int64.MaxValue (9223372036854775807). By doing this you get the Int64.MinValue (-9223372036854775808) since Julia uses an intended integer wrap-around.
You soon realise that negative amounts of money won't help you in any way in a casino. That is where the second wrap-around (underflow) comes into play. If we could just lose another chip we would wrap-around again and reach Int64.MaxValue which would allow us to see any table in the casino. Since withdrawing chips prohibits you from withdrawing a negative amount you need to find a game where you can lose money without having any. The only intended situation where this can happen is when you play at the _slot\_machine_. When you try playing at the _slot\_machine_ for 5 chips but don't have that amount some weird slightly off looking and stinking person comes to you and belittles for not even having enough chips to play with at the _slot\_machine_. He 'helps' you out by grabbing one of your none existing chips and allows you to play for 1 chip. If you lose (which has a chance of 9/10) your balance is again decremented and you again wrap-around to Int64.MaxValue.

The vulnerability is not too difficult once you find it but it forces you to either explore the casino or the code and does not really need any need prior knowledge or experience. 

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

