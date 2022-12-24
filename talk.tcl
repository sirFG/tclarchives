###########################################################
#
#    Talk 1.0 tcl for eggdrop (19/11/2004)
#    by lnx85 at #lnxlabs on AzzurraNet (irc.azzurra.org)
#    E-mail: lnx85@lnxlabs.it
#
#    per attivare lo script è necessario impostare il flag +talk
#    al canale (.chanset #chan +talk)
#
#    per utilizzare il comando !addtalk è necessario impostare
#    il flag +n all'utente (.chattr Utente +n)
#
#    Sintassi del file "matches.txt"
#    Un talk ogni riga (parola da matchare, TABULAZIONE, testo da mostrare)
#
#    Variabili da poter utilizzare nel file "matches.txt"
#    ^NICK = nick del nuovo entrato
#    ^CHAN = canale in cui è entrato
#    ^B = grassetto (^Btesto^B)
#    ^U = sottolineato (^Utesto^U)
#    ^K = colorato ^K<colore testo>[,<colore sfondo>] (^K2,4testo^K)
#    § = ritorno a capo, serve per far inviare più di una riga
#
###########################################################

### GLOBALS ###
set talk(version) "1.0"
set talk(flags) "-"
set talk(matches) { }

# Path del file contenente i match da caricare
set talk(talk_file) "/home/lnxlabs/eggdrop/files/matches.txt"
### END GLOBALS ###

### FLAGS ###
setudef flag talk
### END FLAGS ###

### BINDS ###
bind pubm $talk(flags) "*" talk:parse
bind pub n "!addtalk" talk:addtalk
### END BINDS ###

### PROCS ###
proc talk:parse { nick host handle chan text } {
	global talk
	if { [ lsearch -exact [ channel info $chan ] "+talk" ] == -1 } { return }
	for { set n 0 } { $n < [ llength $talk(matches) ] } { incr n } {
		if { [ regexp -nocase -- {(.+)\t(.+)} [ lindex $talk(matches) $n ] all match testo ] } {
			if { [ regexp -nocase -- "^\[^A-Z0-9\]?$match\[^A-Z0-9\].+" $text all ] || [ regexp -nocase -- ".+\[^A-Z0-9\]$match\[^A-Z0-9\].+" $text all ] || [ regexp -nocase -- ".+\[^A-Z0-9\]$match\[^A-Z0-9\]?\$" $text all ] || [ string match -nocase "$match" $text ] } {
				regsub -all -- {\^B} $testo "\002" testo
				regsub -all -- {\^U} $testo "\037" testo
				regsub -all -- {\^K} $testo "\003" testo
				regsub -all -- {\^NICK} $testo "$nick" testo
				regsub -all -- {\^CHAN} $testo "$chan" testo
				foreach line [ split $testo "§"] {
					putserv "PRIVMSG $chan :$line"
				}
				return
			}
		}
	}
}

proc talk:addtalk { nick host handle chan text } {
	global talk
	if { [ regexp -nocase -- {(.+)\s--text\s(.+)} $text all match testo ] } {
		putlog "\037TALK\037 \002::\002 \037ADD\037 ($match $testo) added by $nick"
		set line "\n$match\t$testo"
		set mf [open $talk(talk_file) a]
		puts $mf $line
		close $mf
		lappend talk(matches) "$match\t$testo"
		putserv "NOTICE $nick :Talk aggiunta"
	} else {
		putserv "NOTICE $nick :\002Utilizzo:\002 !addtalk <parola> --text <testo>"
	}
}
### END PROCS ###

### CARICAMENTO ###
set mf [open $talk(talk_file) r]
while {![eof $mf]} {
	set line [gets $mf]
	lappend talk(matches) $line
}
close $mf

putlog "\037TALK\037 \002::\002 \037LOADED\037 version $talk(version) by lnx85"