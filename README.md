# ASL3 Smart Announce

This shell script automates playing periodic announcements on an AllStarLink 3 (ASL3) node without the need for creating macros and schedules in the rpt.conf file. It monitors node activity and plays WAV files only when the node is idle.

---

## Features

- Plays announcement once per hour (configurable).
- Detects if the ASL3 node is currently busy before playing.
- Ability to set a specific time period to play announcements (i.e. turns off at night, doesn't play during a net, etc.)
- Logs activity to a configurable log file.

---

## Requirements

- Linux system with ASL3 and Asterisk installed.
- `bash` shell.
- Properly formatted WAV files stored in `/var/lib/asterisk/sounds/`.
- User permissions to run Asterisk CLI commands.

---

## Installation

1. **Clone the repository:**

   ```git clone https://github.com/GooseThings/asl3-smart-announce.git```
   
   ```cd asl3-smart-announce```
   
 3. Place your WAV files in ```/var/lib/asterisk/sounds/```.
    * Example files: ID.wav, ID2.wav, cowboy.wav, jessica.wav
 4. Edit the script configuration:
    Open ASL3-smart-announce.sh and set your ASL3 node number and WAV file list
 5. Make the script executable: ```chmod +x ASL3-smart-announce.sh```
 ## Usage
 ### Run manually in the background
```nohup ./announce.sh > /var/log/asl3-announcer.log 2>&1 &```
 ### Run via systemd service (recommended)
   Create /etc/systemd/system/asl3-smart-announce.service with: 
 
```
[Unit]
Description=ASL3 Smart Announcer Script
After=network.target

[Service]
ExecStart=/path/to/ASL3-smart-announce.sh
Restart=always
User=asterisk
Group=asterisk

[Install]
WantedBy=multi-user.target
```

 ### Reload systemd and enable service:

```
sudo systemctl daemon-reload
sudo systemctl enable asl3-smart-announce.service
sudo systemctl start asl3-smart-announce.service
```
 ### Give log the proper permissions
 * ```sudo touch /var/log/ASL-smart-announce.log```
 * ```sudo chown asterisk:asterisk /var/log/ASL-smart-announce.log```
 ### Monitor log as it runs:
  * ```tail -f /var/log/triathlon-announcer.log```

 ## Notes
The script assumes WAV files are placed under /var/lib/asterisk/sounds/ without file extensions in the configuration. WAV files must be 8000Hz mono WAV files of the proper format.

Ensure the user running the script has permission to access the sound files and run Asterisk CLI commands.

If you don't want the announcements to play over a repeater that is connected to the node (ADVISABLE UNLESS IT IS YOUR REPEATER) change ```playback``` to ```localplay``` in the ```ASL3-smart-announce.sh``` file.

 ## Troubleshooting
If announcements do not play, verify file paths and permissions.

Use the log file (/var/log/ASL3-smart-announce.log) for debugging output.

Check that the rpt localplay command works manually in the Asterisk CLI with the chosen file names.

## License
MIT License
