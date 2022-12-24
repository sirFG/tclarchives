################################################### QUOTE TCL V1.1.0.a #######
#
################################################### DEFAULT COMMANDS AND INFO #########
#
#
# !quote(s) <num>
# ### Displays a random quote or the number specified.
# ### Default access: Everyone
#
# !addquote <quote>
# ### This adds quotes to the storage file, quotes can contain any type of character.
# ### Default access: global/channel +o OR +Q globally.
#
# !delquote <num>
# ### Deletes the quote number specified.
# ### Default access: global/channel +o OR +Q globally.
#
# !selquote <num>
# ### Prints out the specified quote number.
# ### Default access: Everyone
#
# !findquote <word>
# ### Searches for the word in the storage file, parses the results to a
# ### text file, and sends the user the results.
# ### Default access: Everyone
#
# !lastquote
# ### Displays the last quote added.
# ### Default access: Everyone
#
# !quotehelp
# ### Sends the user the quote help file. 
# ### Default access: Everyone
#
# !getquotes
# ### Sends the user the quote storage file.
# ### Default access: Everyone
#
# !getscript
# ### Sends the user the quote script.
# ### Default access: Everyone
#
# !quotestats
# ### Shows how many quotes there are and how big the quote storage file is.
# ### Default access: Everyone.
#
# !quoteversion
# ### Displays the quote version and author name. :)
# ### Default access: Everyone
#
################################################### DEFAULT COMMANDS AND INFO #########


################################################### SETTINGS ##########################
#
# Select this to your perferred command prefix, "" is acceptable.
	set qot(cmd) "!"
#
# File name of the storage file for added quotes.
	set qot(file) "quote.txt"
#
# File name of the backup store file for added quotes.
        set qot(backup) "quote.txt.bak"
#
# Access required to read quotes & access help. (Probably don't need
# to change this.)
	set qot(readflag) "-"
#
# Access required to add quotes, "-" is everyone. Note: If a user has any
# of these flags, he/she can add quotes.
	set qot(addflag) "-"
#
# Access required to delete quotes. Note: If a user has any of these flags,
# he/she can delete quotes.
	set qot(delflag) "-"
#
# This settings is used for flood protection, in the form x:y. Any queries 
# beyond x in y seconds is considered a flood and the user is ignored.
	set qot(flood) 4:15
#
# Switch for ignoring flooders if they violate qot(flood) (1=On, 0=Off)
	set qot(ignore) 1
#
# This is used to set the amount of time a flooder is  ignored (minutes). This
# value is useless if qot(ignore) is set to 0.
	set qot(ignore_time) 5
#
# Access needed to send/recieve quote file.
	set qot(dccflag) "-|-"
#
# Access needed to restore the backed up quote file.
	set qot(mergflag) "Qm|-"
#
# Number of quotes to show
	set qot(quoteshow) "3"

################################################### SETTINGS ##########################

#### BINDINGS 

### PUBLIC COMMANDS BINDINGS
set quotefile news.txt

# 0 = display quotes in channel
# 1 = display quotes via private notice.
set quotevianotice 0

bind pub - !news quote:pub:quote
## Random quote bindings
bind pub $qot(readflag) [string trim $qot(cmd)]news qot_random
bind pub $qot(readflag) [string trim $qot(cmd)]news qot_random
## Add quote bindings
bind pub $qot(addflag) [string trim $qot(cmd)]anews qot_addquote
## Delete quote bindings
bind pub $qot(delflag) [string trim $qot(cmd)]dnews qot_del
## Select quote bindings
bind pub $qot(readflag) [string trim $qot(cmd)]snews qot_sel
## Search quote bindings
bind pub $qot(readflag) [string trim $qot(cmd)]fnews qot_src
bind pub $qot(readflag) [string trim $qot(cmd)]fnews qot_src
## Help bindings
bind pub $qot(readflag) [string trim $qot(cmd)]nhelp qot_help
bind pub $qot(readflag) [string trim $qot(cmd)]nhelp qot_help
## Miscellaneous bindings
bind pub $qot(readflag) [string trim $qot(cmd)]nver qot_ver
bind pub $qot(readflag) [string trim $qot(cmd)]tnews qot_total
bind pub $qot(readflag) [string trim $qot(cmd)]nstats qot_total
bind pub $qot(readflag) [string trim $qot(cmd)]lnews qot_last



#####################################################################

##### TCL PROCEDURES ################################################

##### MISC TCL SHIT #################################################

set qot(vershort) "1.1.0.a"
set qot(script) "scripts/quote_tcl-$qot(vershort).tcl"
set qot(package) "scripts/quote_tcl-$qot(vershort).tar.gz"
putlog "News TCL version $qot(vershort) loaded."

proc check_string {text} {
  regsub -all ">" $text "" text
  regsub -all "<" $text "" textews
  regsub -all "|" $text "" text
  regsub -all "&" $text "" text

  return $text
} 

proc qot_flood_init {} {
  global qot qot_flood_array ; if {![string match *:* $qot(flood)]} {putcmdlog "News TCL: var qot(flood) not set correctly." ; return}
  set qot(flood_num) [lindex [split $qot(flood) :] 0] ; set qot(flood_time) [lindex [split $qot(flood) :] 1] ; set i [expr $qot(flood_num) - 1]
  while {$i >= 0} {set qot_flood_array($i) 0 ; incr i -1 ; }
} ; qot_flood_init

proc qot_flood {nick uhost} {
  global qot qot_flood_array ; if {$qot(flood_num) == 0} {return 0} ; set i [expr $qot(flood_num) - 1]
  while {$i >= 1} {set qot_flood_array($i) $qot_flood_array([expr $i - 1]) ; incr i -1} ; set qot_flood_array(0) [unixtime]
  if {[expr [unixtime] - $qot_flood_array([expr $qot(flood_num) - 1])] <= $qot(flood_time)} {putcmdlog "News TCL: Flood detected from $nick. Ignoring for $qot(ignore_time) minutes." ; if {$qot(ignore)} {newignore [maskhost [getchanhost $nick]] News-TCL "$nick flooded the news script." $qot(ignore_time)} ; return 1
  } {return 0}
}

# moretools stuff... reason why they're here is to make the script easier for people to load. from mc.moretools1.2.tcl by MC_8

proc strip:color {ar} {
 set argument ""
 if {![string match *\003* $ar]} {return $ar} ; set i -1 ; set length [string length $ar]
 while {$i < $length} {
  if {[string index $ar $i] == "\003"} {
   set wind 1 ; set pos [expr $i+1]
   while {$wind < 3} {
    if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
     incr wind 1 ; incr pos 1} {set wind 3
    }
   }
   if {[string index $ar $pos] == "," && [string index $ar [expr $pos + 1]] <= 9 &&
       [string index $ar [expr $pos + 1]] >= 0} {
    set wind 1 ; incr pos 1
    while {$wind < 3} {
     if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
      incr wind 1 ; incr pos 1} {set wind 3
     }
    }
   }
   if {$i == 0} {
    set ar [string range $ar $pos end]
    set length [string length $ar]
   } {
    set ar "[string range $ar 0 [expr $i - 1]][string range $ar $pos end]"
    set length [string length $ar]
   }
   set argument "$argument[string index $ar $i]"
  } {incr i 1}
 }
 set argument $ar
 return $argument
}

proc strip:bold {ar} {
 set argument ""
 if {[string match *\002* $ar]} {
  set i 0
  while {$i <= [string length $ar]} {
   if {![string match \002 [string index $ar $i]]} {
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc strip:uline {ar} {
 set argument ""
 if {[string match *\037* $ar]} {
  set i 0
  while {$i <= [string length $ar]} {
   if {![string match \037 [string index $ar $i]]} {
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc strip:reverse {ar} {
 set argument ""
 if {[string match *\026* $ar]} {
  set i 0
  while {$i <= [string length $ar]} {
   if {![string match \026 [string index $ar $i]]} {
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc strip:all {ar} {
 return [strip:reverse [strip:uline [strip:bold [strip:color $ar]]]]
}

proc bold {} {return \002}
proc reverse {} {return \026}
proc color {} {return \003}
proc underline {} {return \037}

#### PUBLIC COMMANDS PROCEDURESS ######################################

proc qot_random {nick uhost hand chan rest} {
    global qot
    if {[qot_flood $nick $uhost]} {return 0}
    if {![file exists $qot(file)]} {
	putquick "PRIVMSG $chan :Error: No news found--file does not exist"
	return
    } else {
    set qot_fd [open $qot(file) r]
    } 
    for {set qot_cnt 0} { ![eof $qot_fd] } { incr qot_cnt } {
	gets $qot_fd qot_list($qot_cnt)
    }
    close $qot_fd
    if {$rest==""} {
    set qot_cnt [expr $qot_cnt - 2]
    set qot_sel $qot_list([set qot_cur [rand [expr $qot_cnt + 1]]])
    putquick "PRIVMSG $chan :News (4#[bold][expr $qot_cur + 1]/[expr $qot_cnt + 1][bold]1): $qot_sel"
    } else { 
    if {[string is integer $rest]} {
    set qot_cnt [expr $qot_cnt - 2]
    unset qot_list([expr $qot_cnt + 1])
    if {![info exists qot_list([expr {$rest} - 1])]} {
        putquick "PRIVMSG $chan :Error: that news does not exist"
        return
    } else {
    set qot_sel $qot_list([expr {$rest} - 1])
    putquick "PRIVMSG $chan :News (4#[bold]$rest/[expr $qot_cnt + 1][bold]1): $qot_sel"
    return }}}
}

proc qot_sel {nick uhost hand chan rest} {
    global qot
    if {[qot_flood $nick $uhost]} {return 0}
    if {![file exists $qot(file)]} {
	putquick "PRIVMSG $chan :Error: No news found--file does not exist"
	return
    }
    set qot_fd [open $qot(file) r]
    for {set qot_cnt 0} { ![eof $qot_fd] } { incr qot_cnt 1 } {
	gets $qot_fd qot_list($qot_cnt)
    }
    close $qot_fd
    set qot_cnt [expr $qot_cnt - 2]
    unset qot_list([expr $qot_cnt + 1])
    if {![info exists qot_list([expr {$rest} - 1])]} {
	putquick "PRIVMSG $chan :Error: that news does not exist"
	return
    } else {
    set qot_sel $qot_list([expr {$rest} - 1])
    putquick "PRIVMSG $chan :News [bold]$rest[bold] of [bold][expr $qot_cnt + 1][bold]: $qot_sel"
    return
    }
    returnews

proc quote:pub:quotef {nick uhost hand chan arg} {
 global quotefile quotevianotice
 set quotes ""
 if { [file exists $quotefile] } { set file [open $quotefile r] 
 } else {
  if { $quotevianotice == 0 } { putmsg $chan "$quotefile does not exist. You'll need to add news to the database first by typing \002!addnews <a news>\002" }
  if { $quotevianotice == 1 } { putnotc $nick "$quotefile does not exist. You'll need to add news to the database first by typing \002!addnews <a news>\002" }
  return 0
 }
 while { ![eof $file] } {
  set quote [gets $file]
  if { $quote != "" } {
   set quotes [linsert $quotes end $quote]
  }
 }
 close $file
 if { $arg != "" } {
  set pattern [string tolower $arg]
  set aquotes ""
  set quote ""
  foreach quote $quotes {
   set lowquote [string tolower $quote]
   if { [string match $pattern $lowquote] } {
    set aquotes [linsert $aquotes end $quote]
   }
   set quotes ""
   set quotes $aquotes
  }
 }
 set row [rand [llength $quotes]]
 if { [expr $row >= 0] && [expr $row < [llength $quotes]] } {
  set quote [lindex $quotes $row]
 }
 if { $quote != "" } {
  if { $quotevianotice == 0 } {
   putmsg $chan "News: $quote"
  }
  if { $quotevianotice == 1 } {
   putnotc $nick "$quote"
  }
 }
 return 1
}


proc qot_src {nick uhost hand chan rest} {
if {$rest == ""} { 
	putquick "PRIVMSG $chan :Searching for something does require a word to search for..."
	break
}
    global qot
    set checked [check_string $rest]
    if {[qot_flood $nick $uhost]} {return 0}
    set qot_src(file) "results-$nick-$rest.txt"
    exec grep -i -n "$checked" $qot(file) > $qot_src(file)
     set fp [open $qot_src(file) r]
     set data [read $fp]
     close $fp
	set data [split $data "\n"]
	set total 0

set number 0
set totalkeys ""
	foreach line $data {
set i [string first ":" $line] 
set key [string range $line 0 [expr $i - 1]] 
	set totalkeys "$totalkeys $key"
	}

     foreach line $data {
set i [string first ":" $line] 
set key [string range $line 0 [expr $i - 1]] 
set value [string range $line [expr $i + 1] end] 
set numqdata($key) $value


	if { $line=="" } {
	break
 	} else {
	putquick "PRIVMSG $chan :News (4#[bold]$key[bold]1): $numqdata($key)"
	set number [expr $number + 1]

	if {$number == $qot(quoteshow)} { 
	putquick "PRIVMSG $chan :And again all of them: $totalkeys" 
	break
	}

	}
     }
 
    exec rm -f $qot_src(file)
    putcmdlog "<<$nick>> !$hand! Searched for a news in $chan." 
    return 
}

proc qot_addquote {nick uhost hand chan rest} {
    global qot
    set stripped [strip:all $rest]
    set qot_fd [open $qot(file) a+]
    puts $qot_fd $stripped
    close $qot_fd
    putquick "PRIVMSG $chan :News has been added to storage file."
    putcmdlog "<<$nick>> !$hand! Added a news in $chan."
    exec cp "$qot(file)" "$qot(backup)"
    return
}

proc qot_del {nick uhost hand chan rest} {

	if {![isop $nick $chan]} { break }

    global qot
    set delnum $rest
    set type [lindex $rest 0]
    set rest [lrange $rest 1 end]
    if {![file exists $qot(file)]} {
	putquick "PRIVMSG $chan :Error: No news found--file does not exist"
	return
    } else {
	set qot_fd [open $qot(file) r]
    }
    for {set qot_cnt 0} { ![eof $qot_fd] } { incr qot_cnt 1 } {
	gets $qot_fd qot_list($qot_cnt)
    }
    close $qot_fd
    set qot_cnt [expr $qot_cnt - 2]
    if {[string is integer $delnum]} {
        set qot_fd [open $qot(file) w]
        for { set i 0 } { $i <= $qot_cnt } { incr i 1 } {
	    if {($qot_list($i) == "") || ($i == [expr $delnum - 1])} {
		putquick "PRIVMSG $chan :News [expr $i + 1] deleted"
                putcmdlog "<<$nick>> !$hand! Deleted a news in $chan."
		continue                
	    } else {
		puts $qot_fd $qot_list($i)
	    }
	}
	close $qot_fd
    } else {
    if {$type == "num"} {
	set qot_fd [open $qot(file) w]
	for { set i 0 } { $i <= $qot_cnt } { incr i 1 } {
	    if {($qot_list($i) == "") || ($i == [expr $rest - 1])} {
		putquick "PRIVMSG $chan :News [expr $i + 1] deleted"
                putcmdlog "<<$nick>> !$hand! Deleted a news in $chan."
		continue
	    } else {
		puts $qot_fd $qot_list($i)
	    }
	}
	close $qot_fd
    }
    return
}}

proc qot_get {nick uhost hand chan args} {
    global qot
    if {[qot_flood $nick $uhost]} {return 0}
    putcmdlog "<<$nick>> !$hand! Requested the news storage file in $chan"
    putquick "NOTICE $nick :Sending the news storage file."
    return
}

proc qot_script {nick uhost hand chan args} {
    global qot
    if {[qot_flood $nick $uhost]} {return 0}
    putcmdlog "<<$nick>> !$hand! Requested the news script package in $chan"
    putquick "NOTICE $nick :Sending the quote_tcl-$qot(vershort).tar.gz package."
    return 
}

proc qot_help {nick uhost hand chan rest} {
    global qot
    set qot(helpfile) "quote_help.txt"
    if {[qot_flood $nick $uhost]} {return 0}
    putquick "NOTICE $nick :Sending the News TCL Help file."
    return
}

proc qot_total {nick uhost hand chan rest} {
    global qot
    if {[qot_flood $nick $uhost]} {return 0}
    set qot(byte_size) [file size $qot(file)]
    set qot(kb_size) [expr $qot(byte_size) / 1024]
    if {![file exists $qot(file)]} {
        putchan $chan "Error: No news found--file does not exist"
        return
    } else {
    set qot(cnt) [exec grep -c "" $qot(file)]
    putquick "PRIVMSG $chan :[bold]$qot(cnt)[bold] news total using [bold]$qot(kb_size)kb[bold]."
}}

proc qot_ver {nick uhost hand chan rest} {
    global qot
    if {[qot_flood $nick $uhost]} {return 0}
    putquick "PRIVMSG $chan :News TCL[bold] v$qot(vershort)[bold]"
}

proc qot_last {nick uhost hand chan arg} {
    global qot
    if {[qot_flood $nick $uhost]} {return 0}
    if {![file exists $qot(file)]} {
        putchan $chan "Error: No news found--file does not exist"
        return
    } else {
    set qot_fd [open $qot(file) r]
    }
    for {set qot_cnt 0} { ![eof $qot_fd] } { incr qot_cnt } {
        gets $qot_fd qot_list($qot_cnt)
    }
    close $qot_fd
    set qot_cnt [expr $qot_cnt - 2]    
    set qot(last) $qot_list([expr $qot_cnt])
    putquick "PRIVMSG $chan :[bold]Last News ([expr $qot_cnt + 1]):[bold] $qot(last)"
    return 
}