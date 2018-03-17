#!/usr/bin/expect

set remoteIp "47.93.13.234"
set remotePwd "zZ123456"
set timeout 15

spawn scp /mnt/c/swap/projects/os/build/boot.com root@${remoteIp}:/root/boot.com
expect {
  "*password:" {send "${remotePwd}\r"}
}

spawn ssh root@${remoteIp}
expect {
  "*password:" {send "${remotePwd}\r"}
}
expect "#"
send "./build.sh\r"
expect "#"
send "exit\r"
expect eof

spawn scp root@${remoteIp}:/root/os.img /mnt/c/swap/freedos-img/os.img
expect {
  "*password:" {send "${remotePwd}\r"}
}
expect eof
