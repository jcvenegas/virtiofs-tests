#!/bin/bash
set -o nounset

csv_file="${1:-iotop.csv}"

echo "second,pid,process,read,write" > "${csv_file}"
s="0"
while true;do
	sudo iotop -n 1 -k -qqq -o|awk -v s="${s}" '{print s","$1","$12","$4","$6}' >> "${csv_file}"
	sleep 1;
	((s++))
done
