#!/usr/bin/env bash

typeset MYSELF="$(realpath $0)"
typeset MYPATH="${MYSELF%/*}"

#set -o nounset -o noclobber
#export LC_ALL=C
#export PATH="/bin:/sbin:/usr/bin:/usr/sbin:$PATH"
#export PS4=' (${BASH_SOURCE##*/}:$LINENO ${FUNCNAME[0]:-main})  '

# Load main library
typeset -a ammpaths=("$MYPATH/ammlib" "$HOME/.ammlib" "/etc/ammlib")
for ammpath in "${ammpaths[@]}" fail; do
	[[ -e "$ammpath/ammlib" ]] && source "$ammpath/ammlib" && break
done
if [[ "$ammpath" == "fail" ]]; then
	echo >&2 "Unable to find ammlib in paths '${ammpaths[@]}'"
	echo >&2 "Download it with 'git clone https://github.com/Saruspete/ammlib.git $MYPATH'"
	exit 1
fi

# Load the required libraries
ammLib::Require "optparse" "table"

# Add options




function timer::getProcfs {
	if [[ -r "/proc/timer_list" ]]; then
		echo "$(< /proc/timer_list)"
	elif ammExec::AsUser "root" cat /proc/timer_list; then
		:
	else
		ammLog::Error "Cannot get /proc/timer_list content. Run as root, or grant 'sudo cat /proc/timer_list'"
		return 1
	fi
}

# From "enum hrtimer_base_type":
typeset -a CLOCK_LIST=(
	MONOTONIC      REALTIME      BOOTTIME      TAI
	MONOTONIC_SOFT REALTIME_SOFT BOOTTIME_SOFT TAI_SOFT
)


typeset -i currCPU=-1 currClock=-1 timerCntMax=0 timerTotal=0
typeset -iA timersCnt=(0 0 0 0  0 0 0 0)

#ammTable::Create "Timers" "CPU|size:3" "Total|size:3"  "${CLOCK_LIST[@]/%/|size:10}"
ammTable::Create "Timers" "CPU|size:3" "Total|size:4"  "${CLOCK_LIST[@]}"

# Parse the file
while read line; do
	typeset key="${line%%:*}"
	typeset val="${line#*:}"

	case "$line" in

		# New CPU/Clock definition
		cpu:\ [0-9]*)
			currCPU=$val
			;;
		*clock\ [0-9]:*)
			currClock="${key#* }"
			;;

		# New timer
		*expires\ at*)
			typeset timeLeft="${line#*in }"
			timeLeft="${timeLeft% *}"

			timerTotal+=1
			timersCnt[$currClock]+=1
			;;

		# Empty line act as block separator between CPU
		"")
			[[ "$currCPU" == "-1" ]] && continue
			# Display a line
			ammTable::AddRow "$currCPU" "$timerTotal" "${timersCnt[@]}"

			# Reset values
			currTimers=()
			currClock=0
			currCPU=0
			timerTotal=0
			timersCnt=(0 0 0 0  0 0 0 0)
			;;

		Tick\ Device:\ mode:*)
			break
			;;

		# now at 312894874983064 nsecs
		now\ at*)
			;;
	esac

done < <( timer::getProcfs )

ammTable::Display
