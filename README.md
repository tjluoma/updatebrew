# updatebrew
This is the script that I use to update [brew](https://brew.sh) automatically using `launchd`

## updatebrew.sh

This is the actual shell script which does all the work.

It must be installed at `/usr/local/bin/updatebrew.sh` and it must be executable:

	chmod 755 /usr/local/bin/updatebrew.sh


## com.tjluoma.updatebrew.plist

This is the `launchd` plist file. It must be installed as `~/Library/LaunchAgents/com.tjluoma.updatebrew.plist`

Once installed, it can be started by giving this command in Terminal:

	launchctl load ~/Library/LaunchAgents/com.tjluoma.updatebrew.plist


### “How do I change how often it runs?”

The frequency that `updatebrew.sh` is run is controlled by `launchd`, which is defined by the 'com.tjluoma.updatebrew.plist' file, specifically these lines:

```
	<key>StartInterval</key>
	<integer>172800</integer>
```

172800 is the number of seconds equal to two days.

86400 would equal one day.

You can change that number to be anything you want, but it does not need to be more often than once-per-day.

### “How do I run it at the same time each day?”

If you want `updatebrew.sh` to be run at the same time every day, then you need to edit the 'com.tjluoma.updatebrew.plist' file and _delete_ the `<key>StartInterval</key>` line and the `<integer>172800</integer>` line.

Then put these lines in their place:

```
	<key>StartCalendarInterval</key>
	<dict>
		<key>Hour</key>
		<integer>4</integer>
		<key>Minute</key>
		<integer>0</integer>
	</dict>
```

That will run it at exactly 4:00 a.m. (local time) each day.

Change the `4` to anything between `0-23` for the hour if you want to change the hour.

Change the `0` to anything between `0-59` if you want to change the minute.

## homebrew-256x256.png (optional)

![Homebrew Logo](homebrew-256x256.png)

This is the logo file that I use with either [growlnotify](http://growl.cachefly.net/GrowlNotify-2.1.zip) or [terminal-notifier](https://github.com/julienXX/terminal-notifier), assuming that you have either installed.

* If you have both installed, `growlnotify` will be used (because I assume if you have [Growl](https://apps.apple.com/us/app/growl/id467939042?mt=12) installed, you want to use Growl.)

* If you do not have either one installed, neither will be used and you will never see this image.

***If you do want to use this image*** with either `growlnotify` or `terminal-notifier` then it must be saved to `~/Pictures/homebrew-256x256.png`.

