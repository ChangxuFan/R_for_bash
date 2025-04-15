#!/bin/bash
set -e
# converting bf.R to a bash script to make it faster (avoid loading R every time!)
# The original bf.R is in bash2ftp.R
pwd=`pwd`
for i in $@; do
	if [[ ! ${i} =~ ^(~|/) ]]; then
	  # echo "relative path"
	  i=${pwd}/${i}
	  # echo $i
	fi
	ftp=$(echo "$i" | sed "s|^~|https://wangftp.wustl.edu/~$user|")
	ftp=$(echo "$ftp" | sed "s|/bar/$user|https://wangftp.wustl.edu/~$user|")
	ftp=$(echo "$ftp" | sed "s|/wanglab/$user|https://wangcluster.wustl.edu/~$user|")
	ftp=$(echo "$ftp" | sed "s|/scratch/$user/|https://wangftp.wustl.edu/~$user/sth/|")
	ftp=$(echo "$ftp" | sed "s|/scratch/fanc/|https://wangftp.wustl.edu/~cfan/sth/|")

	echo $ftp
done
