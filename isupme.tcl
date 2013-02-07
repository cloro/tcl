# Isup.me Script by Trixar_za 
# Type in partyline: .chanset #channel +isup to enable it. 

# Sets the user agent 
set isup(agent) "Mozilla/4.75 (X11; U; Linux 2.2.17; i586; Nav)" 

setudef flag isup 

if {[catch {package require http 2.5} e] != 0} { 
  set isup(noutf8) 1 
  package require http 
} 

bind pub - !check proc:isup 

proc proc:isup {nick uhand handle chan input} { 
  if {[channel get $chan isup]} { 
     global isup 

    if {![llength [split $input]]} { 
       putquick "PRIVMSG $chan Please supply a website address. Ex: !isup google.com" 
    } else { 
  
       if {[info exists isup(noutf8)]} { 
          set http [::http::config -useragent $isup(agent)] 
       } else { 
          set http [::http::config -useragent $isup(agent) -urlencoding "utf-8"] 
       } 

       catch { set http [::http::geturl "http://www.isup.me/$input" -timeout 10000]} error 
  
       if {![string match -nocase "::http::*" $error]} { 
          putquick "PRIVMSG $chan [string totitle [string map {"\n" " | "} $error]] \( $input \)" 
          return 0 
       } 

       if {![string equal -nocase [::http::status $http] "ok"]} { 
          putquick "PRIVMSG $chan [string totitle [::http::status $http]] \( $input \)" 
          return 0 
       } 

       set html [::http::data $http] 

       # Clean up :P 
       regsub -all {\n} $html { } html 
       regsub -all {\t} $html { } html 
       regsub -all {<br/>} $html { } html 
       regsub -all {&nbsp;} $html { } html 
       regsub -all {    } $html { } html 
       regsub -all {   } $html { } html 
       regsub -all {  } $html { } html 
       regsub -all {<a.+?>} $html {} html 
       regsub -all {</a>} $html {} html 
       regsub -all {<span.+?>} $html {} html 
       regsub -all {</span>} $html {} html 
       regsub -all {—} $html {-} html 
       regsub -all {&gt;} $html {>} html 
       regsub -all {&lt;} $html {<} html 
       regsub -all {&amp;} $html {\&} html 
       regsub -all {&times;} $html {*} html 
       regsub -all {(?:\x91|\x92|’|‘|')} $html {'} html 
       regsub -all {(?:\x93|\x94|“|”|&quot;)} $html {"} html 
       regsub -all {×} $html {x} html 

       if {[regexp -- {<div.+?>(.+?)<p>} $html - upsite]} { 
          set upsite [string trim $upsite] 
       } 

       if {[info exists upsite]} { 
          putquick "PRIVMSG $chan $upsite" 
       } else { 
          putquick "PRIVMSG $chan Ironically, I couldn't get anything from isup.me!" 
       } 
    } 
  } 
} 

putlog "Isup.me Script by Trixar_za Loaded"
