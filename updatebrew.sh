#!/usr/bin/env zsh -f
# Purpose: update brew and save output
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2019-11-07

NAME="$0:t:r"

	## These commands save us from using `date`
	## You should not need to change these lines unless you
	## want to change the format of the date/time stamp
zmodload zsh/datetime
TIME=$(strftime "%Y-%m-%d--%H.%M.%S" "$EPOCHSECONDS")
function timestamp { strftime "%Y-%m-%d--%H.%M.%S" "$EPOCHSECONDS" }

########################################################################################
##
##		BELOW HERE IS THE ONLY PLACE YOU MIGHT NEED TO EDIT SOMETHING
##

	# This is in the GitHub repo
IMAGE="$HOME/Pictures/homebrew-256x256.png"

	# If you want one msg for all updates. use this:
LOG="$HOME/Library/Logs/$NAME.log"

	# If you want a separate msg for each time this runs, uncomment the next line
#LOG="$HOME/Library/Logs/$NAME.$TIME.log"

##
##		ABOVE HERE IS THE ONLY PLACE YOU MIGHT NEED TO EDIT SOMETHING
##
########################################################################################
##
##		YOU SHOULD NOT NEED TO EDIT ANYTHING BELOW THIS LINE.
##

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi

	# this is how we msg things to a file and to the notification system, if possible
function msg {

	if (( $+commands[growlnotify] ))
	then

		growlnotify \
			--image "$IMAGE" \
			--identifier "$NAME" \
			--message "$@" \
			--title "$NAME at `timestamp`"

	elif (( $+commands[terminal-notifier] ))
	then

		terminal-notifier -message "$@" -contentImage "$IMAGE" -title "\$NAME" -subtitle "`timestamp`"

	fi

	echo "$NAME [`timestamp`]: $@" | tee -a "$LOG"

}

	########################################################################################
	## 		Was this script launched by launchd? If so, sleep 10
	## 		just to give things a chance to happen if this is at system startup
PPID_NAME=$(/bin/ps -p $PPID | fgrep '/sbin/launchd' | awk '{print $NF}')

if [ "$PPID_NAME" = "/sbin/launchd" ]
then
	sleep 10
fi

########################################################################################

if ((! $+commands[brew] ))
then
		# check to make sure that the `brew` command is installed
	msg "'brew' is required but not found in '$PATH'."
	exit 0
fi

########################################################################################

msg "brew update is starting"

(brew update 2>&1) | tee -a "$LOG"

EXIT="$?"

if [ "$EXIT" = "0" ]
then

	msg "'brew update' succeeded"

else

	msg "brew update failed. See $LOG"
	exit 0
	# if we use 'exit 1' then `launchd` won't try again
fi

########################################################################################

msg "'brew upgrade' starting"

(brew upgrade 2>&1) | tee -a "$LOG"

EXIT="$?"

if [ "$EXIT" = "0" ]
then
	msg "'brew upgrade' succeeded"
else
	msg "'brew upgrade' failed (\$EXIT = $EXIT)"
	exit 0
fi

########################################################################################

msg "'brew cleanup' starting"

(brew cleanup 2>&1) | tee -a "$LOG"

########################################################################################

msg "Checking 'brew doctor'"

	## If 'brew doctor' always reports some innocuous issue, you can create an
	## 'Expected Output' file which the script will use for comparison, and will
	## only draw your attention to it if it deviates from what is 'expected'
	##
	## Create it using this command:
	#	(brew doctor 2>&1 ) >| ~/Library/Logs/brew.doctor.expected.log
	#
EXPECTED_OUTPUT="$HOME/Library/Logs/brew.doctor.expected.log"

if [[ -e "$EXPECTED_OUTPUT" ]]
then

	ACTUAL_OUTPUT="$HOME/Library/Logs/brew.doctor.new.log"

	rm -f "$ACTUAL_OUTPUT"

	(brew doctor 2>&1) | tee "$ACTUAL_OUTPUT"

		# are the files are identical?
	cmp --quiet "$ACTUAL_OUTPUT" "$EXPECTED_OUTPUT"

	EXIT="$?"

	if [ "$EXIT" = "0" ]
	then
		msg "Finished at `timestamp` (brew doctor is as expected)"
	else
		msg "Finished, but 'brew doctor' reports NEW issues"
	fi

else

	## This is what is used if there is no EXPECTED_OUTPUT file

	RESULT=$(brew doctor 2>&1 | tee -a "$LOG")

	if [[ "$RESULT" == "Your system is ready to brew." ]]
	then

		msg "Finished at `timestamp` (brew doctor is good)"

	else

		msg "Finished, but 'brew doctor' reports issues. See '$LOG'"

		echo "The result of 'brew doctor' is: $RESULT" >> "$LOG"
	fi

fi

exit 0

#
#EOF
########################################################################################
