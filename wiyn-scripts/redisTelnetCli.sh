#!/usr/bin/expect

set timeout 20
set name [lindex $argv 0]
set password [lindex $argv 2]
set port [lindex $argv 1]
set command [lindex $argv 3]
spawn telnet $name $port

expect "Escape character is '^]'."
send "auth $password\n"
expect "+OK"
send "$command\n"
expect "+OK"

