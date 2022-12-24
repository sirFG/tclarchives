# Quotes-2112 - Copyright C.Leonhardt Nov.2006 rosc2112 at yahoo com http://members.dandy.net/~fbn/quotes2112.tcl.txt
set q2112ver "0.01h"
#
# Purpose: Stores quotes from users and shows them on command. 
#
# Features: Users can save/delete their own quotes.
#           Configurable permissions for adding/deleting quotes for other people or categories.
#           Configurable number of quotes to save (users and "categories" have seperate limits.)
#           Configurable command prefix, PRIVMSG/NOTICE, etc.
#           Logs adding/deleting quotes/categories into a "quotelog" section of the datafile.
#           Special "any" category for general, unlimited number of quotes.
#           Command to create/delete "categories" for quotes (deletes all quotes for category as well).
#           Command to list all "categories" by name.
#           Command to show quote from yourself by number or at random.
#           Command to show quote from username or category by number or at random.
#           Command to show quote randomly from entire datafile.
#           Command to show quote randomly from the "any" category.
#           Command to show all quotes for username or category (in privmsg).
#           Command to show all of your own quotes (in privmsg).
#           Command to search quote datafile by keywords/text string (results shown in privmsg).
#           Command to show statistics for all quotes in the datafile (total number of quotes, users/quotes, etc.)
#           Command to show the quotelog data (to those with permissions).
#           Quotes within a user's or category's saved quotes are automatically renumbered when one line is deleted.
#           Properly handles all tcl-special chars, so quotes can contain ANY input.
#
# Use: .quotehelp  -  Typed in channel or privmsg to the bot, show the full helpfile.
#
# Notes about "Categories" :
# Categories are special usernames/handles added to the bot, and named for the category they represent (such as, 
# history, sports, etc.) Its global flag is used to distinguish these from regular usernames (I use the flag "Q" 
# by default, but this is configurable below.)
#
# When reporting bugs, PLEASE include the .set errorInfo debug info! Read here: 
# http://forum.egghelp.org/viewtopic.php?t=10215
#
#
# History: Nov 10 2006 - Initial conception.
#          Nov 14 2006 - First release.
#                      - Fixed stats showing the "any" category under "Users."
#                      - Made permission configs both global and channel (channel flags will not work in privmsg, 
#                        only when commands are typed in channel.)
#                      - Added [nick2hand] to the quotelog lines, just to have the handle for the person..
#                      - Tweaked stats format a bit.
#                      - Made searches/string matches case-insensitive.
#                      - Added more verbose error msgs.
#         Nov 18 2006  - Added a total to the msg when saving a new quote (shows quotenumber/total-allowed)
#                      - Made config file a seperate file (requested by Dianora)
#                      - Added an array to the search function to show the quote's number from the name/category.
######################################################################################################################
# Configuration #
#---------------#

# You can download the default config file from:
# http://members.dandy.net/~fbn/quotes2112.cfg.txt

# You could also cut/paste the config file lines here, and remove the 'source' line below, if you prefer.

# The name of your configuration file:
source /home/geetob/scripts/quotes2112.cfg

#-------#-------------------------------------------------------------------------------------------------------------
# binds - Change the commandnames and bind permission flags here, if you wish (remember to change the helpfiles too)
#-------#

# command to view the helpfile
bind pub - ${qcomprefix}quotehelp proc:quotehelp
bind msg - ${qcomprefix}quotehelp proc:msgquotehelp

# command to get a quote
bind pub - ${qcomprefix}quote proc:quote
bind msg - ${qcomprefix}quote proc:msgquote

# command to list, search, view all quotes, etc
bind pub - ${qcomprefix}quotes proc:quotes
bind msg - ${qcomprefix}quotes proc:msgquotes

# command to add quotes for self
bind pub f|f ${qcomprefix}quoteme proc:quoteme
bind msg f|f ${qcomprefix}quoteme proc:msgquoteme

# command to add quotes for other people/categories
bind pub f|f ${qcomprefix}quoteadd proc:quoteadd
bind msg f|f ${qcomprefix}quoteadd proc:msgquoteadd

# command to delete quotes (for onesself, or other users/category with the permissions set above)
bind pub f|f ${qcomprefix}quotedel proc:quotedel
bind msg f|f ${qcomprefix}quotedel proc:msgquotedel

# command to add categories
bind pub n ${qcomprefix}quoteaddcat proc:quoteaddcat
bind msg n ${qcomprefix}quoteaddcat proc:msgquoteaddcat

# command to delete categories
bind pub n ${qcomprefix}quotedelcat proc:quotedelcat
bind msg n ${qcomprefix}quotedelcat proc:msgquotedelcat

# command to view/delete the quotelog
bind pub o|o ${qcomprefix}quotelog proc:quotelog
bind msg o|o ${qcomprefix}quotelog proc:msgquotelog

#######################################################################################################################
# Code begins #
#-------------#

proc proc:quote {nick uhost hand chan text} {
	global quotekeepuser quotecatflag quotekeepcat
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	if {([lsearch -exact $::quotequietchans $chan] != -1) || ($chan == "privmsg")} {set chan $nick}
	set text [split $text]
	set cmd [lindex [string tolower $text] 0]
	set param [lindex $text 1]
	set quotelines [readquotes 0]
	if {$cmd == "help"} {proc:msgquotehelp $nick $uhost $hand $text;return}
	if {$quotelines == "No quotes available."} {puthelp "$::qmsgtype $chan :$quotelines Sorry, $nick";return}
	if {[string is integer -strict $cmd]} {
		# quote by number for self
		if {($cmd < 1) || ($cmd > $quotekeepuser)} {
			puthelp "$::qmsgtype $nick :Quote requests by number for your own quotes must be a number from 1 to max $quotekeepuser."
			return
		} else {
			findquote $nick $chan $hand $cmd $quotelines
		}
	} elseif {[validuser $cmd]} {
		if {$param == ""} {
			# random quote by handle
			findquote $nick $chan $cmd "" $quotelines
		} elseif {[string is integer -strict $param]} {
			# quote by number for handle
			if {([matchattr $cmd $quotecatflag]) && (($param < 1) || ($param > $quotekeepcat))} {
				puthelp "$::qmsgtype $nick :Quote requests by number for categories must be a number from 1 to max $quotekeepcat"
				return
			} elseif {($param < 1) || ($param > $quotekeepuser)} {
				puthelp "$::qmsgtype $nick :Quote requests by number for usernames must be a number from 1 to max $quotekeepuser."
				return
			}
			findquote $nick $chan $cmd $param $quotelines
		}
	} elseif {$cmd == "any"} {
		if {$param == ""} {
			# random quote for "any" category
			findquote $nick $chan any "" $quotelines
		} elseif {[string is integer -strict $param]} {
			# quote by number for "any" category
			findquote $nick $chan any $param $quotelines
		}		
	} elseif {$cmd == "random"} {
		# random quote from entire file
		findquote $nick $chan "" random $quotelines
	} elseif {$cmd == ""} {
		# random quote for self
		findquote $nick $chan $hand "" $quotelines
	} else {
		# Did not understand request - show brief help
		puthelp "$::qmsgtype $nick :I didn't understand your request, try \002${::qcomprefix}quote help\002 for the helpfile."
		return
	}
}

proc proc:msgquote {nick uhost hand text} {
	# pass to proc:quote
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quote $nick $uhost $hand privmsg $text
	return
}	

proc proc:quotes {nick uhost hand chan text} {
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	if {([lsearch -exact $::quotequietchans $chan] != -1) || ($chan == "privmsg")} {set chan $nick}
	set cmd [lindex [string tolower $text] 0]
	set param [lrange $text 1 end]
	set quotelines [readquotes 0]
	if {$cmd == "help"} {proc:msgquotehelp $nick $uhost $hand $text;return}
	if {$quotelines == "No quotes available."} {puthelp "$::qmsgtype $chan :$quotelines Sorry $nick";return}
	if {($cmd == "stats")} {
		findquote $nick $chan "" $cmd $quotelines
	} elseif {($cmd == "search") || ($cmd == "categories")} {
		findquote $nick $chan $cmd $param $quotelines
	} elseif {([validuser $cmd]) || ($cmd == "any")} {
		findquote $nick $chan $cmd all $quotelines
	} elseif {$cmd == ""} {
		findquote $nick $chan $hand all $quotelines

	} else {
		puthelp "$::qmsgtype $nick :I didn't understand your request, try \002${::qcomprefix}quote help\002 for the helpfile."
		return
	}
}

proc proc:msgquotes {nick uhost hand text} {
	# pass to proc:quotes
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quotes $nick $uhost $hand privmsg $text
	return
}

proc findquote {nick chan handle search quotelines} {
	global quotecatflag qcomprefix
	set hquotes "";set categories ""
	if {($handle != "") && ($handle != "search") && ($handle != "categories")} {
		set hquotes [qnamesort $handle $quotelines]
	}
	if {($hquotes == "No quotes available.") || ($quotelines == "No quotes available.")} {
		puthelp "$::qmsgtype $chan :No quotes available for \002$handle\002, sorry."
		return
	}
	if {[string is integer -strict $search]} {
		# looking for a quote by number
		set quotetosend [lindex $hquotes [expr $search - 1]]
		if {$quotetosend != ""} {
			puthelp "$::qmsgtype $chan :Quote number $search for \002$handle\002: [join [lrange [split $quotetosend] 1 end]]"
			return
		} else {
			puthelp "$::qmsgtype $chan :No quote number $search found for \002$handle\002."
			return
		}
	} elseif {$search == "all"} {
		# Want all quotes for handle/category
		set lineno 0
		foreach line $hquotes {
			incr lineno
			puthelp "$::qmsgtype $nick :Quote number $lineno for \002$handle\002: [join [lrange [split $line] 1 end]]"
		}
		if {$lineno > 0} {
			puthelp "$::qmsgtype $nick :\[end of quotes from \002$handle\002\]"
			return
		} else {
			puthelp "$::qmsgtype $nick :No quotes found from \002$handle\002"
			return
		}
	} elseif {$search == "random"} {
		# Want a random quote from anywhere
		set randquote [lindex $quotelines [rand [llength $quotelines]]]
		set quotename [lindex [split $randquote :] 0]
		set quotetext [lrange [split $randquote] 1 end]
		puthelp "$::qmsgtype $chan :Random quote from \002$quotename\002: [join $quotetext]"
		return
	} elseif {$search == "stats"} {
		# count total number of quotes, figure out how many quotes per user..
		set quotetot [llength $quotelines]
		set catmatch "";set showcat "";set usermatch "";set showuser "";set showcatmp "";set showusertmp ""
		set qntmp "";set qtnum ""
		foreach line $quotelines {
			# set an array, stuff a name in it, increment a number per name
			set qntmp [lindex [split $line :] 0]
			if {[array names qtname $qntmp] == ""} {
				array set qtname "$qntmp 1"
			} else {
				set qtnum [lindex [array get qtname $qntmp] 1]
				incr qtnum
				array set qtname "$qntmp $qtnum"
			}
		}
		foreach {name count} [array get qtname] {
			if {([matchattr $name $quotecatflag]) || ($name == "any")} {
				set catmatch "$name\:\002$count\002"
				lappend showcatmp $catmatch
			} else {
				set usermatch "$name\:\002$count\002"
				lappend showusertmp $usermatch
			}
		}
		array unset qtname
		if {$showcatmp != ""} {
			set showcat "Quotes per Categories: [lsort -dictionary $showcatmp]"
		} else { 
			set showcat "Quotes per Categories: None saved"
		}
		if {$showusertmp != ""} {
			set showuser "Quotes per User: [lsort -dictionary $showusertmp]"
		} else {
			set showuser "Quotes per User: None saved"
		}
		puthelp "$::qmsgtype $chan :Quote statistics: Total Quotes Saved: \002$quotetot\002  -=-  [join $showcat]  -=-  [join $showuser]"
		return
	} elseif {$handle == "search"} {
		if {$search != ""} {
			# looking for a quote by search term
			set lineno 0;set qntmp "";set qtnum ""
			foreach line $quotelines {
				set qntmp [lindex [split $line :] 0]
				if {[array names qtname $qntmp] == ""} {
					array set qtname "$qntmp 1"
				} else {
					set qtnum [lindex [array get qtname $qntmp] 1]
					incr qtnum
					array set qtname "$qntmp $qtnum"
				}
				if {[string match -nocase *$search* $line]} {
					incr lineno
					set quotename $qntmp
					set quotetext [lrange [split $line] 1 end]
					puthelp "$::qmsgtype $nick :Quote search for \002$search\002:\[Name:\002$quotename\002 Number:\002[lindex [array get qtname $qntmp] 1]\002\]: [join $quotetext]"
				}
			}
			if {$lineno != 0} {
				puthelp "$::qmsgtype $nick :\[end of search matches for \002$search\002\]"
				return
			} else {
				puthelp "$::qmsgtype $chan :No quotes found containing \002$search\002."
				return
			}
			array unset qtname
		} else {puthelp "$::qmsgtype $nick :You didn't supply a search keyword! Usage: \002${qcomprefix}quotes search <keyword or search string>";return}
	} elseif {$handle == "categories"} {
		set categories [userlist $quotecatflag]
		if {$categories != ""} {
			puthelp "$::qmsgtype $chan :Quote Categories: \002$categories\002"
			return
		} else {
			puthelp "$::qmsgtype $chan :No quote categories have been created yet."
			return
		}
	} else {
		# looking for a random quote by handle
		set randquote [lindex $hquotes [rand [llength $hquotes]]]
		puthelp "$::qmsgtype $chan :Random quote from \002$handle\002: [join [lrange [split $randquote] 1 end]]"
		return
	}
}

proc readquotes {quotelog} {
	global quotefile
	if {![file exists $quotefile]} {return "No quotes available."}
	set quotelines ""
	set inqfile [open $quotefile r]
	set quotetemp [split [read $inqfile] \n]
	catch {close $inqfile}
	foreach line $quotetemp {
		if {$line != ""} {
			if {$quotelog} {
				lappend quotelines $line
			} else {
				if {![string match "quotelog:*" $line]} {
					lappend quotelines $line
				}
			}
		}
	}
	if {$quotelines != ""} {
		return $quotelines
	} else {
		return "No quotes available."
	}
}

proc qnamesort {handle quotelines} {
	set quotematches ""
	foreach line $quotelines {
		if {[string match -nocase $handle [lindex [split $line :] 0]]} {
			if {$line != ""} {
				lappend quotematches $line
			}
		}
	}
	if {$quotematches != ""} {return $quotematches} else {return "No quotes available."}
}

proc proc:quoteme {nick uhost hand chan text} {
	global quotemeperm
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	if {![matchattr $hand $quotemeperm $chan]} {
		puthelp "$::qmsgtype $nick :You don't have permissions to add quotes for yourself, sorry $nick!"
		return
	}
	set text [string trim $text]
	if {($text == "help") || ($text == "")} {
		puthelp "$::qmsgtype $nick :To add a quote for yourself: \002${::qcomprefix}quoteme <quote to add>\002 - Type \002${::qcomprefix}quotehelp\002 for more help."
		return
	}
	proc:quotewrite $nick $hand user $text
	return
}

proc proc:msgquoteme {nick uhost hand text} {
	# pass to proc:quoteme
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quoteme $nick $uhost $hand privmsg $text
	return
}

proc proc:quoteadd {nick uhost hand chan text} {
	global quoteaddcatqperm quoteadduserperm quoteaddanyperm quotecatflag
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	if {(![matchattr $hand $quoteaddcatqperm $chan]) && (![matchattr $hand $quoteadduserperm $chan]) && (![matchattr $hand $quoteaddanyperm $chan])} {
		puthelp "$::qmsgtype $nick :You don't have permissions to add quotes, sorry $nick!"
		return
	}
	set text [string trim $text];set text [split $text]
	if {$text == "help"} {proc:msgquotehelp $nick $uhost $hand $text;return}
	set qname [lindex [split $text :] 0]
	set qtext [lrange $text 1 end]
	if {$qtext == ""} {puthelp "$::qmsgtype $nick :How about giving me a quote to add? :P Try \002${::qcomprefix}quoteadd <username|category>: <quote to add>\002";return}
	if {$qname == "any"} {
		if {[matchattr $hand $quoteaddanyperm $chan]} {
			# add to the "any" category
			proc:quotewrite $nick $qname any [join $qtext]
		} else {
			puthelp "$::qmsgtype $nick :You don't have permissions to add quotes to the \002any\002 category."
			return
		}
	} elseif {[matchattr $qname $quotecatflag]} {
		if {[matchattr $hand $quoteaddcatqperm $chan]} {
			# add to a category
			proc:quotewrite $nick $qname category [join $qtext]
		} else {
			puthelp "$::qmsgtype $nick :You don't have permissions to add quotes to the \002$qname\002 category."
			return
		}
	} elseif {([validuser $qname]) && (![matchattr $qname $quotecatflag])} {
		if {[matchattr $hand $quoteadduserperm $chan]} {
			# adding to a users quotes
			proc:quotewrite $nick $qname user [join $qtext]
		} else {
			puthelp "$::qmsgtype $nick :You don't have permissions to add quotes for users."
			return
		}
	} else {
		puthelp "$::qmsgtype $nick :You didn't provide a valid username, category or the \"any\" category name. To add a quote: \002${::qcomprefix}quoteadd <username|category>: <quote to add>\002"
		puthelp "$::qmsgtype $nick :  Example: ${::qcomprefix}quoteadd sports: This is a quote for the sports category."
		return
	}
}

proc proc:msgquoteadd {nick uhost hand text} {
	# pass to proc:quoteadd
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quoteadd $nick $uhost $hand privmsg $text
}

proc proc:deleteq {nick hand number} {
	global quotefile
	set quotelines [readquotes 1]
	set lineno -1;set matchno 0;set gotmatch 0
	foreach line $quotelines {
		incr lineno
		if {([string match -nocase $hand [lindex [split $line :] 0]])} {
			incr matchno
			if {$matchno == $number} {
				set gotmatch 1
				set quotelines [lreplace $quotelines $lineno $lineno]
				lappend quotelines "quotelog: [ctime [unixtime]] - $nick \([nick2hand $nick]\) deleted quote number $number from '$hand' - Quote: [join [lrange [split $line] 1 end]]"
				break
			}
		}
	}
	if {$gotmatch} {
		set quotewrite [open $quotefile w]
		foreach line $quotelines {
			set line [string trim $line]
			if {$line != ""} {
				puts $quotewrite $line
			}
		}
		catch {close $quotewrite}
		puthelp "$::qmsgtype $nick :Deleted quote number $number for \002$hand\002"
		puthelp "$::qmsgtype $nick :Remember, quotes are automatically renumbered when you delete one."
	} else {
		puthelp "$::qmsgtype $nick :No quote number $number found for \002$hand\002"
	}
}

proc proc:quotedel {nick uhost hand chan text} {
	global quotecatflag quotedeluserperm quotedelcatqperm quotedelanyperm quotekeepuser quotekeepcat quotemeperm
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	set text [string trim $text]
	if {([string is integer -strict $text]) && ([matchattr $hand $quotemeperm $chan])} {
		if {($text < 1) || ($text > $quotekeepuser)} {
			puthelp "$::qmsgtype $nick :Erm.. Quotes are numbered from 1 to $quotekeepuser (max)..Try again :P"
			puthelp "$::qmsgtype $nick :To delete one of your own quotes: \002${::qcomprefix}quotedel <quotenumber>\002"
			return
		}
		proc:deleteq $nick $hand $text
		return
	}
	set delname [lindex [split $text :] 0]
	set delnum [lindex [split $text :] 1];set delnum [string trim $delnum]
	if {$delname == "any"} {
		if {[matchattr $hand $quotedelanyperm $chan]} {
			if {(![string is integer -strict $delnum]) || ($delnum < 1)} {
				puthelp "$::qmsgtype $nick :To delete a quote from the 'any' category: \002${::qcomprefix}quotedel any: <quotenumber>\002"
				return
			}
			proc:deleteq $nick any $delnum
			return
		} else {
			puthelp "$::qmsgtype $nick :You don't have permissions to delete quotes from the \002any\002 category."
			return
		}
	} elseif {[matchattr $delname $quotecatflag]} {
		if {[matchattr $hand $quotedelcatqperm $chan]} {
			if {(![string is integer -strict $delnum]) || ($delnum < 1) || ($delnum > $quotekeepcat)} {
				puthelp "$::qmsgtype $nick :Erm.. Quotes for categories are numbered from 1 to $quotekeepcat (max)..Try again :P"
				puthelp "$::qmsgtype $nick :To delete a quote from the '$delname' category: \002${::qcomprefix}quotedel $delname: <quotenumber>\002"
				return
			}
			proc:deleteq $nick $delname $delnum
			return
		} else {
			puthelp "$::qmsgtype $nick :You don't have permissions to delete quotes from the \002$delname\002 category."
			return
		}
	} elseif {(![matchattr $delname $quotecatflag]) && ([validuser $delname])} {
		if {[matchattr $hand $quotedeluserperm $chan]} {
			if {(![string is integer -strict $delnum]) || ($delnum < 1) || ($delnum > $quotekeepuser)} {
				puthelp "$::qmsgtype $nick :Quotes for users are numbered from 1 to $quotekeepuser (max)..Try again.."
				puthelp "$::qmsgtype $nick :To delete a quote for '$delname': \002${::qcomprefix}quotedel $delname: <quotenumber>\002"
				return
			}
			proc:deleteq $nick $delname $delnum
			return
		} else {
			puthelp "$::qmsgtype $nick :You don't have permissions to delete quotes for users."
			return
		}
	} elseif {([matchattr $hand $quotemeperm $chan]) || ([matchattr $hand $quotedelcatqperm $chan]) || ([matchattr $hand $quotedeluserperm $chan])} {
		puthelp "$::qmsgtype $nick :I did not understand your request.."
		puthelp "$::qmsgtype $nick :To delete one of your own quotes: \002${::qcomprefix}quotedel <quotenumber>\002"
		if {[matchattr $hand $quotedeluserperm $chan]} {
			puthelp "$::qmsgtype $nick :To delete a quote for another user: \002${::qcomprefix}quotedel username: <quotenumber>\002"
		}
		if {[matchattr $hand $quotedelcatqperm $chan]} {
			puthelp "$::qmsgtype $nick :To delete a quote from a category: \002${::qcomprefix}quotedel categoryname: <quotenumber>\002"
		}
		return
	}
}

proc proc:msgquotedel {nick uhost hand text} {
	# pass to proc:quotedel
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quotedel $nick $uhost $hand privmsg $text
	return
}

proc proc:quoteaddcat {nick uhost hand chan text} {
	global quotecatflag quoteaddcatperm quotefile
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	if {![matchattr $hand $quoteaddcatperm $chan]} {return}
	if {([regexp {[^A-Za-z0-9]} $text]) || ([string length $text] < 1) || ([string length $text] > 9)} {
		puthelp "$::qmsgtype $nick :Category names may only contain letters and numbers, and must be less than 9 characters long (eggdrop's username length limit!)"
		return
	}	
	if {[validuser $text]} {puthelp "$::qmsgtype $nick :That name is already used! Category names must be unique.";return}
	set randpass [expr { int(987536 * rand()) }]
	adduser $text
	setuser $text PASS $randpass
	setuser $text XTRA quotes-2112 "category $text"
	chattr $text +${quotecatflag}dkqru
	save
	set quotewrite [open $quotefile a]
	puts $quotewrite "quotelog: [ctime [unixtime]] - $nick \([nick2hand $nick]\) created quote category '$text'"
	catch {close $quotewrite}
	puthelp "$::qmsgtype $nick :Added category name \002$text\002"
}

proc proc:msgquoteaddcat {nick uhost hand text} {
	# pass to proc:quoteaddcat
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quoteaddcat $nick $uhost $hand privmsg $text
	return
}

proc proc:quotedelcat {nick uhost hand chan text} {
	global quotedelcatperm quotecatflag quotefile
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	if {[matchattr $hand $quotedelcatperm $chan]} {
		if {[matchattr $text $quotecatflag]} {
			# delete the quotes from the file first
			set lineno -1;set cqmatch ""
			set quotelines [readquotes 1]
			foreach line $quotelines {
				incr lineno
				if {[string match -nocase "$text" [lindex [split $line :] 0]]} {
					lappend cqmatch $lineno
				}
			}
			if {$cqmatch != ""} {
				set cqmatch [lsort -integer -decreasing $cqmatch]
				foreach number $cqmatch {
					set quotelines [lreplace $quotelines $number $number]
				}
			}
			# log it, write it..
			lappend quotelines "quotelog: [ctime [unixtime]] - $nick \([nick2hand $nick]\) deleted quote category '$text'"
			set quotewrite [open $quotefile w]
			foreach line $quotelines {
				set line [string trim $line]
				if {$line != ""} {
					puts $quotewrite $line
				}
			}
			catch {close $quotewrite}
			deluser $text
			save
			puthelp "$::qmsgtype $nick :Deleted category \002$text\002"
		} else {puthelp "$::qmsgtype $nick :Could not find a category named \002$text\002";return}
	}
}

proc proc:msgquotedelcat {nick uhost hand text} {
	# pass to proc:quotedelcat
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quotedelcat $nick $uhost $hand privmsg $text
	return
}

proc proc:quotewrite {nick hand type text} {
	global quotefile quotekeepuser quotekeepcat quotelength
	# types are user, category or "any" 
	if {$type == "user"} {
		set quotelimit $quotekeepuser
	} elseif {$type == "category"} {
		set quotelimit $quotekeepcat
	} else {
		# close enough to unlimited for the "any" category..Make this limit larger if you need to. :P
		set quotelimit 10000
	}
	set quotelines [readquotes 1]
	if {$quotelines == "No quotes available."} {
		set quotelines ""
	}
	set text [string trim $text]
	if {$text == ""} {puthelp "$::qmsgtype $nick :Quote was an empty string.. Try \002${::qcomprefix}quotehelp\002";return}
	set quotesave [split $text]
	if {[string length $text] > $quotelength} {
		puthelp "$::qmsgtype $nick :Quotes must be less than \002$quotelength chars\002 long. Try making your quote shorter."
		return
	}
	set quotesort "";set lineno 0
	if {$quotelines != ""} {
		foreach line $quotelines {
			if {[string match -nocase $hand [lindex [split $line :] 0]]} {
				incr lineno
				if {$lineno >= $quotelimit} {
					puthelp "$::qmsgtype $nick :I can't add more quotes for \002$hand\002 (\002max $quotelimit\002 quotes allowed) - Delete something to add a new quote! :P"
					return
				}
			}
			set line [split $line]
			set qusername [lindex [split $line :] 0]
			set qtext [lrange $line 1 end]
			set quotesortmp "$qusername $qtext"
			lappend quotesort $quotesortmp
		}
	}
	lappend quotesort "$hand $quotesave"
	lappend quotesort "quotelog: [ctime [unixtime]] - $nick \([nick2hand $nick]\) saved quote number [expr $lineno + 1] for '$hand' - Quote: $quotesave"
	set quotesort [lsort -dictionary -index 0 $quotesort]
	set quotewrite [open $quotefile w]
	foreach line $quotesort {
		set line [string trim $line]
		if {$line != ""} {
			set line "[lindex $line 0]: [join [lrange $line 1 end]]"
			puts $quotewrite $line
		}
	}
	catch {close $quotewrite}
	puthelp "$::qmsgtype $nick :Saved quote number \002[expr $lineno + 1]\002/$quotelimit for \002$hand\002: [join $quotesave]"
}

proc proc:quotelog {nick uhost hand chan text} {
	global quotelogperm quotelogdelperm quotefile
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	if {![matchattr $hand $quotelogperm $chan]} {return}
	set quotelines [readquotes 1]
	if {$quotelines == "No quotes available."} {puthelp "$::qmsgtype $nick :No quotelog data found. Sorry, $nick";return}
	if {($text == "delete") && ([matchattr $hand $quotelogdelperm $chan])} {
		set lineno -1
		set qlmatch ""
		foreach line $quotelines {
			incr lineno
			if {[string match "quotelog" [lindex [split $line :] 0]]} {
				lappend qlmatch $lineno
			}
		}
		if {$qlmatch != ""} {
			set qlmatch [lsort -integer -decreasing $qlmatch]
			foreach number $qlmatch {
				set quotelines [lreplace $quotelines $number $number]
			}
			set quotewrite [open $quotefile w]
			foreach line $quotelines {
				set line [string trim $line]
				if {$line != ""} {
					puts $quotewrite $line
				}
			}
			catch {close $quotewrite}
			puthelp "$::qmsgtype $nick :Deleted quotelog.."
		} else {puthelp "$::qmsgtype $nick :No quotelog data found to delete!"}
		return
	}
	set lineno 0
	foreach line $quotelines {
		if {[string match "quotelog:*" $line]} {
			incr lineno
			putquick "$::qmsgtype $nick :$line"
		}
	}
	if {$lineno > 0} {
		puthelp "$::qmsgtype $nick :\[end of quotelog data\]"
	} else {
		puthelp "$::qmsgtype $nick :No quotelog data found.."
	}
}

proc proc:msgquotelog {nick uhost hand text} {
	# pass along to proc:quotelog
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quotelog $nick $uhost $hand privmsg $text
	return
}

proc proc:quotehelp {nick uhost hand chan text} {
	global quotekeepuser quotemeperm quoteadduserperm quoteaddcatqperm quoteaddanyperm quotedeluserperm quotedelcatqperm quotedelanyperm quotelogperm quoteaddcatperm quotedelcatperm quotelogdelperm
	if {([lsearch -exact $::quotechans $chan] == -1) && ($chan != "privmsg")} {return}
	puthelp "$::qmsgtype $nick :Quotes-2112 $::q2112ver by \002Rosc\002 - Commands are typed in channel or in privmsg to $::botnick"
	puthelp "$::qmsgtype $nick : Parameters shown in \002<>\002 are required. Options divided by \002|\002 means \002OR\002: <this\002|\002that>"
	puthelp "$::qmsgtype $nick : Note: 'usernames' are as known in $::botnick\'s userlist, NOT users public IRC nicknames."
	if {[matchattr $hand $quotemeperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002add\002 a quote for yourself: \002${::qcomprefix}quoteme <quote to add>\002"
	}
	if {[matchattr $hand $quoteadduserperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002add\002 a quote for another username: \002${::qcomprefix}quoteadd <username>: <quote to add>\002"
	}
	if {[matchattr $hand $quoteaddcatqperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002add\002 a quote for a category: \002${::qcomprefix}quoteadd <categoryname>: <quote to add>\002"
	}

	if {[matchattr $hand $quoteaddanyperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002add\002 a quote for the \"any\" category: \002${::qcomprefix}quoteadd any: <quote to add>\002"
	}
	if {[matchattr $hand $quoteaddcatperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002add\002 a quote \002category\002: \002${::qcomprefix}quoteaddcat <category-name>\002"
	}
	if {[matchattr $hand $quotemeperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002delete\002 one of your quotes: \002${::qcomprefix}quotedel <quotenumber>\002"
	}
	if {[matchattr $hand $quotedeluserperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002delete\002 a quote for another username: \002${::qcomprefix}quotedel <username>: <quotenumber>\002"
	}
	if {[matchattr $hand $quotedelcatqperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002delete\002 a quote from a category: \002${::qcomprefix}quotedel <categoryname>: <quotenumber>\002"
	}
	if {[matchattr $hand $quotedelanyperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002delete\002 a quote from the \"any\" category: \002${::qcomprefix}quotedel any: <quotenumber>\002"
	}

	if {[matchattr $hand $quotedelcatperm $chan]} {
		puthelp "$::qmsgtype $nick :To \002delete\002 a category and all quotes in it: \002${::qcomprefix}quotedelcat <category-name>\002"
	}
	puthelp "$::qmsgtype $nick :To \002search\002 for quotes by keyword/text string: \002${::qcomprefix}quotes search <keyword>\002"
	puthelp "$::qmsgtype $nick :   Example: \002${::qcomprefix}quotes search little bunny fufu\002 shows all quotes with \"little bunny fufu\""
	puthelp "$::qmsgtype $nick :To show \002stats\002 (total quotes, quotes per user, etc): \002${::qcomprefix}quotes stats\002"
	puthelp "$::qmsgtype $nick :To show \002list\002 of quote categories: \002${::qcomprefix}quotes categories\002"
	puthelp "$::qmsgtype $nick :To show \002all\002 of your saved quotes: \002${::qcomprefix}quotes\002"
	puthelp "$::qmsgtype $nick :To show \002all\002 quotes by username or category: \002${::qcomprefix}quotes <username|category>\002"
	puthelp "$::qmsgtype $nick :To show a random quote from yourself: \002${::qcomprefix}quote\002"
	puthelp "$::qmsgtype $nick :To show a random quote from all quotes: \002${::qcomprefix}quote random\002"
	puthelp "$::qmsgtype $nick :To show a random quote from the \"any\" category: \002${::qcomprefix}quote any\002"
	puthelp "$::qmsgtype $nick :To show a random quote from a username or category: \002${::qcomprefix}quote <username|category>\002"
	puthelp "$::qmsgtype $nick :To show a quote from yourself by number: \002${::qcomprefix}quote <number>\002"
	puthelp "$::qmsgtype $nick :To show a quote from a username or category by number: \002${::qcomprefix}quote <username|category> <number>\002"
	puthelp "$::qmsgtype $nick :To show a quote from the \"any\" category by number: \002${::qcomprefix}quote any <number>\002"
	if {[matchattr $hand $quotelogperm $chan]} {
		puthelp "$::qmsgtype $nick :To show the quotelog: \002${::qcomprefix}quotelog\002"
	}
	if {[matchattr $hand $quotelogdelperm $chan]} {
		puthelp "$::qmsgtype $nick :To delete the quotelog: \002${::qcomprefix}quotelog delete\002"
	}
	puthelp "$::qmsgtype $nick :\[end of Quotes-2112 help\]"
}

proc proc:msgquotehelp {nick uhost hand text} {
	if {(![onchan $nick]) && (![validuser $nick])} {return}
	proc:quotehelp $nick $uhost $hand privmsg $text
	return
}

putlog "Quotes-2112 $q2112ver by rosc loaded."
