# Ping Script Installation

> WLED has to be instance 1 and/or 2.

### 1. Download
Login via SSH and execute the following command:

<pre><code>rm hyper_ping.sh ; wget https://raw.githubusercontent.com/dan-froe/BASH/master/esp_ping/hyper_ping.sh</code></pre>

### 2. Set up crontab
execute: <pre><code>crontab -e</code></pre>
choose editor when prompted.
Add at the bottom of the file :

<pre><code>@reboot bash $HOME/hyper_ping.sh IP IP2 TIME</code></pre>

Replace **IP** with the IP of your ESP.
If you have a second ESP replace **IP2** with the IP of your second ESP.

Optional: Replace **TIME** with a duration in seconds. This extents the time between two successful ping. Standard is 4 seconds. 

**When there is only 1 ESP, variable TIME takes the place of IP2.
You have to provide at least one IP. IP2 and TIME are not required.**

Examples:

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39</code></pre>

or

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39 10</code></pre>

or

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39 192.168.178.110 60</code></pre>

### 3. Description 
The scripts starts with every boot. The script runs in an endless loop. 
First it pings the ESP(s). If it doesn't receive an answers it starts a new ping after 1 second. 
Does it receive a pong from the ESP(s) it will switch on instance 0-2. Furthermore it switches on LEDs and Grabber. It than proceeds to check if WLED starts streaming from hyperion. It repeats to switch on the instances and checking for streaming every second if it doesn't receive true (on) from all WLEDs. 
If it receives true the loop will stop. It than proceeds to ping the ESP(s) every 4 seconds. This duration can be extended by the TIME variable. When one device doesn't return a pong the whole script starts from the beginning. 

**It is possible to stop the streaming from hyperion via WLED GUI. The script only starts from beginning when it receives no pong.**
