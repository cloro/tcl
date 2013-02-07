#---------------- Menu TCL -----------------#





#----- Dont Edit If You Dont Know It ----#





proc pub_menu {nick uhost hand args channel rest} {

  global botnick

    putquick "NOTICE $nick :.ayuda"

    putquick "NOTICE $nick :.help"

    putquick "NOTICE $nick :.rules"

    putquick "NOTICE $nick :.vpn"

    putquick "NOTICE $nick :.vpnpago"

    putquick "NOTICE $nick :.vpngratis"

    putquick "NOTICE $nick :.blog"

    putquick "NOTICE $nick :.ocultarip"

    putquick "NOTICE $nick :.webchat"

    putquick "NOTICE $nick :.tor"

    putquick "NOTICE $nick :.webproxy"

    putquick "NOTICE $nick :.registrar"

    putquick "NOTICE $nick :.vhost"

    putquick "NOTICE $nick :.xchat"

    putquick "NOTICE $nick :.vm"

    putquick "NOTICE $nick :.irssi"

    putquick "NOTICE $nick :.pad"

    putquick "NOTICE $nick :.criptografia"

    putquick "NOTICE $nick :.identificar"

    putquick "NOTICE $nick :.services"

    putquick "NOTICE $nick :.vagos"

    putquick "NOTICE $nick :.guardia"

    putquick "NOTICE $nick :.bnc"

    putquick "NOTICE $nick :!911"

    putquick "NOTICE $nick :.trolling"

    return 0

}



bind pub - .ayuda pub_ayuda

bind pub - .help pub_ayuda



proc pub_ayuda {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Para ver mi ayuda teclea lo que te interese saber: .rules .ocultarip .blog .vpn .vpngratis .vpnpago .webchat .tor .registrar .vhost .xchat .irssi .vm .pad .criptografia .memes .webproxy .identificar .vagos .services .bnc !911"

    return 0

}



bind pub - .vpn pub_vpn



proc pub_vpn {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Usa una VPN de pago, las gratuitas no son recomendables porque pueden ceder tus datos a terceros. Siempre que puedas usa una de pago. Para verlas escribe .vpngratis o .vpnpago"

    return 0

}



bind pub - .rules pub_rules



proc pub_rules {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Por favor, Lee atentamente las Reglas de F4All IRC Network: http://f4allz.tk/f4a_r"

    return 0

}



bind pub - .vpnpago pub_vpnpago



proc pub_vpnpago {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Aquí hay una lista de VPN de pago y algunos tips extras http://goo.gl/GQDNR"

    return 0

}



bind pub - .vpngratis pub_vpngratis



proc pub_vpngratis {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Aquí algunos ejemplos: www.cyberghostvpn.com || www.hotspotshield.com || www.proxpn.org || www.anonimityonline.org - Aquí hay una lista más exhaustiva: http://freed0m4all.org/recursos/"

    return 0

}



bind pub - .blog pub_blog



proc pub_blog {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Nuestro blog es http://blog.freed0m4all.org - Te invitamos a leerlo e informarte de las novedades de F4All Irc Network"

    return 0

}



bind pub - .ocultarip pub_ocultarip



proc pub_ocultarip {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Para ocultar tu IP te recomendamos usar una VPN. No uses proxy ni Tor para chat, (sólo para navegar) Escribe: !proxy !vpn !tor para mayor información."

    return 0

}



bind pub - .webchat pub_webchat



proc pub_webchat {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :para entrar al chat via tu navegador usa este enlace: http://webchat.freed0m4all.org   // Nuestro nuevo y definitivo WebIRC: http://chat.freed0m4all.org"

    return 0

}



bind pub - .tor pub_tor





proc pub_tor {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Tor es una red de proxies que ayuda a ocultar su IP. Esta NO encripta datos. Algunos países específicos (como Irán) afirman haber logrado su bloqueo. Sin embargo, es útil para utilizarla en la navegación. Puedes descargar Tor desde www.torproject.org"

    return 0

}



bind pub - .webproxy pub_webproxy



proc pub_webproxy {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Un webproxy mantiene tu anonimato al navegar (úsalo como alternativa a una VPN y únicamente para navegar y como último recurso (no lo uses con el chat ni con el LOIC). Te recomendamos esta: http://proxy.freed0m4all.org/ o http://www.zend2.com"

    retrun 0

}



bind pub - .registrar pub_registrar



proc pub_registrar {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Para registrarse escribe lo siguiente: /ns register TUPASSWORD email@masfalsoqueexistaenelmundo.XD Luego de eso para ocultar tu ip en el canal escribe: .vhost"

    retrun 0

}



bind pub - .vhost pub_vhost



proc pub_vhost {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Para crear un vhost 1º debes ir al canal #vhost (tipeando: /join #vhost) Una vez alli escribes lo siguiente: !vhost lo.que.se.te.ocurra.poner El canal te baneará, es normal y quiere decir que lo has hecho bien."

    retrun 0

}



bind pub - .xchat pub_xchat



proc pub_xchat {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Xchat para Windows: http://www.silverex.org/download/ -------------- Xchat para linux o Mac: http://xchat.org/download"

    retrun 0

}



bind pub - .vm pub_vm



proc pub_vm {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Virtual Machine, es como tener una pc DENTRO de tu pc, puedes crear una bajando el VBox: https://www.virtualbox.org/wiki/Downloads --- Luego descargar una imagen ISO de Google y ya puedes armar tu VM :D Es muy facil hacerlo, solo lee bienlas opciones al crear tu maquina virtual ."

    retrun 0

}



bind pub - .irssi pub_irssi



proc pub_irssi {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Otra variente de cliente irc. Puedes descargarla en: http://irssi.org/download"

    retrun 0

}



bind pub - .pad pub_pad



proc pub_pad {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Nuestro EtherPad para crear documentos en conjunto a otros usuarios (ubicado en uno de nuetros servers offshore) : http://pad.freed0m4all.org"

    retrun 0

}



bind pub - .criptografia pub_criptografia



proc pub_criptografia {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Borrado seguro, recomendado a 35 pases "CCleaner": http://www.piriform.com/ccleaner/download || Encriptación segura "TrueCrypt": http://www.truecrypt.org/downloads"

    retrun 0

}



bind pub - .vagos pub_vagos



proc pub_vagos {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Comandos utiles de Humanoid: !seen pedido - !seennick nick - !idle nick - !chanstats #canal - !seenstats - !ayuda seen - !ayuda chanstats - !ayuda seenstats"

    retrun 0

}

bind pub - .identificar pub_identificar

proc pub_identificar {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Para identificarte con Nickserv hazlo de la siguiente manera: /ns identify TUCLAVE o con la forma sin abreviar: /msg nickserv identify TUCLAVE"

    retrun 0

}

bind pub - .services pub_services

proc pub_services {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Aqui podras ver y aprenderte los comandos de los Servicios Anope, tipea lo siguiente: /msg nickserv help   -- /msg chanserv help    --  /msg botserv help   // o de la forma abreviada: /cs help  --  /ns help  -- /bs help // Sino funciona uno, intenta con el otro :)"

    retrun 0

}

bind pub - .guardia pub_guardia

proc pub_guardia {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Ok asi será -.-"
    
	retrun 0

}

bind pub - .bnc pub_bnc

proc pub_bnc {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG $channel :Pide tu BNC ingresando al canal #BlackZNC ( /join #BlackZNC ). Una vez alli, escribe el siguiente comando: !znc Usuario irc.tuserver.org e-mail *** EL ALTA DEL SERVICIO DEMORA DE 1 HS A 24 HS. CHEQUEA TU CORREO *** || Asegurate que el e-mail que brindes sea valido, de lo contrario no se otorgara el BNC || Dudas o consultas: contacto@blackznc.net || REGLAS: http://blackznc.net/reglas/"
    
	return 0

}

bind pub - !911 pub_911

proc pub_911 {nick uhost hand channel arg} {

  global botnick

    putserv "PRIVMSG #help :Maximus, $nick te llama en $channel razon: $arg"

	putserv "PRIVMSG Maximus :Maximus, $nick te llama en $channel razon: $arg"

	putserv "PRIVMSG $channel :$nick, se le ha mandado un mensaje a los administradores de F4All. Vendran tan pronto puedan."

    
	return 0

}


bind pub - .trolling pub_trolling

proc pub_trolling {nick uhost hand channel arg} {

  global botnick

	putserv "PRIVMSG $channel :$arg, Asi que te gusta el Flood??"
	putserv "PRIVMSG $channel :$arg, te gusta que te nombren???"
	putserv "PRIVMSG $channel :$arg, que lindo es escuchar el CUACK CUACK del script"
	putserv "PRIVMSG $channel :$arg, .l."
	putserv "PRIVMSG $channel :$arg, aprende, asi se Floodea .l."
	putserv "PRIVMSG $channel :$arg, aprende, asi se Floodea .l."
	putserv "PRIVMSG $channel :$arg, aprende, asi se Floodea .l."
	putserv "PRIVMSG $channel :$arg, aprende, asi se Floodea .l."
	putserv "PRIVMSG $channel :$arg, aprende, asi se Floodea .l."
	putserv "PRIVMSG $channel :$arg, aprende, asi se Floodea .l."
	putserv "PRIVMSG $channel :$arg, aprende, asi se Floodea .l."	
	putserv "PRIVMSG $arg :$arg,aprende, asi se Floodea .l."
	putserv "PRIVMSG $arg :$arg,aprende, asi se Floodea .l."
	putserv "PRIVMSG $arg :$arg,aprende, asi se Floodea .l."
	putserv "PRIVMSG $arg :$arg,aprende, asi se Floodea .l."
	putserv "PRIVMSG $arg :$arg,aprende, asi se Floodea .l."
	putserv "PRIVMSG $arg :$arg,aprende, asi se Floodea .l."
	putserv "PRIVMSG $arg :$arg,aprende, asi se Floodea .l."



    
	return 0

}

###############################################################################

#---- putlog "Editado por FUUU -- http://freed0m4all.org"  -------------------#

#---- putlog "Menu.tcl Para Eggdrop o Windrop By FUUU" -----------------------#

#---- putlog "Menu.tcl Cargado completamente, que tenga un buen dia" ---------#

###############################################################################