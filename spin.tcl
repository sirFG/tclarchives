###  This Script Not Belong To Me But I Do Some Changes.
###  Now The Spin The Bottle Have A Random Message.
###  Anyone Can Add Easily The Options Of The Random Message That Want.
### 
###     Written By Sergios K. sergios_k@hotmail.com
###
###  
###   Testing
###    Platforms : Linux 2.2.16   TCL v8.3
###                Eggdrop v1.6.0
###                Eggdrop v1.6.6
###         And : SunOS 5.8      TCL v8.3
###                Eggdrop v1.5.4
###
###  Description : IRC Game,the famous game Spin The Bottle (night at beatch,that was my job,lol)
###
###   Future Plans : Send in suggestions.
###
### Author Contact :     Email - sergios_k@hotmail.com
###                      Email - sergios@zeus.dynip.com
###                   Home Page - http://zeus.dynip.com/programs
###                     IRC - Nick: Sergios
###                   Support Channels: #Parea @GRNet (nini.irc.gr)
###                   #Help @ZeusNet (patra.dynip.com)
###                  
###
###                  History : 07/29/2001 - First Release
###
###    This Script Belong To moonwolf, just i do change into random message.
###    Flames/suggestions/invitations to dinner: 
###    moonwolf on IRC                    moonwolf@wolflair.demon.co.uk
###    BOTNET: moonwolf@phelan            wolf@spodbox.ehche.ac.uk
###
###    Oh, BTW, right now the last_nick function doesn't work.  Anyone tell
###    me why please?   Also working on stopping more than one person
###    spinning it at a time.  Suggestions for that also appreciated.  k.
###
###    Modified a bit by dhbrown [chocolat@undernet]. I think "last_nick"
###    works now...
###    Adapted for 1.0 by Robey
###

###    spin_bunny:   Coded by moonwolf with input from Sloot. Reworked by chocolat
###             to eliminate bot, self, last_nick kissing. Incorporates
###             previous "init_bunny" code.

###
### Define last_nick to be $botnick if not yet defined...
###
if {![info exists last_nick]} {set last_nick $botnick}

proc spin_bunny {nick uhost handle chan args} {
  global botnick last_nick
  global rep
#
#  Define last_nick = $botnick if last_nick now gone from channel
#
  if {![onchan $last_nick $chan]} {set last_nick $botnick}
  set mylist [chanlist $chan]
#
# Remove the bot from the list (life's too short to kiss bots!)
#
  set wb [lsearch $mylist $botnick]
  set mylist [lreplace $mylist $wb $wb]
#
# Remove the invoking nick from the list
#
  set wn [lsearch $mylist $nick]
  set mylist [lreplace $mylist $wn $wn]
#
# If our first time thru, last_nick = $botnick, so we're done.
# Else, remove last person kissed from the list too.
#
  if {$last_nick != $botnick} {
    set wl [lsearch $mylist $last_nick]
    set mylist [lreplace $mylist $wl $wl]
  }
#
# Pick one of the remaining people at random. Make sure
# we're not just playing with ourselves... :)
#
  set mylength [llength $mylist]
  if {$mylength == 0} {
  putserv "PRIVMSG $chan :Well, $nick, there's no one new to kiss! :("
  return 0
  }
  set myindex [rand $mylength]
  set result [lindex $mylist $myindex]
  set rep {
  "kiss"
  "hugs"
  "kiss into mouth of"
  "do anything that want"
  "go close of"
  "kiss on the cheak to"
  "explain what do you feel for"
}
#
# Build the suspense up somewhat
#
  putserv "PRIVMSG $chan :$nick spins the bottle ....."
  putserv "PRIVMSG $chan :Where it will point nobody knows ...."
  putserv "PRIVMSG $chan :Round and round it goes ....."
  putserv "PRIVMSG $chan :Round and round it goes ....."
  putserv "PRIVMSG $chan :and it slows and comes to a stop ..."
  putserv "PRIVMSG $chan :pointing at ..... $result!!!!"
  putserv "PRIVMSG $chan :Now $nick you must [lindex $rep [rand [llength $rep]]] $result!!!"
#
# Now define last_nick for future spins...
#
  set last_nick $result
  return 1
}
#
# Bind the command public so anyone can do it. (on any channel)
#
bind pubm - "*spin the bottle*" spin_bunny
bind pubm - "*spin the bunny*" spin_bunny
