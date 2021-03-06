#!/bin/bash

# Copyright (c) 2021 Robert LaRocca http://www.laroccx.com

# Helpful Linux bash_aliases for sysadmins, developers and the forgetful.

export BASH_ALIASES_VERSION="1.2.18-$HOSTNAME"

if [ $USER = 'root' ]; then
	printf '🧀 '
elif [ $USER = 'user1' ]; then
	printf '👾️ '
elif [ $USER = 'user2' ]; then
	printf '💵️ '
fi

# edit bash aliases using gedit (Text Editor)
edit-bash-aliases() {
	case "$1" in
	--gedit)
		gedit $HOME/.bash_aliases
		;;
	--nano)
		nano $HOME/.bash_aliases
		;;
	--vi | --vim)
		vim $HOME/.bash_aliases
		;;
	*)
		$(which xdg-open) $HOME/.bash_aliases
		;;
	esac
};

# prevent conflicts with existing kubectl installs
alias kubectl="microk8s kubectl"

# similar to the macOS 'open' command
alias open="$(which xdg-open)"

# search bash history with grep
alias hgrep="history | grep -i"

# display the current ipv4 and ipv6 address
whatsmyip() {
	ipv4_address="$(curl -s4 https://ifconfig.co/ip)"
	ipv6_address="$(curl -s6 https://ifconfig.co/ip)"

	if [ -n "$ipv4_address" ]; then
		echo "IPv4: $ipv4_address"
	fi

	if [ -n "$ipv6_address" ]; then
		echo "IPv6: $ipv6_address"
	fi
};

# display the current logical volume management (lvs) storage
lvms() {
	# require root privileges
	if [ $UID != 0 ]; then
		logger -i "Error: lvms must be run as root!"
		echo "Error: lvms must be run as root!"
		break
	else
		echo '  --- Physical volumes ---'
		pvs ; echo
		echo '  --- Volume groups ---'
		vgs ; echo
		echo '  --- Logical volumes ---'
		lvs ; echo
	fi
};

lvmdisplay() {
	# require root privileges
	if [ $UID != 0 ]; then
		logger -i "Error: lvmdisplay must be run as root!"
		echo "Error: lvmdisplay must be run as root!"
		break
	else
		pvdisplay
		vgdisplay
		lvdisplay
	fi
};

# display command reminder to create a lvm snapshot
lvmsnapshot() {
	cat <<-EOF_XYZ
	Logical volume snapshots are created using the 'lvcreate' command.

	Examples:
	 lvcreate -L 50%ORIGIN --snapshot --name snap_1 /dev/mapper/ubuntu-root
	 lvcreate -L 16G -s -n snap_2 /dev/ubuntu/logical-volume-name

	See the lvcreate(8) manual for more information.
	EOF_XYZ
};

# generate a secure random password
alias mkpw="mkpassword"
mkpassword() {
	local a=$(pwgen -A -0 -B 6 1)
	local b=$(pwgen -A -0 -B 6 1)
	local c=$(pwgen -n -B 6 1)
	echo "$a-$b-$c"
};

# generate a secure random pre-shared key
alias mkpsk="mkpresharedkey"
mkpresharedkey() {
	local a=$(pwgen -A -0 -B 6 1)
	local b=$(pwgen -A -0 -B 6 1)
	local c=$(pwgen -n -B 6 1)
	echo "$a-$b-$c" | sha256sum | cut -f1 -d' '
};

# update apt repositories and upgrade installed packages
swupdate() {
	case "$1" in
		-f | --fw | --firmware)
			sudo apt --yes clean
			sudo apt --yes update
			sudo apt --yes upgrade
			sudo apt --yes full-upgrade
			sudo apt --yes autoremove
			sudo snap refresh
			sudo fwupdmgr --force refresh
			sudo fwupdmgr update
			;;
		-l | --lts)
			sudo apt --yes clean
			sudo apt --yes update
			sudo apt --yes upgrade
			sudo apt --yes full-upgrade
			sudo apt --yes autoremove
			sudo snap refresh
			sudo apt --yes install update-manager-core
			sudo cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
			sudo sed -E -i s/'^Prompt=.*'/'Prompt=lts'/g /etc/update-manager/release-upgrades
			sudo do-release-upgrade
			;;
		-r | --release)
			sudo apt --yes clean
			sudo apt --yes update
			sudo apt --yes upgrade
			sudo apt --yes full-upgrade
			sudo apt --yes autoremove
			sudo snap refresh
			sudo apt --yes install update-manager-core
			sudo cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.bak
			sudo sed -E -i s/'^Prompt=.*'/'Prompt=normal'/g /etc/update-manager/release-upgrades
			sudo do-release-upgrade
			;;
		*)
			if [ -z "$1" ]; then
				sudo apt --yes clean
				sudo apt --yes update
				sudo apt --yes upgrade
				sudo apt --yes full-upgrade
				sudo apt --yes autoremove
				sudo snap refresh
			else
				cat <<-EOF_XYZ
				swupdate: unrecognized option '$1'
				Try 'swupdate --help' for more information.
				EOF_XYZ
			fi
			;;
	esac
};

# check website availability
alias check-website="test-website"
test-website() {
	local server_address="$1"

	if [ -n "$server_address" ]; then
		echo "$server_address"
		curl -ISs --connect-timeout 8 --retry 2 "$server_address"
	else
		for server_address in \
			https://www.bing.com \
			https://duckduckgo.com \
			https://www.google.com \
			https://www.yahoo.com ;
		do
			echo "$server_address"
			curl -ISs --connect-timeout 8 --retry 2 "$server_address"
			echo
		done
	fi
};

# test firewall ports using telnet
test-port() {
	local server_address='telnet.example.com'
	local service_port='8738'

	case "$1" in
	-p | --port)
		telnet $server_address "$2"
		;;
	*)
		if [ -z "$1" ]; then
			telnet $server_address $service_port
		else
			cat <<-EOF_XYZ
			test-port: unrecognized option '$1'
			Try 'test-port --port <number>' to check a specific port.
			EOF_XYZ
		fi
		;;
	esac
};

# merge current master with upstream
git-merge-upstream() {
	case "$1" in
	-H | --help)
		cat <<-EOF_XYZ
		Update a fork by merging with upstream using the 'git' command.

		Examples:
		 remote add upstream https://example.com/project-repo.git
		 git fetch upstream
		 git checkout master
		 git merge upstream/master
		 git push origin master

		See gittutorial(7) and the git(1) manual for more information.
		EOF_XYZ
		;;
	*)
		local upstream_repo_address="$1"
		remote add upstream $upstream_repo_address
		git remote -v
		git fetch upstream
		git checkout master
		git merge upstream/master
		git push origin master
		;;
	esac
};

# include private bash_aliases
source $HOME/.bash_aliases_private

