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








Outline:
#Intro
 - what was our first intetntion
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

