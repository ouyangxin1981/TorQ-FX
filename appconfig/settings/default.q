// configuration for default mail server
\d .email
enabled:1b                                      // whether emails are enabled
url:`$"smtp.office365.com:587"                                           // url of email server e.g. `$"smtp://smtpout.secureserver.net:80"
user:`$"auto@aquaq.co.uk"                                          // user account to use to send emails e.g. torq@aquaq.co.uk
password:`$"Circuit17"                                      // password for user account
from:`$"auto@aquaq.co.uk"                         // address for return emails e.g. torq@aquaq.co.uk
usessl:1b                                       // connect using SSL/TLS
debug:0i                                        // debug level for email library: 0i = none, 1i=normal, 2i=verbose
img:`$getenv[`KDBHTML],"/img/AquaQ-TorQ-symbol-small.png"       // default image for bottom of email

