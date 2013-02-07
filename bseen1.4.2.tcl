#
###
#Bass's Seen script. Traducido por YeRbA v1.4.2c  11/2007
#Bass's Seen script. Traduccion actualizada y completada por BaRDaHL & Tybalt para IRCTrivia.es v1.4.2c  01/2008
#Tybalt en #IRCNewbies - #Trivia.es @ OnlineGamesNet.
#BaRDaHL en #IRCNewbies - #Trivia.es @ OnlineGamesNet & #??? UnderNet.
#
# http://www.IRCTrivia.es/
###
#
#Este script mantiene la base de datos de *todos* los nicks vistos,
#Este es un script editado del original, simplemente se le tradujo al español
#
###
#comandos:
#       pub:  
#             !seen <pedido> [#canal]
#             !seennick <nick>
#             !idle <nick>
#             !chanstats [#canal]
#             !seenstats
#             !ayuda seen
#             !ayuda chanstats
#             !ayuda seenstats
#       msg:
#             seen <pedido> [#canal]
#             seennick <pedido> [#canal]
#             chanstats <#canal>
#             seenstats
#             ayuda seen
#             ayuda chanstats
#             ayuda seenstats
#       dcc:  .seen <pedido> [#canal]
#             .seennick <pedido> [#canal]
#             .unseen <#canal>
#             .ayuda seen
#             .ayuda chanstats
#             .ayuda seenstats
#             .help seen
#             .help chanstats
#             .help seenstats
###

###Parameters:

#bs(limit) limite máximo de registros.
set bs(limit) 10000

#bs(nicksize) número máximo de caracteres permitidos para el nickname (12 en Undernet)
set bs(nicksize) 30

#bs(no_pub) listado de canales que tu no quieras que el bot haga público
#  (pedidos publicos ignorados).  ejemplo: #lamer
set bs(no_pub) ""

#bs(quiet_chan) lista de canales que tu si quieres que el bot haga pedidos públicos
#  mediante via notice.
set bs(quiet_chan) ""

#bs(no_log) lista de canales que no quieres que el bot registre en su base de datos.
set bs(no_log) ""

#bs(log_only) lo contrario del anterior.
set bs(log_only) ""

#bs(cmdchar) caracter que se usara por defecto en los pedidos publicos, por ejemplo: !seen nick, por defecto es " ! "
set bs(cmdchar) "!"

#bs(flood) is used for flood protection, in the form x:y.  Any queries
#  beyond x in y seconds is considered a flood and ignored.
set bs(flood) 4:15
#bs(ignore) ignorar a los flooders? (1=on)
set bs(ignore) 1
#bs(ignore_time) cantidad de tiempo que lo flooders seran ignorados en minutos.
#  Esto no se toma en cuenta si el bs(ignore) esta apagado (0).
set bs(ignore_time) 5

#bs(smartsearch) is a master enable/disable for SmartSearch.  SmartSearch ensures that
#  the most accurate and current results are returned for nick queries. (1=on)
set bs(smartsearch) 1

#bs(logqueries) is used to log DCC/MSG/PUB queries
set bs(logqueries) 0

#bs(path) is used to indicate what path to save the database and backup to.
#  Setting to "" will cause the script to be saved in the same path as the eggdrop executable
#  If you set it, use the full path, and make sure you terminate w/ a "/".
#  eg:  set bs(path) "/home/usuario/directorio/"
set bs(path) "/home/usuario/midirectorio/"

###### Don't edit below here, even if you do know Tcl ######


if {[bind msg -|- help] != "*msg:help"} {bind msg -|- help *msg:help} ; #this is to fix a bind I didn't intend to use in a prev version (which screwed up msg'd help).  Sorry!
proc bs_filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}
proc bs_flood_init {} {
  global bs bs_flood_array ; if {![string match *:* $bs(flood)]} {putlog "$bs(version): variable bs(flood) no establecida correctamente." ; return}
  set bs(flood_num) [lindex [split $bs(flood) :] 0] ; set bs(flood_time) [lindex [split $bs(flood) :] 1] ; set i [expr $bs(flood_num) - 1]
  while {$i >= 0} {set bs_flood_array($i) 0 ; incr i -1 ; }
} ; bs_flood_init
proc bs_flood {nick uhost} {
  global bs bs_flood_array ; if {$bs(flood_num) == 0} {return 0} ; set i [expr $bs(flood_num) - 1]
  while {$i >= 1} {set bs_flood_array($i) $bs_flood_array([expr $i - 1]) ; incr i -1} ; set bs_flood_array(0) [unixtime]
  if {[expr [unixtime] - $bs_flood_array([expr $bs(flood_num) - 1])] <= $bs(flood_time)} {
    putlog "$bs(version): Flood detectado desde $nick." ; if {$bs(ignore)} {newignore [join [maskhost *!*[string trimleft $uhost ~]]] $bs(version) flood $bs(ignore_time)} ; return 1
  } {return 0}
}
if {[lsearch -exact [bind time -|- "*2 * * * *"] bs_timedsave] > -1} {unbind time -|- "*2 * * * *" bs_timedsave} ; #backup frequency can be lower
proc bs_read {} {
  global bs_list userfile bs
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {![file exists $bs(path)bs_data.$name]} {
    if {![file exists $bs(path)bs_data.$name.bak]} {
      putlog "     Base de datos bseen no encontrada!" ; putlog "     If this is the first time you've run the script, don't worry." ; putlog "     Si *deberia* de existir un archivo de base de datos antigua bseen... preocupese." ; return
    } {exec cp $bs(path)bs_data.$name.bak $bs(path)bs_data.$name ; putlog "     Base de datos bseen no encontrada! Backup reestablecido y en uso."}
  } ; set fd [open $bs(path)bs_data.$name r]
  set bsu_ver "" ; set break 0
  while {![eof $fd]} {
    set inp [gets $fd] ; if {[eof $fd]} {break} ; if {[string trim $inp " "] == ""} {continue}
    if {[string index $inp 0] == "#"} {set bsu_version [string trimleft $inp #] ; continue}
    if {![info exists bsu_version] || $bsu_version == "" || $bsu_version < $bs(updater)} {
      putlog "Actualizando la base de datos a la nueva version de bseen..."
#bugfix (b) - loading the wrong updater version
      if {[source scripts/bseen_updater1.4.2.tcl] != "ok"} {set temp 1} {set temp 0}
      if {$temp || [bsu_go] || [bsu_finish]} {
        putlog "Un grave error a sido detectado mientras se actualizaba la base de datos bseen."
        if {$temp} {putlog "     El script de actualizacion no a sido encontrado."}
        putlog "No es seguro ejecutar el bot con una base de datos que no corresponde con esta version de bseen."
        putlog "Si no usted no puede encontrar el problema, la unica opcion es eliminar los archivos bs_data.$name y bs_data.$name.bak y despues reiniciar el bot."
        putlog "Gracias a que esto es un bloqueo potencial en el bot, el bot sera detenido." ; die "error critico en encontrado en bseen."
      } ; set break 1 ; break
    }
    set nick [lindex $inp 0] ; set bs_list([string tolower $nick]) $inp
  } ; close $fd
  if {$break} {bs_read} {putlog "     Cargados [array size bs_list] datos bseen."}
}

###
#Must check to make sure the version didn't change during a .rehash
proc bs_update {} {
  global bs
  putlog "Una nueva version de bseen a sido cargado dinamicamente."
  putlog "    Verificando la integridad de la base de datos en el cruce de versiones..."
  bs_save ; bs_read
}
set bs(updater) 10402 ; set bs(version) bseen1.4.2c
if {[info exists bs_list]} {
#a rehash was done
  if {[info exists bs(oldver)]} {
    if {$bs(oldver) < $bs(updater)} {bs_update} ;# old ver found
  } {bs_update} ;# pre- 1.4.0
}
set bs(oldver) $bs(updater)
putlog "-- Bass's SEEN script $bs(version) cargado. Traducido por BaRDaHL & Tybalt para IRCTrivia.es"
if {![info exists bs_list] || [array size bs_list] == 0} {putlog "     Cargando la base de datos bseen..." ; bs_read}
###

bind time - "12 * * * *" bs_timedsave
proc bs_timedsave {min b c d e} {bs_save}
proc bs_save {} {
  global bs_list userfile bs ; if {[array size bs_list] == 0} {return}
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {[file exists $bs(path)bs_data.$name]} {catch {exec cp -f $bs(path)bs_data.$name $bs(path)bs_data.$name.bak}}
  set fd [open $bs(path)bs_data.$name w] ; set id [array startsearch bs_list] ;# putlog "Guardando copia de seguridad de la base de datos bseen..."
  puts $fd "#$bs(updater)"
  while {[array anymore bs_list $id]} {set item [array nextelement bs_list $id] ; puts $fd "$bs_list($item)"} ; array donesearch bs_list $id ; close $fd
}
#bugfix -- support new PART in egg1.5.x+
if {[string trimleft [lindex $version 1] 0] >= 1050000} {
  bind part -|- * bs_part
} {
  if {[lsearch -exact [bind part -|- *] bs_part] > -1} {unbind part -|- * bs_part}
  bind part -|- * bs_part_oldver
}
proc bs_part_oldver {a b c d} {bs_part $a $b $c $d ""}
#bugfix - new bs_part proc
proc bs_part {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] part $chan [split $reason]"}
bind join -|- * bs_join
proc bs_join {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] join $chan"}
bind sign -|- * bs_sign
proc bs_sign {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] quit $chan [split $reason]"}
bind kick -|- * bs_kick
proc bs_kick {nick uhost hand chan knick reason} {bs_add $knick "[getchanhost $knick $chan] [unixtime] kick $chan [list $nick] [list $reason]"}
bind nick -|- * bs_nick
proc bs_nick {nick uhost hand chan newnick} {set time [unixtime] ; bs_add $nick "[list $uhost] [expr $time -1] nick $chan [list $newnick]" ; bs_add $newnick "[list $uhost] $time rnck $chan [list $nick]"}
bind splt -|- * bs_splt
proc bs_splt {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] splt $chan"}
bind rejn -|- * bs_rejn
proc bs_rejn {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] rejn $chan"}
bind chon -|- * bs_chon
proc bs_chon {hand idx} {foreach item [dcclist] {if {[lindex $item 3] != "CHAT"} {continue} ; if {[lindex $item 0] == $idx} {bs_add $hand "[lindex $item 2] [unixtime] chon" ; break}}}
if {[lsearch -exact [bind chof -|- *] bs_chof] > -1} {unbind chof -|- * bs_chof} ; #this bind isn't needed any more
bind chjn -|- * bs_chjn
proc bs_chjn {bot hand channum flag sock from} {bs_add $hand "[string trimleft $from ~] [unixtime] chjn $bot"}
bind chpt -|- * bs_chpt
proc bs_chpt {bot hand args} {set old [split [bs_search ? [string tolower $hand]]] ; if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] chpt $bot"}}

if {[string trimleft [lindex $version 1] 0] > 1030000} {bind away -|- * bs_away}
proc bs_away {bot idx msg} {
  global botnet-nick
  if {$bot == ${botnet-nick}} {set hand [idx2hand $idx]} {return}
  set old [split [bs_search ? [string tolower $hand]]]
  if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] away $bot [bs_filt [join $msg]]"}
}
bind dcc n|- unseen bs_unseen
proc bs_unseen {hand idx args} {
  global bs_list
  set tot 0 ; set chan [string tolower [lindex $args 0]] ; set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {incr tot ; lappend remlist $item}
  }
  array donesearch bs_list $id ; if {$tot > 0} {foreach item $remlist {unset bs_list($item)}}
  putlog "$hand elimino $chan de la base de datos bseen.  $tot entradas eliminadas."
  putidx $idx "$chan eliminado correctamente.  $tot entradas eliminadas de la base de datos bseen."
}
bind bot -|- bs_botsearch bs_botsearch
proc bs_botsearch {from cmd args} {
  global botnick ; set args [join $args]
  set command [lindex $args 0] ; set target [lindex $args 1] ; set nick [lindex $args 2] ; set search [bs_filt [join [lrange $args 3 e]]]
  if {[string match *\\\** $search]} {
    set output [bs_seenmask bot $nick $search]
    if {$output != "No se encontraron coincidencias." && ![string match "No estoy en *" $output]} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick dice:  [bs_filt $output]}"}
  } {
    set output [bs_output bot $nick [bs_filt [lindex $search 0]] 0]
    if {$output != 0 && [lrange [split $output] 1 4] != "No he visto a"} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick dice:  [bs_filt $output]}"}
  }
}
if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}
bind bot -|- bs_botsearch_reply bs_botsearch_reply
proc bs_botsearch_reply {from cmd args} {
  global bs ; set args [join $args]
  if {[lindex [lindex $args 2] 5] == "estoy" || [lindex [lindex $args 2] 4] == "estoy"} {return}
  if {![info exists bs(bot_delay)]} {
    set bs(bot_delay) on ; utimer 10 {if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}}
    if {![lindex $args 0]} {putdcc [lindex $args 1] "[join [lindex $args 2]]"} {puthelp "[lindex $args 1] :[join [lindex $args 2]]"}
  }
}
bind dcc -|- seen bs_dccreq1
bind dcc -|- seennick bs_dccreq2
proc bs_dccreq1 {hand idx args} {bs_dccreq $hand $idx $args 0}
proc bs_dccreq2 {hand idx args} {bs_dccreq $hand $idx $args 1}
proc bs_dccreq {hand idx args no} {
  set args [bs_filt [join $args]] ; global bs
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask dcc $hand $args]
    if {$output == "No se encontraron coincidencias."} {putallbots "bs_botsearch 0 $idx $hand $args"}
    if {[string match "No estoy en *" $output]} {putallbots "bs_botsearch 0 $idx $hand $args"}
    putdcc $idx $output ; return $bs(logqueries)
  }
  set search [bs_filt [lindex $args 0]]
  set output [bs_output dcc $hand $search $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "No he visto a"} {putallbots "bs_botsearch 0 $idx $hand $args"}
  putdcc $idx "$output" ; return $bs(logqueries)
}
bind msg -|- seen bs_msgreq1
bind msg -|- seennick bs_msgreq2
proc bs_msgreq1 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 0}
proc bs_msgreq2 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 1}
proc bs_msgreq {nick uhost hand args no} { 
  if {[bs_flood $nick $uhost]} {return 0} ; global bs
  set args [bs_filt [join $args]]
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask msg $nick $args] 
    if {$output == "No se encontraron coincidencias."} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
    if {[string match "No estoy en *" $output]} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
    puthelp "notice $nick :$output" ; return $bs(logqueries)
  }
  set search [bs_filt [lindex $args 0]]
  set output [bs_output $search $nick $search $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "No he visto a"} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
  puthelp "notice $nick :$output" ; return $bs(logqueries)
}
bind pub -|- [string trim $bs(cmdchar)]seen bs_pubreq1
bind pub -|- [string trim $bs(cmdchar)]seennick bs_pubreq2
proc bs_pubreq1 {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 0}
proc bs_pubreq2 {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 1}
proc bs_pubreq {nick uhost hand chan args no} {
  if {[bs_flood $nick $uhost]} {return 0}
  global botnick bs ; set i 0 
  if {[lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0} {return 0}
  if {$bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1} {return 0}
  set args [bs_filt [join $args]]
  if {[lsearch -exact $bs(quiet_chan) [string tolower $chan]] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask $chan $hand $args]
    if {$output == "No se encontraron coincidencias."} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    if {[string match "No estoy en *" $output]} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    puthelp "$target :$output" ; return $bs(logqueries)
  }
  set data [bs_filt [string trimright [lindex $args 0] ?!.,]]
  if {[string tolower $nick] == [string tolower $data] } {puthelp "$target :$nick, mírate al espejo. (ojala no se rompa) :)." ; return $bs(logqueries)}
  if {[string tolower $data] == [string tolower $botnick] } {puthelp "$target :$nick, Estoy justo aca. Deja de malgastar mi tiempo!" ; return $bs(logqueries)}
  if {[onchan $data $chan]} {puthelp "$target :$nick, abre tus ojos ya que $data esta aqui!" ; return $bs(logqueries)}
  set output [bs_output $chan $nick $data $no] ; if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "No he visto a"} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
  puthelp "$target :$output" ; return $bs(logqueries)
}
proc bs_output {chan nick data no} {
  global botnick bs version bs_list
  set data [string tolower [string trimright [lindex $data 0] ?!.,]]
  if {$data == ""} {return 0}
  if {[string tolower $nick] == $data} {return [concat $nick, mírate al espejo. (ojala no se rompa) :).]}
  if {$data == [string tolower $botnick]} {return [concat $nick, Estoy justo aca. Deja de malgastar mi tiempo!]}
  if {[string length $data] > $bs(nicksize)} {return 0}
  if {$bs(smartsearch) != 1} {set no 1}
  if {$no == 0} {
    set matches "" ; set hand "" ; set addy ""
    if {[lsearch -exact [array names bs_list] $data] != "-1"} {
      set addy [lindex $bs_list([string tolower $data]) 1] ; set hand [finduser $addy]
      foreach item [bs_seenmask dcc ? [maskhost $addy]] {if {[lsearch -exact $matches $item] == -1} {set matches "$matches $item"}}
    }
    if {[validuser $data]} {set hand $data}
    if {$hand != "*" && $hand != ""} {
      if {[string trimleft [lindex $version 1] 0]>1030000} {set hosts [getuser $hand hosts]} {set hosts [gethosts $hand]}
      foreach addr $hosts {
        foreach item [string tolower [bs_seenmask dcc ? $addr]] {
          if {[lsearch -exact [string tolower $matches] [string tolower $item]] == -1} {set matches [concat $matches $item]}
        }
      }
    }
    if {$matches != ""} {
      set matches [string trimleft $matches " "]
      set len [llength $matches]
      if {$len == 1} {return [bs_search $chan [lindex $matches 0]]}
      if {$len > 99} {return [concat Encontré $len coincidencias para su petición\; por favor especifique su pedido.]}
      set matches [bs_sort $matches]
      set key [lindex $matches 0]
      if {[string tolower $key] == [string tolower $data]} {return [bs_search $chan $key]}
      if {$len <= 5} {
        set output [concat Encontré $len coincidencias para tu pedido (clasificados): [join $matches].]
        set output [concat $output  [bs_search $chan $key]] ; return $output
      } {
        set output [concat Encontré $len coincidencias para tu pedido. Aqui estan los 5 más recientes (clasificados): [join [lrange $matches 0 4]].]
        set output [concat $output  [bs_search $chan $key]] ; return $output
      }
    }
  }
  set temp [bs_search $chan $data]
  if {$temp != 0} { return $temp } {
    #$data not found in $bs_list, so search userfile
    if {![validuser [bs_filt $data]] || [string trimleft [lindex $version 1] 0]<1030000} { 
      return "$nick, No he visto a $data."
    } {
      set seen [getuser $data laston]
      if {[getuser $data laston] == ""} {return "$nick, No he visto a $data."}
      if {($chan != [lindex $seen 1] || $chan == "bot" || $chan == "msg" || $chan == "dcc") && [validchan [lindex $seen 1]] && [lindex [channel info [lindex $seen 1]] 23] == "+secret"} {
        set chan "-secret-"
      } {
        set chan [lindex $seen 1]
      }
      return [concat $nick, $data se le vio por ultima vez en: $chan [bs_when hace [lindex $seen 0]] .]
    }
  }
}
proc bs_search {chan n} {
  global bs_list ; if {![info exists bs_list]} {return 0}
  if {[lsearch -exact [array names bs_list] [string tolower $n]] != "-1"} { 
#bugfix:  let's see if the split added below fixes the eggdrop1.4.2 truncation bug
    set data [split $bs_list([string tolower $n])]
#bugfix: added a join on the $n  (c)
    set n [join [lindex $data 0]] ; set addy [lindex $data 1] ; set time [lindex $data 2] ; set marker 0
    if {([string tolower $chan] != [string tolower [lindex $data 4]] || $chan == "dcc" || $chan == "msg" || $chan == "bot") && [validchan [lindex $data 4]] && [lindex [channel info [lindex $data 4]] 23] == "+secret"} {
      set chan "-secret-"
    } {
      set chan [lindex $data 4]
    }
    switch -- [lindex $data 3] {
	part { 
        set reason [lrange $data 5 e]
        if {$reason == ""} {set reason "."} {set reason " diciendo \"$reason\"."}
        set output [concat $n ($addy) se le vio saliendo de $chan hace [bs_when $time] $reason] 
      }
	quit { set output [concat $n ($addy) se le vio por ultima vez al desconectarse del IRC desde $chan hace [bs_when $time] con el siguiente mensaje: ([join [lrange $data 5 e]]).] }
	kick { set output [concat $n ($addy) se le vio por ultima vez siendo expulsado de: $chan por [lindex $data 5] hace [bs_when $time] por el motivo: ([join [lrange $data 6 e]]).] }
	rnck {
	  set output [concat $n ($addy) se le vio por ultima vez cambiando de nick de [lindex $data 5] en [lindex $data 4] hace [bs_when $time] .] 
	  if {[validchan [lindex $data 4]]} {
	    if {[onchan $n [lindex $data 4]]} {
	      set output [concat $output $n aún está ahí.]
	    } {
	      set output [concat $output  No veo a $n en este momento.]
	    }
	  }
	}
	nick { 
	  set output [concat $n ($addy) se le vio por ultima vez cambiando de nick a [lindex $data 5] en [lindex $data 4] hace [bs_when $time] .] 
	}
	splt { set output [concat $n ($addy) se le vio saliendo de $chan debido a un split, hace [bs_when $time] .] }
	rejn { 
	  set output [concat $n ($addy) se le vio por ultima vez reingresando a $chan del split, hace [bs_when $time] .] 
	  if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n aún está en $chan.]} {set output [concat $output  No veo a $n en $chan en este momento.]}}
	}
	join { 
	  set output [concat $n ($addy) se le vio por ultima vez ingresando a $chan hace [bs_when $time] .]
	  if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n aún está en $chan.]} {set output [concat $output  No veo a $n en $chan en este momento.]}}
	}
	away {
	  set reason [lrange $data 5 e]
        if {$reason == ""} {
	    set output [concat $n ($addy) se le vio regresando del partyline en $chan hace [bs_when $time].]
	  } {
	    set output [concat $n ($addy) se le vio poniendose ausente ($reason) en $chan hace [bs_when $time] .]
	  }
	}
	chon { 
	  set output [concat $n ($addy) se le vio por ultima vez ingresando al partyline hace [bs_when $time] .] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n está en el partyline justo ahora.] ; set marker 1 ; break}}
	  if {$marker == 0} {set output [concat $output  No veo a $n en el partyline en este momento.]}
	}
	chof { 
	  set output [concat $n ($addy) se le vio por ultima vez dejando el partyline hace [bs_when $time] .] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n está en el partyline en [lindex $item 1] still.] ; break}}
	}
	chjn {
	  set output [concat $n ($addy) se le vio por ultima vez ingresando al partyline en $chan hace [bs_when $time] .] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n está en el partyline justo ahora.] ; set marker 1 ; break}}
	  if {$marker == 0} {set output [concat $output  No veo a $n en el partyline en este momento.]}
	}
	chpt { 
	  set output [concat $n ($addy) se le vio por ultima vez saliendo del partyline desde $chan hace [bs_when $time] .] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n está en el partyline en [lindex $item 1] still.] ; break}}
	}
	default {set output "error"}
    } ; return $output
  } {return 0}
}
proc bs_when {lasttime} {
  #This is equiv to mIRC's $duration() function
  set years 0 ; set days 0 ; set hours 0 ; set mins 0 ; set time [expr [unixtime] - $lasttime]
  if {$time < 60} {return "solo $time segundos"}
  if {$time >= 31536000} {set years [expr int([expr $time/31536000])] ; set time [expr $time - [expr 31536000*$years]]}
  if {$time >= 86400} {set days [expr int([expr $time/86400])] ; set time [expr $time - [expr 86400*$days]]}
  if {$time >= 3600} {set hours [expr int([expr $time/3600])] ; set time [expr $time - [expr 3600*$hours]]}
  if {$time >= 60} {set mins [expr int([expr $time/60])]}
  if {$years == 0} {set output ""} elseif {$years == 1} {set output "1 año,"} {set output "$years años,"}
  if {$days == 1} {lappend output "1 dia,"} elseif {$days > 1} {lappend output "$days dias,"}
  if {$hours == 1} {lappend output "1 hora,"} elseif {$hours > 1} {lappend output "$hours horas,"}
  if {$mins == 1} {lappend output "1 minuto"} elseif {$mins > 1} {lappend output "$mins minutos"}
  return [string trimright [join $output] ", "]
}
proc bs_add {nick data} {
  global bs_list bs
  if {[lsearch -exact $bs(no_log) [string tolower [lindex $data 3]]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower [lindex $data 3]]] == -1)} {return}
  set bs_list([string tolower $nick]) "[bs_filt $nick] $data"
}
bind time -  "*1 * * * *" bs_trim
proc bs_lsortcmd {a b} {global bs_list ; set a [lindex $bs_list([string tolower $a]) 2] ; set b [lindex $bs_list([string tolower $b]) 2] ; if {$a > $b} {return 1} elseif {$a < $b} {return -1} {return 0}}
proc bs_trim {min h d m y} {
  global bs bs_list ; if {![info exists bs_list] || ![array exists bs_list]} {return} ; set list [array names bs_list] ; set range [expr [llength $list] - $bs(limit) - 1] ; if {$range < 0} {return}
  set list [lsort -increasing -command bs_lsortcmd $list] ; foreach item [lrange $list 0 $range] {unset bs_list($item)}
}
proc bs_seenmask {ch nick args} {
  global bs_list bs ; set matches "" ; set temp "" ; set i 0 ; set args [join $args] ; set chan [lindex $args 1]
  if {$chan != "" && [string trimleft $chan #] != $chan} {
    if {![validchan $chan]} {return "No estoy en $chan."} {set chan [string tolower $chan]}
  } { set $chan "" }
  if {![info exists bs_list]} {return "No se encontraron coincidencias."} ; set data [bs_filt [string tolower [lindex $args 0]]]

#bugfix: unnecessarily complex masks essentially freeze the bot
  set maskfix 1
  while $maskfix {
    set mark 1
    if [regsub -all -- \\?\\? $data ? data] {set mark 0}
    if [regsub -all -- \\*\\* $data * data] {set mark 0}
    if [regsub -all -- \\*\\? $data * data] {set mark 0}
    if [regsub -all -- \\?\\* $data * data] {set mark 0}
    if $mark {break}
  }

  set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id] ; if {$item == ""} {continue} ; set i 0 ; set temp "" ; set match [lindex $bs_list($item) 0] ; set addy [lindex $bs_list($item) 1]
    if {[string match $data $item![string tolower $addy]]} {
      set match [bs_filt $match] ; if {$chan != ""} {
        if {[string match $chan [string tolower [lindex $bs_list($item) 4]]]} {set matches [concat $matches $match]}
      } {set matches [concat $matches $match]}
    }
  }
  array donesearch bs_list $id
  set matches [string trim $matches " "]
  if {$nick == "?"} {return [bs_filt $matches]}
  set len [llength $matches]
  if {$len == 0} {return "No se encontraron coincidencias."}
  if {$len == 1} {return [bs_output $ch $nick $matches 1]}
  if {$len > 99} {return "Encontré $len coincidencias para tu pedido; por favor sea más específico con su consulta."}
  set matches [bs_sort $matches]
  if {$len <= 5} {
    set output [concat Encontré $len coincidencia para tu pedido (clasificados): [join $matches].]
  } {
    set output "Encontré $len coincidencias para tu pedido. Aqui estan los mas recientes (clasificados): [join [lrange $matches 0 4]]."
  }
  return [concat $output [bs_output $ch $nick [lindex [split $matches] 0] 1]]
} 
proc bs_sort {data} {global bs_list ; set data [bs_filt [join [lsort -decreasing -command bs_lsortcmd $data]]] ; return $data}
bind dcc -|- seenstats bs_dccstats
proc bs_dccstats {hand idx args} {putdcc $idx "[bs_stats]"; return 1}
bind pub -|- [string trim $bs(cmdchar)]seenstats bs_pubstats
proc bs_pubstats {nick uhost hand chan args} {
  global bs ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) [string tolower $chan]] >= 0} {set target "notice $nick"} {set target "privmsg $chan"} ; puthelp "$target :[bs_stats]" ; return 1
}
bind msg -|- seenstats bs_msgstats
proc bs_msgstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_stats]" ; return $bs(logqueries)}
proc bs_stats {} {
  global bs_list bs ; set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    set tok [lindex $bs_list($item) 2] ; if {$tok == ""} {putlog "Registro bseen dañado: $item" ; continue}
    if {[lindex $bs_list($item) 2] < $bs_record} {set bs_record [lindex $bs_list($item) 2] ; set name $item}
    set addy [string tolower [maskhost [lindex $bs_list($item) 1]]] ; if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
  }
  array donesearch bs_list $id
  return "En este momento estoy rastreando [array size bs_list]/$bs(limit) nicks, de los cuales hay $totalm userhosts únicos. El registro más antiguo es de [lindex $bs_list($name) 0], el cual es de hace [bs_when $bs_record] atrás."
}
bind dcc -|- chanstats bs_dccchanstats
proc bs_dccchanstats {hand idx args} {
  if {$args == "{}"} {set args [console $idx]}  
  if {[lindex $args 0] == "*"} {putdcc $idx "$hand, chanstats requiere un argumento de canal, o un canal de consola válido." ; return 1}
  putdcc $idx "[bs_chanstats [lindex $args 0]]"
  return 1
}
bind pub -|- [string trim $bs(cmdchar)]chanstats bs_pubchanstats
proc bs_pubchanstats {nick uhost hand chan args} {
  global bs ; set chan [string tolower $chan]
  if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  if {[lindex $args 0] != ""} {set chan [lindex $args 0]} ; puthelp "$target :[bs_chanstats $chan]" ; return $bs(logqueries)
}
bind msg -|- chanstats bs_msgchanstats
proc bs_msgchanstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_chanstats [lindex $args 0]]" ; return $bs(logqueries)}
proc bs_chanstats {chan} {
  global bs_list ; set chan [string tolower $chan] ; if {![validchan $chan]} {return "No estoy en $chan."}
  set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalc 0 ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id] ; set time [lindex $bs_list($item) 2] ; if {$time == ""} {continue}
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {
      if {$time < $bs_record} {set bs_record $time} ; incr totalc
      set addy [string tolower [maskhost [lindex $bs_list($item) 1]]]
      if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
    }
  }
  array donesearch bs_list $id ; set total [array size bs_list]
  return "$chan es la fuente de [expr 100*$totalc/$total]% ($totalc/$total) de los registros en la base de datos. En $chan hubo un total de $totalm userhosts únicos en los últimos [bs_when $bs_record]."
}
foreach chan [string tolower [channels]] {if {![info exists bs_botidle($chan)]} {set bs_botidle($chan) [unixtime]}}
bind join -|- * bs_join_botidle
proc bs_join_botidle {nick uhost hand chan} {
  global bs_botidle botnick
  if {$nick == $botnick} {
   set bs_botidle([string tolower $chan]) [unixtime]
  }
}
bind pub -|- [string trim $bs(cmdchar)]idle lastspoke

#bugfix: fixed lastspoke to handle [blah] nicks better (c)
proc lastspoke {nick uhost hand chan args} {
  global bs botnick bs_botidle
  set chan [string tolower $chan] ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) $chan] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  set data [lindex [bs_filt [join $args]] 0]
  set ldata [string tolower $data] 
  if {[string match *\** $data]} {
    set chanlist [string tolower [chanlist $chan]]
    if {[lsearch -glob $chanlist $ldata] > -1} {set data [lindex [chanlist $chan] [lsearch -glob $chanlist $ldata]]}
  }
  if {[onchan $data $chan]} { 
    if {$ldata == [string tolower $botnick]} {puthelp "$target :$nick, tienes que malgastar mi tiempo?" ; return 1}
    set time [getchanidle $data $chan] ; set bottime [expr ([unixtime] - $bs_botidle($chan))/60]
    if {$time < $bottime} {
      if {$time > 0} {set diftime [bs_when [expr [unixtime] - $time*60 -15]]} {set diftime "menos de un minuto"}
      puthelp "$target :$data  habló por última vez en $chan hace $diftime atrás."
    } {
      set diftime [bs_when $bs_botidle($chan)]
      puthelp "$target :$data no ha dicho una palabra desde que entré a $chan hace $diftime atrás."
    }
  }
  return 1
}
bind msgm -|- "ayuda seen" bs_help_msg_seen
bind msgm -|- "ayuda chanstats" bs_help_msg_chanstats
bind msgm -|- "ayuda seenstats" bs_help_msg_seenstats
bind pubm -|- "ayuda seen" bs_help_msg_seen
bind pubm -|- "ayuda chanstats" bs_help_msg_chanstats
bind pubm -|- "ayuda seenstats" bs_help_msg_seenstats
proc bs_help_msg_seen {nick uhost hand args} {
	global bs ; if {[bs_flood $nick $uhost]} {return 0}
	puthelp "notice $nick :###  seen <pedido> \[canal\]          $bs(version)"
	puthelp "notice $nick :   Los pedidos pueden tener los siguientes formatos:"
	puthelp "notice $nick :     'normal':  seen nick; seen nickname "
	puthelp "notice $nick :     'mask':   seen *n?ck*; seen *.nick.com; seen *.edu #canal" ; return 0
}
proc bs_help_msg_chanstats {nick uhost hand args} {
	global bs ; if {[bs_flood $nick $uhost]} {return 0}
	puthelp "notice $nick :###  chanstats <canal>          $bs(version)"
	puthelp "notice $nick :   Devuelve las estadísticas de #canal en la base de datos bseen." ; return 0
}
proc bs_help_msg_seenstats {nick uhost hand args} {
	global bs ; if {[bs_flood $nick $uhost]} {return 0}
	puthelp "notice $nick :###  seenstats          $bs(version)"
	puthelp "notice $nick :   Devuelve el estado de la base de datos bseen." ; return 0
}
bind dcc -|- seenversion bs_version
proc bs_version {hand idx args} {global bs ; putidx $idx "###  Bass's Seen script, $bs(version). Traducido por BaRDaHL & Tybalt para IRCTrivia.es"}
bind dcc -|- help bs_help_dcc
bind dcc -|- ayuda bs_help_dcc
proc bs_help_dcc {hand idx args} {
	global bs
	switch -- $args {
		seen {
			putidx $idx "###  seen <pedido> \[canal\]          $bs(version)" ; putidx $idx "   Los pedidos pueden tener los siguientes formatos:"
			putidx $idx "     'normal':  seen nick; seen nickname " ; putidx $idx "     'mask':   seen *n?ck*; seen *.nick.com; seen *.edu #canal"
		}
		seennick {putidx $idx "###  seen <nick>          $bs(version)"}
		chanstats {putidx $idx "###  chanstats <canal>" ; putidx $idx "   Devuelve las estadísticas de #canal en la base de datos bseen."}
		seenstats {putidx $idx "###  seenstats          $bs(version)" ; putidx $idx "   Devuelve el estado de la base de datos bseen."}
		unseen {if {[matchattr $hand n]} {putidx $idx "###  unseen <canal>          $bs(version)" ; putidx $idx "   Borra todas las entradas de <canal> de la base de datos bseen.."}}
		default {*dcc:help $hand $idx [join $args] ; return 0}
	} ; return 1
}