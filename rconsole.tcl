#################################################################################
#                                                                               #
# rconsole.tcl - full remote control/console for eggdrop by demond@demond.net   #
#                                                                               #
#                this thing utilizes the botnet to open a remote console to     #
#                any linked bot; why would I need that, you ask... well, for    #
#                starters, it eliminates the need of DCC CHAT, telnet, .relay   #
#                to the bot you need to control - now you can control all of    #
#                your leafs from the hub's console, conveniently issuing just   #
#                a single command which will get replicated and executed on     #
#                all remote consoles you've opened; think also of all firewall  #
#                problems you circumvent with this thing - it enables you with  #
#                full access to any bot on your botnet, regardless whether its  #
#                host is firewalled or not                                      #
#                                                                               #
#                so how is this different from the netbots script? well, unlike #
#                netbots, rconsole gives you full remote access to any eggdrop  #
#                command, not just to a predefined and limited set of custom    #
#                netbots commands; that being said, it should be noted that     #
#                rconsole is not meant as substitution of netbots - you may     #
#                find it most useful when used alongside netbots, although it   #
#                implements full botnet control by itself                       #
#                                                                               #
#                naturally, rconsole supports multiple users simultaniously,    #
#                that is, any user can open a remote console independently of   #
#                other users logged into the bot                                #
#                                                                               #
#                please note that you need to load this script both on the bot  #
#                which will serve rconsole (remote bot) and on the bot which    #
#                will initiate a request and will be a client for rconsole      #
#                (local bot); better load it on each bot in the botnet for      #
#                total control                                                  #
#                                                                               #
#         Usage: .rc <bot|*> [command|text]  ("*" is used to send to all bots)  #
#                                                                               #
#                when used without command/text, it sends initial login request #
#                                                                               #
#       History: 1.0 - initial version                                          #
#                                                                               #
#                1.1 - added rci command, usage: .rci <bot|*> <infocmd>         #
#                     (type .rci for more information on info commands)         #
#                                                                               #
#                1.2 - bugfixes                                                 #
#                                                                               #
#                1.3 - code cleanup, more rci commands                          #
#                                                                               #
#                1.4 - bugfixes, code cleanup                                   #
#                                                                               #
#                1.5 - implemented rconsole groups and multiple .rc bots spec   #
#                     (.rc <bot|bot1,bot2|group#|*> [command|text], see below)  #
#                                                                               #
#                1.6 - added more rci commands (ch, gr)                         #
#                                                                               #
#                1.7 - implemented botnet traffic encryption                    #
#                                                                               #
#################################################################################

package require Tcl 8.0
package require eggdrop 1.6

# change this if you are in heterogenous botnet (see below)
#
set rconsole "rconsole"

namespace eval $rconsole {

# DCC commands for controlling rconsole
#
variable rcc "rc"
variable rci "rci"

# define your encryption key here if you want 
# rconsole botnet traffic secured by blowfish
#
#variable key "secret"

# define your rconsole groups here, sets of bots to control with .rc by index
# for example, `.rc 1 .command' will send .command to Bot1, Bot2 and Bot3
#
#set group(1) {Bot1 Bot2 Bot3}
#set group(2) {Bot4 Bot5}

# change these if you are in heterogenous botnet environment (i.e. not all bots
# are yours) and other people run their own rconsole scripts for their own bots
#
variable rca "rca"
variable rcq "rcq"
variable rcs "rcs"

# don't edit below unless you know what you're doing

variable version "rconsole-1.7"

variable icmds {os up rc ch gr}

bind dcc - $rcc [namespace current]::rccmd
bind dcc m $rci [namespace current]::rcicmd
bind bot - $rcq [namespace current]::gotrcq
bind bot - $rca [namespace current]::gotrca
bind bot - $rcs [namespace current]::gotrcs
bind chon - *   [namespace current]::chonoff
bind chof - *   [namespace current]::chonoff

putlog "$version by demond loaded"

proc log {text} {
	variable version
	putloglev 4 * "$version: $text"
}

proc putallbots {text} {
	variable key
	if [info exists key] {
		foreach {cmd idx} [split $text] {break}
		set text [join [lrange [split $text] 2 e]]
		::putallbots "$cmd $idx [encrypt $key $text]"
	} {
		::putallbots $text
	}
}

proc putbot {bot text} {
	variable key
	if [islinked $bot] {
	if [info exists key] {
		foreach {cmd idx} [split $text] {break}
		set text [join [lrange [split $text] 2 e]]
		::putbot $bot "$cmd $idx [encrypt $key $text]"
	} {
		::putbot $bot $text
	}}
}

proc getlocal {} {
	variable my-ip
	set ip ""; set port ""
	foreach e [dcclist telnet] {
		if {[lindex $e 1] == "(telnet)" || [lindex $e 1] == "(users)"} {
			set port [lindex [lindex $e 4] 1]; break
		}
	}
	if {$port != ""} {
		set ip "localhost"
		if {${::my-hostname} != ""} {set ip ${::my-hostname}}
		if {${::my-ip} != ""}       {set ip ${::my-ip}}
		if [info exists my-ip]      {set ip ${my-ip}}
	}
	return $ip:$port
}

proc rccmd {hand idx text} {
	variable group
	variable rcq; variable rcc
	if {$text == ""} {
		putdcc $idx "Usage: .$rcc <bot|bot1,bot2,...|group#|*> \[command|text\]"
		putdcc $idx "Description: this will send a bot command or text to:"
		putdcc $idx "  single bot, several bots, bot group specified, or all bots"
		putdcc $idx "  (use without command|text argument to log into remote bot(s))"
		return 0
	}
	if [info exists ::botnet-nick] {set me ${::botnet-nick}} {set me $::nick}
	set bot [lindex [split $text] 0]
	if [string equal -nocase $bot $me] {
		putdcc $idx "I'm not a remote bot, doofus"
		return 0
	}
	if [string is integer $bot] {
		if [info exists group($bot)] {
			set bots $group($bot)
		} {
			putdcc $idx "no such group $bot"
			return 0
		}
	} {
		set bots [split $bot ,]
	}
	if {[llength $bots] == 1 && $bot != "*" && ![islinked $bot]} {
		putdcc $idx "$bot is not on the botnet"
		return 0
	}
	set text [join [lrange [split $text] 1 e]]
	if {[llength $bots] != 1} {
		foreach bot $bots {
			putbot $bot "$rcq $idx $text"
		}
	} {
		if {$bot == "*"} {
			putallbots "$rcq $idx $text"
		} {
			putbot $bot "$rcq $idx $text"
		}
	}
	if {$text == "" || [string index $text 0] == "."} {
		set nolog {tcl set newpass chpass}
		set cmd ""; scan [string range $text 1 e] %s cmd
		if {[lsearch -exact $nolog $cmd] == -1} {return 1}
	}
	return 0
}

proc rcicmd {hand idx text} {
	variable icmds; variable group
	variable rcs; variable rci
	if {$text == ""} {
		putdcc $idx "Usage: .$rci <bot|bot1,bot2,...|group#|*> <[join $icmds |]>"
		putdcc $idx "Description: obtain info from me or remote bot(s):"
		putdcc $idx "  os - operating system's version, host uptime & load averages"
		putdcc $idx "  up - uptimes of the bot and its IRC server connection"
		putdcc $idx "  rc - who is currently using remote console(s) and from where"
		putdcc $idx "  ch - current channel status for bot's network"
		putdcc $idx "  gr - list defined bot controlling groups, if any"
		return 0
	}
	if [info exists ::botnet-nick] {set me ${::botnet-nick}} {set me $::nick}
	set bot [lindex [split $text] 0]
	if [string is integer $bot] {
		if [info exists group($bot)] {
			set bots $group($bot)
		} {
			putdcc $idx "no such group $bot"
			return 0
		}
	} {
		set bots [split $bot ,]
	}
	if {[llength $bots] == 1} {
	if {$bot != "*" && ![string equal -nocase $bot $me] && ![islinked $bot]} {
		putdcc $idx "$bot is not on the botnet"
		return 0
	}}
	set text [join [lrange [split $text] 1 e]]
	if {[lsearch -exact $icmds $text] == -1} {
		putdcc $idx "wrong infocmd, must be one of: [join $icmds ,]"
		return 0
	}
	if {[llength $bots] != 1} {
		if {[lsearch -exact [string tolower $bots] [string tolower $me]] != -1} {
			putdcc $idx "<$me> [getinfo $text]"
		}
		foreach bot $bots {
			putbot $bot "$rcs $idx $text"
		}
	} {
		if {$bot == "*" || [string equal -nocase $bot $me]} {
			putdcc $idx "<$me> [getinfo $text]"
			if {$bot != "*"} {return 1}
		}
		if {$bot == "*"} {
			putallbots "$rcs $idx $text"
		} {
			putbot $bot "$rcs $idx $text"
		}
	}
	return 1
}

proc gotrcq {from cmd text} {
	variable handle; variable key
	variable rca; variable pairs
	set idx [lindex [split $text] 0]
	set text [join [lrange [split $text] 1 e]]
	if [info exists key] {
		set text [decrypt $key $text]
	}
	set lidx [which loc $idx $from]
	if {$text == ""} {
		if {$lidx != ""} {
			putbot $from "$rca $idx *** Already logged in as $handle($lidx)"
			return
		}
		if {[set local [getlocal]] == ":"} {
			putbot $from "$rca $idx *** Can't log in, no local listen port"
			return
		} {
			scan $local {%[^:]:%d} ip port
			control [set lidx [connect $ip $port]] [namespace current]::ctrl
			lappend pairs($from) [list $lidx $idx]
			log "allocated pairs($from) \{$lidx $idx\}"
			set handle($lidx) "*"
		}
	} {
		if {$lidx == ""} {
			putbot $from "$rca $idx *** Not logged in yet, log in first"
			return
		} {
			if {$handle($lidx) == "*"} {
				set handle($lidx) $text
			}
			putdcc $lidx $text
		} 
	}
}

proc gotrca {from cmd text} {
	variable key
	set idx [lindex [split $text] 0]
	set text [join [lrange [split $text] 1 e]]	
	if [info exists key] {
		set text [decrypt $key $text]
	}
	putdcc $idx "<$from> $text"
}

proc ctrl {idx text} {
	variable rca
	if {$text != ""} {
		scan [which rem $idx] {%[^:]:%d} bot ridx
		putbot $bot "$rca $ridx $text"
	} {
		which kill $idx	
	}
}

proc chonoff {hand idx} {
	variable rcs
	putallbots "$rcs $idx drop"
}

proc duration {ts} {
	set days [expr $ts / 86400]
	set hour [expr ($ts % 86400) / 3600]
	set mins [expr (($ts % 86400) % 3600) / 60]
	if $days {set res "$days days, "} {set res ""}
	append res [format %02d:%02d $hour $mins]
}

proc getinfo {cmd} {
	variable group
	variable pairs; variable handle
	switch $cmd {
	"os" {
		set stat "$::tcl_platform(os) $::tcl_platform(osVersion)"
		if {$::tcl_platform(platform) == "unix"} {
			append stat " [exec hostname] [exec uptime]"
		}
	}
	"up" {
		if ${::server-online} {
			set connected [duration [expr [unixtime] - ${::server-online}]]
			append connected " on $::server"
		} {
			set connected "<offline>"
		}
		set uptime [duration [expr [unixtime] - $::uptime]]
		set stat "up: $uptime; conn: $connected"
	}
	"rc" {
		set stat "rconsoles: "
		foreach {bot elist} [array get pairs] {
			set users {}
			foreach e $elist {
				lappend users $handle([lindex $e 0])
			}
			set users [join $users ,]
			append stat "$bot\($users\) "
		}
	}
	"ch" {
		if [info exists ::network] {set stat "\[$::network\]"} {set stat "\[unknown\]"}
		if ${::server-online} {
			set chans {}
			foreach c [channels] {
				if ![botonchan $c] {
					lappend chans "${c}(trying!)"
				} elseif {![botisop $c]} {
					lappend chans "${c}(wantops!)"
				} {
					lappend chans "${c}"
				}
			}
			append stat " [join $chans ,]"
		} {
			append stat " <offline>"
		}
	}
	"gr" {
		set stat "groups: "
		if [info exists group] {
			foreach {num blist} [array get group] {
				append stat "($num)[join $blist ,] "
			}
		}
	}}
	return $stat
}

proc gotrcs {from cmd text} {
	variable rca; variable key
	set idx [lindex [split $text] 0]
	set cmd [join [lrange [split $text] 1 e]]
	if [info exists key] {
		set cmd [decrypt $key $cmd]
	}
	switch $cmd {
	"drop" {
		if {[set lidx [which loc $idx $from]] != ""} {
			if [valididx $lidx] {killdcc $lidx}
			which kill $lidx
		}
	}
	default {
		putbot $from "$rca $idx [getinfo $cmd]"
	}}
}

proc which {cmd idx {bot ""}} {
	variable pairs; variable handle
	switch $cmd {
	"loc" {
		set lidx ""
		if [info exists pairs($bot)] {
			foreach e $pairs($bot) {
				if {[lindex $e 1] == $idx} {
					set lidx [lindex $e 0]; break
				}
			} 
		}
		return $lidx
	}
	"rem" {
		foreach {bot elist} [array get pairs] {
			foreach e $elist {
				if {[lindex $e 0] == $idx} {
					set ridx [lindex $e 1]; return $bot:$ridx
				}
			}
		}
		return $bot:$ridx
	}
	"kill" {
		set flag 0
		foreach {bot elist} [array get pairs] {
			set i 0
			foreach e $elist {
				if {[lindex $e 0] == $idx} {set flag 1; break}
				incr i
			}
			if $flag break
		}
		set pairs($bot) [lreplace $pairs($bot) $i $i]
		unset handle($idx)
	}}
}

}
