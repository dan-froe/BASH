# Ping Skript Installation

Wenn etwas geändert werden soll Bescheid geben. Das Skript muss nicht endlos laufen. Man kann auch die Aktionszeiten usw anpassen. 

### 1. Download
Per SSH einloggen und im Start Verzeichnis folgendes ausführen:

<pre><code>wget https://raw.githubusercontent.com/dan-froe/BASH/master/esp_ping/hyper_ping.sh</code></pre>

### 2. Crontab einrichten
Folgendes ausführen: <pre><code>crontab -e</code></pre>
ggfs Editor auswählen.
Dann unterhalb des Textes folgendes einfügen :

<pre><code>@reboot bash $HOME/hyper_ping.sh IP TIME</code></pre>

Die Abkürzung **IP** mit der IP des ESP ersetzen.
Optional kann unter **TIME** eine Zeit in Sekunden eingetragen werden. Dies ist die Zeit zwischen jeder Anfrage solange er den ESP nicht erreicht. Standard sind 4 Sekunden. 

Beispiele:

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39</code></pre>

oder

<pre><code>@reboot bash $HOME/hyper_ping.sh 192.168.178.39 10</code></pre>

### 3. Erklärung
Bei jedem Boot wird das Skript gestartet. Das Skript läuft dann in einer Endlosschleife. 
Als erstes pingt es den ESP an. Erhält es keine Antwort wiederholt es den ping alle 4 Sekunden, oder die selbstgewählte Zeit.
Erreicht es den ESP schaltet das Skript die LED der Instanz 0 an. Danach prüft es, ob es die Info von Hyperion bekommt, dass die LED der Instanz 0 gestartet sind. Solange es kein "true" (an) bekommt wiederholt es jede Sekunde das anschalten.
Erhält es "true" wird es beendet und es pingt ca. alle 30 Sekunden den ESP an. Wenn er keinen Pong mehr erhält startet alles wieder von vorne. 
