#######################################################################################################
## BlackWeather.tcl 1.2  (25/05/2021)  			  		  Copyright 2008 - 2021 @ WwW.TCLScripts.NET ##
##                        _   _   _   _   _   _   _   _   _   _   _   _   _   _                      ##
##                       / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \                     ##
##                      ( T | C | L | S | C | R | I | P | T | S | . | N | E | T )                    ##
##                       \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/                     ##
##                                                                                                   ##
##                                      ® BLaCkShaDoW Production ®                                   ##
##                                                                                                   ##
##                                              PRESENTS                                             ##
##									                           ® ##
##########################################  BLACK WEATHER TCL   #######################################
##									                           									     ##
##  DESCRIPTION: 							                             ##
##  Displays real-time weather conditions, local time from any city in the world. 					 ##
##									                             ##
##  Supports US Zipcode, UK Postcode, Canada Postalcode or worldwide city name.                      ##
##									                             ##
##  Few of the available variable: max./min. and 'feels like' temperatures, wind speed,,local time   ##
##                                                                     ##
##									                             ##
##  ATTENTION: search does not support diacritic markst as: á, é, í, ó, ú, ü, ñ, ¿, ¡, etc.          ##
##									                             ##
##  Tested on Eggdrop v1.8.3 (Debian Linux 3.16.0-4-amd64) Tcl version: 8.6.6                        ##
##									                             ##
#######################################################################################################
##									                             ##
##                                 /===============================\                                 ##
##                                 |      This Space For Rent      |                                 ##
##                                 \===============================/                                 ##
##									                             ##
#######################################################################################################
##									                           									     ##
##  INSTALLATION: 							                             							 ##
##     ++ http package is REQUIRED for this script to work.                           		     ##
##     ++ json package is REQUIRED for this script to work.                           		     ##
##     ++ Edit the BlackWeather.tcl script and place it into your /scripts directory,                ##
##     ++ add "source scripts/BlackWeather.tcl" to your eggdrop config and rehash the bot.           ##
##									                             									 ##
#######################################################################################################
#######################################################################################################
##									                             ##
##  OFFICIAL LINKS:                                                                                  ##
##   E-mail      : BLaCkShaDoW[at]tclscripts.net                                                     ##
##   Bugs report : http://www.tclscripts.net                                                         ##
##   GitHub page : https://github.com/tclscripts/ 			                             ##
##   Online help : irc://irc.undernet.org/tcl-help                                                   ##
##                 #TCL-HELP / UnderNet        	                                                     ##
##                 You can ask in english or romanian                                                ##
##									                             ##
##     paypal.me/DanielVoipan = Please consider a donation. Thanks!                                  ##
##									                             ##
#######################################################################################################
##									                             ##
##                           You want a customised TCL Script for your eggdrop?                      ##
##                                Easy-peasy, just tell me what you need!                            ##
##                I can create almost anything in TCL based on your ideas and donations.             ##
##                  Email blackshadow@tclscripts.net or info@tclscripts.net with your                ##
##                    request informations and I'll contact you as soon as possible.                 ##
##									                             ##
#######################################################################################################
##									                           									     ##
##  To activate: .chanset +weather | from BlackTools: .set #channel +weather                         ##
##                                                                                                   ##
##  !w [?|help] - shows all available commands.                                                  	 ##
##                                                                                                   ##
##  !w [set] [nick|zipcode|city,state|city,state,country|airport]                       		     ##
##                                                                                                   ##
##  !time [nick|zipcode|city,state|city,state,country|airport]                                       ##
##                                          - returns a default user local time.                     ##
##                                                                                                   ##
##  !w version - shows the actual weather script version.                                  	         ##
##                                                                                                   ##
##  Supports: US Zipcode, UK Postcode, Canada Postalcodes or worldwide city name.                    ##
##                                                                                                   ##
##  ATTENTION: search does not support diacritic markst as: á, é, í, ó, ú, ü, ñ, ¿, ¡, etc.          ##
##                                                                                                   ##
#######################################################################################################                                                                                                 ##
#######################################################################################################
##									                         									     ##
##  LICENSE:                                                                                         ##
##   This code comes with ABSOLUTELY NO WARRANTY.                                                    ##
##                                                                                                   ##
##   This program is free software; you can redistribute it and/or modify it under the terms of      ##
##   the GNU General Public License version 3 as published by the Free Software Foundation.          ##
##                                                                                                   ##
##   This program is distributed WITHOUT ANY WARRANTY; without even the implied warranty of          ##
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                                            ##
##   USE AT YOUR OWN RISK.                                                                           ##
##                                                                                                   ##
##   See the GNU General Public License for more details.                                            ##
##        (http://www.gnu.org/copyleft/library.txt)                                                  ##
##                                                                                                   ##
##  			          Copyright 2008 - 2021 @ WwW.TCLScripts.NET              		             ##
##                                                                                                   ##
#######################################################################################################
#######################################################################################################
##                                   CONFIGURATION FOR BlackWeather.TCL                              ##
#######################################################################################################

###
# Channel flags
# - to activate the script:
# .set +weather or .chanset #channel +weather
#
###

###
# Cmdchar trigger
# - set here the trigger you want to use.
###
set weather(cmd_char) "!"

###
#Api keys from http://api.weatherstack.com 
#(works with multiple keys now)
###
set weather(nr_id)  {
"ebe14f63b36d2663ea85a0010f490e04"
#"key2"
}

###
#Default units type (m - metric, f - fahrenheit)
#
###
set weather(units_type) "m"

###
#Use weather short output ?
# 0 - yes ; 1 - no
###
set weather(short_out) "1"

###
# User db file
# - specifies the file where all users weather locations are stored.
###
set weather(user_file) "scripts/Blackweather.users.txt"

###
# FLOOD PROTECTION
#Set the number of minute(s) to ignore flooders, 0 to disable flood protection
###
set weather(ignore_prot) "1"

###
# FLOOD PROTECTION
#Set the number of requests within specifide number of seconds to trigger flood protection.
# By default, 4:10, which allows for upto 3 queries in 10 seconds. 4 or more quries in 10 seconds would cuase
# the forth and later queries to be ignored for the amount of time specifide above.
###
set weather(flood_prot) "3:10"


#######################################################################################################
###                       DO NOT MODIFY HERE UNLESS YOU KNOW WHAT YOU'RE DOING                      ###
#######################################################################################################

setudef flag weather

bind pubm - * weather:get

###
	package require tls
	package require http
	package require json

if {![file exists $weather(user_file)]} {
	set file [open $weather(user_file) w]
	close $file
}

proc weather:get {nick host hand chan arg} {
	global weather black
if {![channel get $chan weather]} {
	return
}
	set first_cmd [lindex [split $arg] 0]
if {[string match -nocase "$weather(cmd_char)w" $first_cmd]} {
	set cmd_type 0
} elseif {[string match -nocase "$weather(cmd_char)time" $first_cmd]} {
	set cmd_type 1
} else { return }
	set flood_protect [weather:flood:prot $chan $host]
if {$flood_protect == "1"} {
	set get_seconds [weather:get:flood_time $host $chan]
	weather:say $nick $chan [list $get_seconds "6" $nick] 0
	return
}
	set cmd [lindex [split $arg] 1]
	set location [lrange [split $arg] 1 end]
	set setup_location [join [lrange [split $arg] 2 end]]
	set slocation [join $setup_location "%20"]
	switch $cmd {
	set {
if {$setup_location == ""} {
	weather:say $nick $chan $weather(cmd_char) 7
	return
		}
	set units [weather:get_units $setup_location]
	set units_type [lindex $units 0]
	set units_specified [lindex $units 1]
	set new_loc [lindex $units 2]
	weather:say $nick $chan [list $nick $new_loc $units_type] 8
	weather:setlocation $nick $host $chan $setup_location
	}
	
	? {
	weather:say $nick $chan $weather(cmd_char) 10
	}
	
	version {
	weather:say $nick $chan $weather(cmd_char) version
	}
	
	default {
if {$cmd == ""} {
	set getlocation [weather:getlocation $nick $host $chan]
	set units [weather:get_units $getlocation]
	set units_type [lindex $units 0]
	set units_specified [lindex $units 1]
	set new_loc [lindex $units 2]
if {$units_specified == "1"} {
	set getlocation [join $new_loc "%20"]
} else {
	set getlocation [join $getlocation "%20"]
}
	
if {$getlocation == "0"} {
	weather:say $nick $chan [list $nick $weather(cmd_char)] 9
				} else {
	weather:getinfo $nick $chan $getlocation $units_type $cmd_type
				}
			} else {
if {[onchan $cmd $chan]} {
	set get_host [getchanhost $cmd $chan]
	set getlocation [weather:getlocation $nick $get_host $chan]
	set units [weather:get_units $getlocation]
	set units_type [lindex $units 0]
	set units_specified [lindex $units 1]
	set new_loc [lindex $units 2]
if {$units_specified == "1"} {
	set getlocation [join $new_loc "%20"]
} else {
	set getlocation [join $getlocation "%20"]
}
if {$getlocation == "0"} {
	weather:say $nick $chan [list $cmd ] 11
	return
}
	weather:getinfo $nick $chan $getlocation $units_type $cmd_type
	return
}
	set units [weather:get_units $location]
	set units_type [lindex $units 0]
	set units_specified [lindex $units 1]
	set new_loc [lindex $units 2]
if {$units_specified == "1"} {
	set location [join $new_loc "%20"]
} else {
	set location [join $location "%20"]
}
	weather:getinfo $nick $chan $location $units_type $cmd_type
			}
		}
	}
}

###
proc weather:get_units {location} {
	global weather
	set units ""
if {[regexp {[,]} $location]} {
	set units [string trimleft [lindex [weather:wsplit $location ","] 1] " "]
switch [concat $units] {
	m {
	set location [regsub -all {\s+} [lindex [weather:wsplit $location ","] 0] " "]
	return [list m 1 $location]
			}
	f {
	set location [regsub -all {\s+} [lindex [weather:wsplit $location ","] 0] " "]
	return [list f 1 $location]
			}
	default {
	set location [regsub -all {\s+} [lindex [weather:wsplit $location ","] 0] " "]
	return [list $weather(units_type) 0 $location]
			}
		}
	} else {
	return [list $weather(units_type) 0 $location]
	}	
}

###
proc weather:getinfo {nick chan location units cmd_type} {
	global weather
if {![info exists weather(id_num)]} {
	set weather(id_num) 0
}
	set data [weather:getdata $chan $location $units $weather(id_num)]
	set error [weather:getjson "error" $data]
if {$error != ""} {
	incr weather(id_num)
if {[lindex $weather(nr_id) $weather(id_num)] != ""} {
	weather:getinfo $nick $chan $location $units $cmd_type
	return
	} else {
	unset weather(id_num)
}
	set error_text [lindex $error 5]
	weather:say $nick $chan [list $error_text] 6
	return
}
	set location [weather:getjson "location" $data]
	set name [encoding convertfrom utf-8 [lindex $location 1]]
	set country [encoding convertfrom utf-8 [lindex $location 3]]
	set region [encoding convertfrom utf-8 [lindex $location 5]]
	set lat [lindex $location 7]
	set lon [lindex $location 9]
	set latlon [join "$lat $lon" ", "]
if {[string equal -nocase $name $region] || $region == ""} {
	set get_location [join [list $name $country] ", "]
} else {
	set get_location [join [list $name $region $country] ", "]
}
	set timezone [lindex $location 11]
	set get [catch {exec env TZ=$timezone date -R | tr -s " "} dat]
	set dat [join [lreplace [split $dat " "] 5 5]]
	set clock_scan [clock scan $dat -format "%a, %e %b %Y %H:%M:%S"]
	set day [clock format $clock_scan -format %A]
	set localtime [clock format $clock_scan -format "%d %b %Y %R"]
if {$cmd_type == "1"} {
	weather:say $nick $chan [list $get_location $latlon $localtime $day] 3
	return
}
	set current [weather:getjson "current" $data]
	set feelslike_temp [lindex $current 25]
	set cloud_cover_percent [lindex $current 19]
	set humidity [lindex $current 21]
	set wind_dir [lindex $current 15]
	set wind_speed [lindex $current 11]
	set pressure [lindex $current 17]
	set precip [lindex $current 19]
	set uv [lindex $current 23]
	set desc [join [lindex $current 9]]
	set temp [lindex $current 3]
	set observation_time [lindex $current 1]
if {$weather(short_out) == "0"} {
if {$units == "m"} {
	weather:say $nick $chan [list $get_location $latlon $desc $feelslike_temp] 1
	} else {
	weather:say $nick $chan [list $get_location $latlon $desc $feelslike_temp] 2
		}
	} else {
if {$units == "m"} {
	weather:say $nick $chan [list $get_location $latlon $temp $feelslike_temp $humidity $wind_dir $wind_speed $pressure $cloud_cover_percent $uv $observation_time $precip $desc] 4
} else {
	weather:say $nick $chan [list $get_location $latlon $temp $feelslike_temp $humidity $wind_dir $wind_speed $pressure $cloud_cover_percent $uv $observation_time $precip $desc] 5
		}		
	}
}

###
proc weather:say {nick chan arg num} {
	global black
	set inc 0
foreach s $arg {
	set inc [expr $inc + 1]
	set replace(%msg.$inc%) $s
}
	set reply [string map [array get replace] $black(weather.en.$num)]
	putserv "PRIVMSG $chan :$reply"
}

###
proc weather:getlocation {nick host chan} {
	global black weather
	set file [open $weather(user_file) "r"]
	set read_location ""
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
	set read_host [lindex [split $line] 2]
if {[string equal -nocase $enc_chan $chan] && [string match -nocase $host $read_host]} {
	set read_location [join [lrange [split $line] 3 end]]
	}
}
	close $file
if {$read_location == ""} {
	return 0
	} else {
	return $read_location
	}
}

###
proc weather:getdata {chan location units num} {
	global weather black
	set wid [lindex $weather(nr_id) $num]
	set weatherlink "http://api.weatherstack.com/current?access_key=${wid}&query=$location&units=$units"
	set ipq [http::config -useragent "lynx"]
	set ipq [::http::geturl "$weatherlink" -timeout 10000] 
	set data [http::data $ipq]
	::http::cleanup $ipq
	return $data
}

###
proc weather:getjson {get data} {
	global weather
	set parse [::json::json2dict $data]
	set return ""
foreach {name info} $parse {
if {[string equal -nocase $name $get]} {
	set return $info
	break;
		}
	}
	return $return
}

###
proc weather:flood:prot {chan host} {
	global weather
	set number [scan $weather(flood_prot) %\[^:\]]
	set timer [scan $weather(flood_prot) %*\[^:\]:%s]
if {[info exists weather(flood:$host:$chan:act)]} {
	return 1
}
foreach tmr [utimers] {
if {[string match "*weather:remove:flood $host $chan*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
	}
}
if {![info exists weather(flood:$host:$chan)]} { 
	set weather(flood:$host:$chan) 0 
}
	incr weather(flood:$host:$chan)
	utimer $timer [list weather:remove:flood $host $chan]	
if {$weather(flood:$host:$chan) > $number} {
	set weather(flood:$host:$chan:act) 1
	utimer 60 [list weather:expire:flood $host $chan]
	return 1
	} else {
	return 0
	}
}

###
proc weather:expire:flood {host chan} {
	global black weather
if {[info exists weather(flood:$host:$chan:act)]} {
	unset weather(flood:$host:$chan:act)
	}
}

###
proc weather:remove:flood {host chan} {
	global black weather
if {[info exists weather(flood:$host:$chan)]} {
	unset weather(flood:$host:$chan)
	}
}

###
proc weather:get:flood_time {host chan} {
	global weather
		foreach tmr [utimers] {
if {[string match "*weather:expire:flood $host $chan*" [join [lindex $tmr 1]]]} {
	return [lindex $tmr 0]
		}
	}
}

###
proc weather:test_alpha {string} {
	global weather
	set return 0
	for {set i 0} {$i < [string length $string]} {incr i} {
    set char [string index $string $i]
    if {[regexp -all {[a-zA-Z0-9]} $char]} {
        continue
    } else {
        set return 1
		break;
		}
	}
	return $return
}

###
set weather(projectName) "Weather Forecast"


#http://wiki.tcl.tk/989
###
proc weather:wsplit {string sep} {
    set first [string first $sep $string]
    if {$first == -1} {
        return [list $string]
    } else {
        set l [string length $sep]
        set left [string range $string 0 [expr {$first-1}]]
        set right [string range $string [expr {$first+$l}] end]
        return [concat [list $left] [weather:wsplit $right $sep]]
    }
}

###
proc weather:setlocation {nick host chan location} {
	global black weather
	set file [open $weather(user_file) "r"]
	set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
	set temp "weather_temp.$timestamp"
	set tempwrite [open $temp w]
while {[gets $file line] != -1} {
	set read_chan [lindex [split $line] 0]
	set enc_chan [encoding convertfrom utf-8 $read_chan]
	set read_host [lindex [split $line] 2]
if {[string equal -nocase $enc_chan $chan] && [string match -nocase $host $read_host]} {
	continue
	} else {
	puts $tempwrite $line
	}	
}
	close $tempwrite
	close $file
    file rename -force $temp $weather(user_file)
	
	set file [open $weather(user_file) a]
	puts $file "$chan $nick $host $location"
	close $file
}

set grade_sign [encoding convertfrom "utf-8" "°"]
set black(weather.en.1) "\002%msg.1%\002 (%msg.2%) -- %msg.3% and %msg.4%$grade_sign C"
set black(weather.en.2) "\002%msg.1%\002 (%msg.2%) -- %msg.3% and %msg.4%$grade_sign F"
set black(weather.en.3) "\002%msg.1%\002 (%msg.2%) -- \002%msg.4%\002, %msg.3%"
set black(weather.en.4) "\002%msg.1%\002 (%msg.2%) -- %msg.13% and %msg.3%$grade_sign C | \002Feels Like\002: %msg.4%$grade_sign C | \002Humidity\002: %msg.5%% | \002Wind\002: %msg.6% @ %msg.7% KPH | \002Pressure\002: %msg.8%mb | \002Clouds\002: %msg.9%% |  \002Rainfall\002: %msg.12%% | \002UV Index\002: %msg.10% | \002Observation time\002: %msg.11%"
set black(weather.en.5) "\002%msg.1%\002 (%msg.2%) -- %msg.13% and %msg.3%$grade_sign F | \002Feels Like\002: %msg.4%$grade_sign F | \002Humidity\002: %msg.5%% | \002Wind\002: %msg.6% @ %msg.7% MPH | \002Pressure\002: %msg.8%in | \002Clouds\002: %msg.9%% |  \002Rainfall\002: %msg.12%% | \002UV Index\002: %msg.10% | \002Observation time\002: %msg.11%"
set black(weather.en.6) "\002Error\002: %msg.1%"
set black(weather.en.7) "SYNTAX: \002%msg.1%w set <location,(m/f)>\002 to set one."
set black(weather.en.8) "\002%msg.1%\002: your default location saved as:\002 %msg.2%\002 with \002%msg.3%\002 unit."
set black(weather.en.9) "\002%msg.1%\002: no location found linked to your nick. To link one, use: \002%msg.2%w set <location,(m/f)>\002"
set black(weather.en.10) "SYNTAX: \002%msg.1%w <location>\002 to get the live weather."
set black(weather.en.11) "No location found linked to \002%msg.1%\002."
set black(weather.en.version) "\002$weather(projectName)\002"

putlog "\002$weather(projectName) $weather(version)\002: Loaded & initialised.."

#######################
#######################################################################################################
###                  *** END OF BlackWeather TCL ***                                                ###
#######################################################################################################
