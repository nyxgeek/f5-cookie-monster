######     BIG-IP COOKIE DECODER - 2015
# Based on original code for Getting Cookies Using Powershell
# https://gallery.technet.microsoft.com/scriptcenter/Getting-Cookies-using-3c373c7e
# 
# Big-IP Decoding instructions found at
# https://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html
# Solution: enable encrypted cookies


param (
	[string]$url = $( Read-Host "Input server url, please" )
)

$attempts = 10
[array]$resultarray = ""




function cookiemonster{

$x = @"
                .---. .---. 
               :     : o   :    me want cookie!
           _..-:   o :     :-.._    /
       .-''  '  ``---' ``---' "   ``-.    
     .'   "   '  "  .    "  . '  "  ``.  
    :   '.---.,,.,...,.,.,.,..---.  ' ;
    `. " ``.                     .' " .'
     `.  '``.                   .' ' .'
      `.    ``-._           _.-' "  .'  .----.
        `. "    '"--...--"'  . ' .'  .'  o   `.
        .'`-._'    " .     " _.-'``. :       o  :
  jgs .'      ```--.....--'''    ' `:_ o       :
    .'    "     '         "     "   ; ``.;";";";'
   ;         '       "       '     . ; .' ; ; ;
  ;     '         '       '   "    .'      .-'
  '  "     "   '      "           "    _.-'

"@
echo $x

}


######################### START HERE #########################

clear

$tempurl = read-host -prompt "Enter a URL to check: "
if ( $tempurl ){ $url = $tempurl}

echo "`n`n--------------------------------------------------------------`n`nTESTING $url`n`n--------------------------------------------------------------`n"
cookiemonster



foreach ($number in 1..$attempts){


$webrequest = Invoke-WebRequest -Uri $url -SessionVariable websession 
$cookies = $websession.Cookies.GetCookies($url) 
 
function COOKIE_MONSTER([string]$cookienom) {
  #first we split the cookie into parts divided by periods
  $cookie_crumble = $cookienom.split(".")

# IP ADDRESS
#  Write-Output "Cookie Part 1: $($cookie_crumble[0])"

# PORT NUMBER
#  Write-Output "Cookie Part 2: $($cookie_crumble[1])"

# NOT USED
#  Write-Output "Cookie Part 3: $($cookie_crumble[2])"



### FIRST LET'S DO THE IP CONVERSION

  #convert the decimal integer into hex
  $cookie_server_hex = [convert]::ToString($($cookie_crumble[0]),16)

  #now split into hex (2-chars each)
  $cookie_server_hex_array = $cookie_server_hex -split '(..)' | ? { $_ }

  #reverse ordering and convert back to int
  $octet_a = [convert]::ToInt32("$($cookie_server_hex_array[3])",16)
  $octet_b = [convert]::ToInt32("$($cookie_server_hex_array[2])",16)
  $octet_c = [convert]::ToInt32("$($cookie_server_hex_array[1])",16)
  $octet_d = [convert]::ToInt32("$($cookie_server_hex_array[0])",16)

#DEBUG  write-output "Internal IP for server is $octet_a.$octet_b.$octet_c.$octet_d"


### OK NOW LET'S SEE WHAT PORT IT'S ON

  #convert the decimal integer into hex
  $cookie_port_hex = [convert]::ToString($($cookie_crumble[1]),16)

  #now split into hex (2-chars each)
  $cookie_port_hex_array = $cookie_port_hex -split '(..)' | ? { $_ }

  $encodedport = "$($cookie_port_hex_array[1])$($cookie_port_hex_array[0])"
  $portnumber = [convert]::ToInt32($encodedport,16)

#DEBUG  Write-Output "Port is $portnumber"

return "$octet_a.$octet_b.$octet_c.$octet_d`:$portnumber"

 }



 
foreach ($cookie in $cookies) { 
     # You can get cookie specifics, or just use $cookie 
     # This gets each cookie's name and value 
     if ( $($cookie.name) -like "BIGipServer*" ) {
        write-host "BIG-IP COOKIE FOUND!!! Cookie value is $($cookie.value)"
        write-host "NOM NOM NOM NOM NOM NOM NOM NOM NOM NOM NOM"
        $nomnomcookies = COOKIE_MONSTER $($cookie.value)
        write-host "FOUND $nomnomcookies"
        $resultarray += "$nomnomcookies"

    }
}

#end of foreach loop
}


echo "`n------------------------------------------------------------"
echo "`nFINAL RESULTS:"
echo $($resultarray | sort | get-unique)
