Kopplung ist eines der zentralen Konzepte in der
Softwarearchitektur. Ein Programmstück A ist stark an ein anderes
Programmstück B gekoppelt, wenn es viele Abhängigkeiten von A nach B
gibt.  Das hat zur Folge, dass Änderungen in B mit hoher
Wahrscheinlichkeit auch Änderungen in A nach sich ziehen. Wenn unsere
Software also aus vielen solchen stark gekoppelten Teilen besteht,
müssen wir bei den kleinsten Anforderungsänderungen fast die gesamte
Software anfassen. Besser für die Wartbarkeit wäre das Gegenteil.

Die herkömmliche Sicht auf Kopplung ist die, dass hohe Kopplung dann
entsteht, wenn man als Programmierer nicht aufpasst beim
Programmieren: wenn man _nicht_ gegen explizite Schnittstellen
programmiert, wenn man _nicht_ modularisiert, wenn man _kein_
Visitor-Pattern verwendet. Kopplung, so scheint es, ist das Resultat
von Unterlassung.  Die Kopplung wieder zu senken erfordert dann
erhöhten Arbeitsaufwand: Maßnahmen des Refactorings. Beim iSAQB gibt
es einen ganzen Katalog sog. "Taktiken", die man anwenden kann, um die
Wartbarkeit zu erhöhen, sprich: die Kopplung zu senken. Dort stehen
Maßnahmen wie "Einhaltung des Open/Closed-Prinzips" oder der Einsatz
von Entwurfsmustern.

Wenn der sprichwörtliche Karren bereits im Dreck liegt, dann ist der
Einsatz von Taktiken sicherlich sinnvoll. Man muss den Karren
schließlich wieder aus dem Dreck ziehen und das erfordert Arbeit. Auch
beim Karren könnte man bei der Problemanalyse zum Ergebnis kommen,
dass es Unterlassungen waren, die zur Misere geführt haben. Der Fahrer
hat zu spät Schneeketten aufgezogen oder er hat es schlicht versäumt
ein Auto mit Allradantrieb zu kaufen.  Gleichzeitig ist aber auch
klar: Der eigentliche Ursprung des Problems liegt nicht in der
Unterlassung -- der Untat --, sondern in der Tat: Jemand ist in den
Dreck gefahren. Was hat der Karren überhaupt im Dreck zu suchen?

Besser als den Karren ständig aus dem Dreck zu ziehen, wär's doch, ihn
gar nicht erst in den Dreck zu fahren. Bei der Kopplung dasselbe:
Besser als ständig Maßnahmen zur Senkung der Kopplung ergreifen zu
müssen, wäre es doch, wenn wir diese Kopplung gar nicht erst einführen
würden. Die Ursünde der Softwarearchitektur ist nicht die Unterlassung
von heilenden Gegenmaßnahmen, sondern die Durchführung von schädlichen
Maßnahmen.

## Das Problem mit veränderlichem Zustand

Eine dieser schädlichen Maßnahmen betrifft das Programmieren mit
veränderlichem Zustand. Dass ständig mit veränderlichem Zustand
programmiert wird, ist nicht primär das Vergehen der Programmierer,
sondern schon das Vergehen der Programmiersprachen. Der Standard des
Umgangs mit Daten in allen populären Programmiersprachen wie Java, C++
oder Python ist, dass Daten veränderlich sind. In diesem
Programmiersprachen erfordert es explizite Maßnahmen, um diese Quelle
der Kopplung abzumildern. Es gibt beispielsweise Bibliotheken für
sog. persistente Datenstrukturen.

In der funktionalen Programmierung ist die Standardeinstellung genau
das Gegenteil: Daten sind unveränderlich.  Wenn wir mit Programmierern
mit klassischer OO-Ausbildung sprechen, werden wir oft gefragt, warum
wir uns dieses Bein stellen mit den unveränderlichen Daten. Aus deren
Sicht ist die Unveränderlichkeit eine Einschränkung des
Normalzustands. Falls wir funktionale Programmierer dann doch mal mit
Zustand programmieren wollen (weil das die Struktur des Problems
vorgibt), müssen wir extra Aufwand betreiben und bspw. zur
State-Monade greifen. Wenn man sich erst mal ans funktionale
Programmieren gewöhnt hat, wird man feststellen, dass erstaunlich
wenige Probleme inhärent mit Zustand zu tun haben. Die Essenz der
meisten Probleme lässt sich viel direkter mit reinen Funktionen
beschreiben. Wer nun allerdings eine Programmiersprache mit
Werkseinstellung Veränderlichkeit zur Hand hat, programmiert natürlich
auch dort mit veränderlichen Daten. Die Rate der Kopplung in den
resultierenden Programmen ist beträchtlich höher. Jedes Datenelement
besteht jetzt nämlich eigentlich aus zwei Konzepten: Dem Datenelement
ansich und einem Ort für das Datenelement. Das hat weitreichende
Konsequenzen, denn damit ist auch jeder Algorithmus, der mit diesen
veränderlichen Daten arbeitet, auf einmal einer, der über Zeit
nachdenken muss.

```java
public class Person {
    private String name;
    private String address;
    ...
    public void setAddress(String newAddress) {
        this.address = newAddress;
    }
}

public class DepartmentA {
    private Person myPerson;
    ...
    public void receivePerson(Person p) {
        myPerson = p;
    }
}

public class DepartmentB {
    private Person myPerson;
    ...
    public void transferPerson(DepartmentA other) {
        // Transfer to other department
        other.receivePerson(myPerson);
        // Delete here
        myPerson = null;
    }
    
    public void backToTheOffice() {
        if (myPerson != null) {
            myPerson.setAddress("Seattle");
        }
    }
}
```

Die Java-Klasse `Person` beschreibt eine veränderliche Person. Die
Signatur von `setAddress` sagt zwar, dass nichts zurückkehrt (`void`),
aber das bedeutet nicht, dass gar nichts geschieht. Die gegebene
Person wird verändert. Darunter sehen wir zwei Verwender: Die
Abteilungen `DepartmentA` und `DepartmentB`. `DepartmentA` kann mit
`receivePerson` eine Person als neuen Mitarbeiter
empfangen. `DepartmentB` kann Personen mit `transferPerson` an
`DepartmentA` transferieren. `DepartmentB` kann außerdem mit
`backTotheoffice` die Adresse seines Mitarbeiters verändern.

Obiger Code ist ziemlich gewöhnlicher Java-Code.  Es passiert nicht
viel, aber dennoch mehr als man denkt.  Die Werkseinstellung von Java
ist, dass Objekte als Referenz übergeben werden. In anderen Worten:
`receivePerson` nimmt streng genommen nicht einfach die Informationen
zu einer Person entgegen, sondern sie nimmt einen Ort, an dem diese
Informationen liegen, entgegen. Das hat verheerende
Konsequenzen. `DepartmentA` kann sich nicht sicher sein, ob die
Informationen, die an diesem Ort liegen, eventuell verändert
werden. In der Tat zeigt die Signatur von `DepartmentB` ja auch noch
die Methode `backToTheOffice`. Das lässt schlimmes erahnen. Ein
vorsichtiger Verwender, d.h. ein vorsichtiger Programmierer der Klasse
`DepartmentA` würde deshalb vielleicht in `receivePerson` eine Kopie
der übergebenen Person machen und diese Kopie an einen neuen -- nicht
geteilten -- Speicherort legen. Dass das in diesem Fall nicht nötig
ist, wird erst mit Blick auf die Implementierung von `transferPerson`
klar: Nachdem die Person übergeben wurde, wird sie von `DepartmentB`
vergessen, indem dieses das Feld `myPerson` auf `null` setzt.

Was hat das ganze nun mit Kopplung zu tun? Da wir nicht nur
(unveränderliche) Daten übergeben, sondern auch Orte, an denen diese
Daten liegen, muss sich der Verwender `DepartmentA` über sehr viele
Eigenschaften der Klasse `DepartmentB` informieren. Die Signatur von
`receivePerson` legt nahe, dass es nur eine Abhängigkeit zur Klasse
`Person` gibt. Das ist aber falsch. Da ein veränderlicher Speicherort
übergeben wird, muss sich der Programmierer von `DepartmentB` auch mit
allen anderen Verwendern der `Person`-Klasse befassen.

Ein defensiver Umgang mit diesem Problem wäre es, direkt eine Kopie
der gegebenen Person anzulegen.

```java
public class DepartmentA {
    private Person myPerson;
    ...
    public void receivePerson(Person p) {
        myPerson = p.clone();
    }
}
```

`receivePerson` erhält so zwar immer noch einen Speicherort, aber
dieser ist nun wirklich nur noch Mittel zum Zweck des reinen
(unveränderlichen) Datenaustauschs.

In einer funktionalen Sprache würde man das so
ausdrücken, dass `move` eine Funktion von einer (alten) Person zu
einer (neuen) Person ist.

```haskell
data Person = Person { name :: String, address :: Address }
move :: String -> Person -> Person
move newAddress (Person name _) = Person name newAddress
```
