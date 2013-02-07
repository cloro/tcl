###############################################INFO###########################################
## Blackmore's BlackIdle 1.0 beta
# Written by: Simeon Simeonov (Blackmore)
# Release date: 10.01.2002
##

## About this script: This is an unique idle script designed to implement effectively the idle kick/ban.
# There are so many idle kick/ban scripts. Why use this one?
# Scripts that simply kick idle users from the channel are absolutely pointless. The idle user can
# simply switch on the auto-rejoin option on his/her IRC client (most IRC clients have this option).
# Scripts that intend to ban idle users are also not complete. Let's imagine that the user is not really idle.
# Once the user realizes that he/she is banned. He/She will try to message the chanops and ask them to be
# unbanned. The point with the idle scripts is to kick/ban users who are not in front of the PC at all such as bots
# or simply users who want to make advantage of some statistic counts in the channel or just logs
# everything said in the channel (I know lots of those).
# This script allows the user to unban him/herself after being banned. The user can not unban him/herself if
# the reason for being banned is not idleing. The script works that way:
# When some user is banned, he/she receive the following message: You have been
# banned from #channel for staying idle more then <some time> minutes. If you are
# online and want to reenter the channel type: /msg TheBot unban <random password> . Otherwise
# you will be automatically unbanned in <some time> minutes."
# The random password is a 4-digit number and it's different for each idle ban.
# 
# The script allows users who have been kicked for staying idle to unban themselves (if they are in-front of the PC)
# Why random password? This prevents (makes it difficult) users from setting up a script which unbans automatically.


## Installation: I will not attempt to teach you how to use eggdrop. If you are not familiar with eggdrop
# visit http://www.egghelp.org
# Copy this file to your script directory (usually scripts/) and add the following line to your configuration file:
# source scripts/blackidle.tcl
# Now you can start your bot. If it is already running you must rehash it (.rehash)
#

## About me:
# If you have some questions or ideas how to make this script better, you can direct them to: blackmore@windows-sucks.com
#

#########################################CONFIGURATION#########################################
#Channels you want the script to monitor (separated by space).
# N.B The bot *MUST* be present in each specified channel.
set channels {#vhost}

# Idletime in minutes. If the user stays idle longer then the idletime, he/she will be banned/kicked.
set idletime 5

# How long will the bot wait (in minutes) before removing the ban automatically.
set bantime 60

# Global flag protection. Users with that global flag will not be kicked/banned
# N.B You can use *ONLY* 1 flag.
set protected_gflag "aso"

# Protected channel flag. Users with that channel flag will not be kicked/banned
# N.B You can use *ONLY* 1 flag.
set protected_cflag "aso"

# The kick message which will be displayed in the channel when the user is kicked out.
set reason "No se permiten Idlers en este canal"

# Allow unban. Allows the user to unban him/herself the random password. 0 = no, 1 = yes.
# If you set this to 0, there is no point for you to use this script.
# N.B The user can't unban him/herself if he/she is not banned 'cause of this script. So don't worry :)
set allow_unban 1


######################## CODE STARTS HERE ( Do not edit above this line if you are not familiar with TCL) ###########################

timer 1 pr_main
timer 2 pr_random
set flood 0
set rnd_pass 1324
bind msg - unban pr_unban

proc pr_main {} {
	
	global channels
	global idletime
	global bantime
	global protected_gflag
	global protected_cflag
	global rnd_pass
	global reason
	global botnick

	foreach chan $channels {
		if {[botonchan $chan] == 1} {
			foreach user [chanlist $chan] {
				if {[isbotnick $user] == 0} {
					set ch [getchanidle $user $chan]
                                	if {$ch >= $idletime} {
						set han [nick2hand $user $chan]
						if {$han == "*"} {
          						set hst [getchanhost $user $chan]
                                                        set bmask "*!$hst"
							puthelp "PRIVMSG LALALALALAALALALA :You have been banned from $chan for staying idle more then $idletime minutes. If are online and want to reenter the channel type: /msg $botnick unban $rnd_pass . Otherwise you will be automaticly unbanned in $bantime minutes."
                                                        newchanban $chan $bmask $rnd_pass $reason $bantime
						} else {
							set str_gflag [chattr $han]
							set str_cflag [chattr $han $chan]
							set tmp [split $str_cflag "|"]
							set str_cflag [lindex $tmp 1]
							set trigger 0
							for {set i 0} {$i < [string length $str_gflag]} {incr i 1} {
								if {$protected_gflag == [string index $str_gflag $i]} {
									set trigger 1
								}
							}

							for {set i 0} {$i < [string length $str_cflag]} {incr i 1} {
                                                                if {$protected_cflag == [string index $str_cflag $i]} {
                                                                        set trigger 1
                                                                }
                                                        }

							if {$trigger == 0} {
								set hst [getchanhost $user $chan]
								set bmask "*!$hst"
								newchanban $chan $bmask $rnd_pass $reason $bantime
								puthelp "PRIVMSG LALALALALALALALALA :You have been banned from $chan for staying idle more then $idletime minutes. If are online and wish to reenter the channel type: /msg $botnick unban $rnd_pass . Otherwise you will be automaticly unbanned in $bantime minutes."
								
							}
						}
					}
				}
			}
		}
	}
timer 1 pr_main
}

proc pr_random {} {
	global rnd_pass
	set rnd_pass [expr [rand 9000] + 1000]
	timer 2 pr_random
}


proc pr_unban { nick uhost handle arg } {
	global channels
	global allow_unban
	if {$allow_unban == 1} {
		if {[string length $arg] == 4} {
			foreach chan $channels {
				foreach ban [banlist $chan] {
                        	       	set bmask "*!$uhost"
					set bpass [string range $ban [expr [string length $ban] - 4] end]
					set bhost [string range $ban 0 [expr [string length $bmask] - 1]]
					if {$arg == $bpass} {
						if {$bmask == $bhost} {
                       	                		killchanban $chan $bmask
							puthelp "PRIVMSG LOONWILCBW :You can now reenter the channel."
						} else {
							puthelp "PRIVMSG HBEHBC NJAHVC :Nice try! It won't work that way"
						}
                                	} else {
						puthelp "PRIVMSG HKVACVKACBXVKBA :Wrong password. Try again!"
					}
				}
			}
		}
	} else {
		puthelp "PRIVMSG BEVHEVL CNADBVUEBV :Unban is turned off. Sorry!"
	}	
}

putlog "BlackIdle 1.0 beta"
