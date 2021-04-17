# Ping Skript Installation

> Das Skript unterstützt derzeit nur WLED als Instanz 1 und/oder 2.

### 1. Download
Per SSH einloggen und im Start Verzeichnis folgendes ausführen:

<pre><code>rm hyper_ping.sh ; wget https://raw.githubusercontent.com/dan-froe/BASH/master/esp_ping/hyper_ping.sh</code></pre>

### 2. Crontab einrichten
Folgendes ausführen: <pre><code>crontab -e</code></pre>
ggfs Editor auswählen.
Dann unterhalb des Textes folgendes einfügen :

<pre><code>@reboot bash $HOME/hyper_ping.sh IP IP2 TIME</code></pre>

Die Abkürzung **IP** mit der IP des ESP ersetzen.
Die Abkürzung **IP2** mit der IP des 2. ESP ersetzen.

Optional kann unter **TIME** eine Zeit in Sekunden eingetragen werden. Dies verlängert die Zeit zwischen den Anfragen nach einem erfolgreichen Ping. Standard sind 4 Sekunden. 

**Sollte nur 1 ESP vorhanden sein, tritt an die Stelle von IP2 die TIME Variable.
Es muss mindestens eine IP angegeben werden. IP2 und TIME sind nicht zwingend.**

Beispiele:

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39</code></pre>

oder

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39 10</code></pre>

oder

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39 192.168.178.110 60</code></pre>

### 3. Erklärung
Bei jedem Boot wird das Skript gestartet. Das Skript läuft dann in einer Endlosschleife. 
Als erstes pingt es den/die ESP an. Erhält es keine Antwort wiederholt es den ping jede Sekunde.
Erreicht es den/die ESP schaltet das Skript die Instanzen 0-2 an, sowie Grabber und LED. Danach prüft es, ob es die Info von WLED bekommt, dass die ESP einen Stream von Hyperion erhalten. Solange es kein "true" (an) bekommt wiederholt es jede Sekunde das Anschalten, sowie die Prüfung.
Erhält es "true" wird diese Schleife beendet und es wird 5 Sekunden lang der Rainbow Swirl gezeigt. Danach pingt es wieder alle 4 Sekunden den/die ESP an. Diese Zeit ist mit TIME verlängerbar. Wenn er keinen Pong mehr erhält startet alles wieder von vorne. 

**Es ist möglich das Streamen von Hyperion an die ESPs über die WLED GUI zu unterbrechen/auszusetzen. Das Skript fängt erst wieder von vorne an, wenn es keinen Pong mehr von den ESPs erhält.**
