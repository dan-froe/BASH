# Ping Skript Installation

Wenn etwas geändert werden soll Bescheid geben. Das Skript muss nicht endlos laufen. Man kann auch die Aktionszeiten usw anpassen. 

### 1. Download
Per SSH einloggen und im Start Verzeichnis folgendes ausführen:

nur wenn Skript schon lokal vorhanden zuerst <pre><code>rm hyper_ping.sh</code></pre>

ansonsten nur/danach


<pre><code>wget https://raw.githubusercontent.com/dan-froe/BASH/master/esp_ping/hyper_ping.sh</code></pre>

### 2. Crontab einrichten
Folgendes ausführen: <pre><code>crontab -e</code></pre>
ggfs Editor auswählen.
Dann unterhalb des Textes folgendes einfügen :

<pre><code>@reboot bash $HOME/hyper_ping.sh IP IP2 TIME</code></pre>

Die Abkürzung **IP** mit der IP des ESP ersetzen.
Die Abkürzung **IP2** mit der IP des 2. ESP ersetzen.

Optional kann unter **TIME** eine Zeit in Sekunden eingetragen werden. Dies verlängert die Zeit zwischen den Anfragen nach einem erfolgreichen Ping. Standard sind 4 Sekunden. 
**Sollte nur 1 ESP vorhanden sein, tritt an die Stelle von IP2 die TIME Variable.**
Beispiele:

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39</code></pre>

oder

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39 10</code></pre>

oder

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39 192.168.178.110 60</code></pre>

### 3. Erklärung
Bei jedem Boot wird das Skript gestartet. Das Skript läuft dann in einer Endlosschleife. 
Als erstes pingt es den ESP an. Erhält es keine Antwort wiederholt es den ping alle 4 Sekunden.
Erreicht es den ESP schaltet das Skript die LED der Instanz 0 an. Danach prüft es, ob es die Info von Hyperion bekommt, dass die LED der Instanz 0 gestartet sind. Solange es kein "true" (an) bekommt wiederholt es jede Sekunde das anschalten.
Erhält es "true" wird diese Schleife beendet und es wird 5 Sekunden lang der Rainbow Swirl gezeigt. Danach pingt es wieder alle 4 Sekunden den ESP an. Diese Zeit ist mit TIME verlängerbar. Wenn er keinen Pong mehr erhält startet alles wieder von vorne. 
