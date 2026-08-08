# Fraga BO2

<details>
  <summary>English description:</summary>

## Game Changes

- Backspeed fixed

## HUD CHANGES

    Game timer
    Round timer
    Trap timer
    Box hits counter
    Raygun tracker
    SPH meter (default start at 50)

## MAP CHANGES

Tranzit

    Bank full for all players
    All perman perks are given on spawn to all players
    MP5 upgraded on weapon locker for all players
    Bus location with /bus 1 (r3705+)
    
Survival Maps

    Raygun & Raygun MK2 average trackers

Town

    You can chose box location with /box
    1 for doubletap
    2 for quick revive

Nuketown

    With /perkrng 0 you can automatically restart untill
    PAP and jug are in the green house
    and the perk order will be QR -> JUG -> PAP -> SPEED -> DT
    on solo and JUG -> PAP -> SPEED -> DT -> QR on coop
    
Die Rise

    Bank full for all players
    All perman perks are given on spawn to all players
    AN94 upgraded on the weapon locker for all players
    Leapers tracker
    Springpads counter
    
Mob of the Dead

    Trap timer
    Box can be set with /box (1 for cafeteria / 2 for office)
    Key always spawns with the box
    Brutus tracker
    Tomahawk will be rewarded to players after reconnecting on round 50+
    
Buried

    Bank full for all players
    All perman perks are given on spawn to all players
    AN94 upgraded on the weapon locker for all players
    Animated pap camo
    Tramplesteam, turbine and resonator counters

Origins

    Box can be set with /box (1 for gen2 / 2 for gen3)
    Wunderfizz set to gen 4
    Animated pap camo
    Panzer tracker
    Templars tracker
    Tank tracker

## Game Monitor
### Available Commands
- `!help` →  Shows all of the commands.
- `!fov <value>` → Changes the field of view (FOV).  
- `!bs` →  Switches between console and steam backspeed. 

- `!zc <round>` → Displays the number of zombies in the given round.  
- `!tzc <start round> <end round>` → Calculates the total number of zombies from one round to another.  
- `!ds <round>` → Displays the drops that have appeared.  
- `!bh` → Displays the ammount of times the box has been hit.

- `!perkrng` → Toggles RNG for perks on or off.  
- `!firstbox` or `!fb` → Toggles RNG for the mystery box on or off.  
- `!traptimer` or `!tt` → Toggles trap timer on or off.  
- `!box <1 / 2>` → Changes the starting location of the mystery box in maps with multiple starting locations.  
- `!character <number>` → Selects a specific character.  

- `!times` → Displays time-related information for the game.  
- `!rt <round>` → Displays round times.  
- `!t` → Displays the total game time.  
- `!timer <value>` → Changes the timer settings.  
- `!sph <round>` → Displays the SPH (Spawn Per Hour) for the round.  

- `!na` → Displays the next possible Avogadro round.  
- `!nb` → Displays the next possible Brutus round.  
- `!nt` → Displays the next possible Templars round.  
- `!np` → Displays the next possible Panzer round.  
- `!nl` → Displays the next possible Leapers round.  
- `!rounders` → Shows the history of special rounds.  
- `!panzers` → Shows the history of Panzers.  
- `!templars` → Shows the history of Templars.  
- `!leapers` → Shows the history of Leapers.  
- `!brutus` → Shows the history of Brutus.  
- `!avogadros` → Shows the history of Avogadros.  

- `!papcamo <value>` → Changes the Pack-a-Punch camo.

## DVars

**It's easier to use the chat**

character [0, 5]

    0 = Random
    1 = Misty, Richtophen, Arlington
    2 = Russman, Dempsei, Finn
    3 = Marlton, Nikolai, Sal
    4 = Stuthlinger, Takeo, Billy
    5 = Ghost (only on mob)

firstbox [0, 1]

    Disables RNG from

sph [0, 255]

     What round sph starts showing, default is 30
    
timer [0, 4]

    0 = Off
    1 = Top right of the screen
    2 = Top left of the screen
    3 = Left side of the screen
    4 = Next to ammo counter

traptimer [0, 1]

    Enables trap timer, default is disabled

perkRNG [0, 1]

    Vulture will be the last perk awarded by the whitches
    Perk order will be QR -> JUG -> PAP -> SPEED -> DT on nuketown
    Perk order will be JUG -> DT -> SPEED -> MULE -> STAM -> QR -> PHD -> CHERRY
    Auto restarts on nuketown untill PAP and JUG are on the green house

forcepap [0, 1]

    On nuketown, restarts the game untill PAP
    and JUG are at the green house backyard

</details>

<details>
  <summary>Descripción en español:</summary>

## Cambios del juego

- Velocidad arreglada

## Cambios en el HUD

    Timer de lobby
    Timer de ronda
    Timer de trampa
    Contador de tiradas de caja
    Contador SPH (apartir de la ronda 50 por defecto)

## Cambios en los mapas

Tranzit

    Banco lleno para todos los jugadores
    Todas las perman perks otrogadas a todos los jugadores hasta la ronda 15
    MP5 / M16 en la nevera
    Bus tracker con /bus 1 (r3755+)
    
Survival Maps

    Raygun & Raygun MK2 average trackers

Town

    Puedes elegir la posición del caja con /box
    1 = Doble Tiro
    2 = Revive

Nuketown

    Con /perkrng 0 puedes reiniciar hasta que 
    el PAP y jug estén en la casa azul
    y el ordend e las perks va a ser QR -> JUG -> PAP -> SPEED -> DT
    en solo, y JUG -> PAP -> SPEED -> DT -> QR en coop
    
Die Rise

    Banco lleno para todos los jugadores
    Todas las perman perks otrogadas a todos los jugadores hasta la ronda 15
    AN94 mejorada en la nevera para todos los jugadores
    Tracker de novas
    Contador de trampolines
    
Mob of the Dead

    Timer de trampa
    Puedes elegir la posición de la caja /box (1 para cafeteria / 2 para la oficina)
    La llave siempre spawnea donde la caja
    Tracker de brutus
    Los jugadores que se reconecten en la ronda 50 o más recibiran
    el tomahawk mejorado
    
Buried

    Banco lleno para todos los jugadores
    Todas las perman perks otrogadas a todos los jugadores hasta la ronda 15
    AN94 mejorada en la nevera para todos los jugadores
    Camuflaje animado de pap
    Contador de turbinas, resonadores y trampolines

Origins

    Puedes fijar la caja con /box (1 para gen2 / 2 para gen3)
    Wunderfizz en el generador 4
    Camuflaje aniamdo
    Tracker de panzers
    Tracker de templarios
    Tracker de tanque

## Monitor del juego
### Comandos Disponibles
- `!help` → Muestra todos los comandos disponibles.
- `!fov <valor>` → Cambia el campo de visión (FOV).
- `!bs` → Cambia entre la velocidad en consola o steam.

- `!zc <ronda>` → Muestra la cantidad de zombis en la ronda dada.
- `!tzc <ronda inicio> <rodna final>` → Calcula el total de zombis de una ronda a otra.
- `!ds <ronda>` → Muestra los drops que han aparecido.
- `!bh` →  Muestra la cantidad de tiradas de caja.

- `!perkrng` → Activa o desactiva el rng relativo perks.
- `!firstbox` o `!fb` → Activa o desactiva el rng de la caja.
- `!traptimer` o `!tt` → Activa o desactiva el temporizador de trampas.
- `!box <1 / 2>` → Cambia la ubicación de la caja en mapas con más de una ubicación inicial.
- `!character <valor>` → Selecciona un personaje específico.

- `!times` → Muestra tiempos relacionados con la partida.
- `!rt <ronda>` → Muestra los tiempos de rondas.
- `!t` → Muestra el tiempo total de la partida.
- `!timer <valor>` → Cambia la configuración del temporizador.
- `!sph <ronda>` → Muestra el SPH de la ronda.

- `!na` → Muestra la siguiente posible ronda de avogadro.
- `!nb` → Muestra la siguiente posible ronda de Brutus.
- `!nt` → Muestra la siguiente posible ronda de los templarios.
- `!np` → Muestra la siguiente posible ronda de panzer.
- `!nl` → Muestra la siguiente posible ronda de leapers.
- `!rounders` → Muestra el historial de rondas especiales.
- `!panzers` → Muestra el historial de panzers.
- `!templars` → Muestra el historial de templarios.
- `!leapers` → Muestra el historial de leapers.
- `!brutus` → Muestra el historial de Brutus.
- `!avogadros` → Muestra el historial de avogadros.

- `!papcamo <valor>` → Cambia el camuflaje del Pack-a-Punch.

## DVars

**Es mejor usar el chat, de todas formas, modificar esto no va a dar error en el juego**

character [0, 5]

    0 = Aleatorio
    1 = Misty, Richtophen, Arlington
    2 = Russman, Dempsei, Finn
    3 = Marlton, Nikolai, Sal
    4 = Stuthlinger, Takeo, Billy
    5 = Ghost (only on mob)

firstbox [0, 1]

    Quita RNG de la caja

sph [0, 255]

    Selecciona en que ronda empieza a mostrar el sph
    
timer [0, 4]

    0 = Off
    1 = Arriba a la derecha
    2 = Arriba a la izquierda
    3 = En el medio a la izquierda
    4 = Al lado del contador de munición

traptimer [0, 1]

    Activa el timer de trampa, por defecto está desactivado

perkRNG [0, 1]

    Vulture será la ultima perk que te dan las brujas
    El orden de ventajas en nuketown será QR -> JUG -> PAP -> SPEED -> DT
    El orden de ventajas de la wunderfizz será JUG -> DT -> SPEED -> MULE -> STAM -> QR -> PHD -> CHERRY
    Auto reinicia partida en nuketown hasta que el pap y el jug está en la casa azul

forcepap [0, 1]

    En nuketown, reinicia el mapa hasta que el PAP
    y Titán están en el jardín de la casa azul

</details>

# [Descarga/Download](https://github.com/Fraaagaaa/Fraga-Bo2/releases/latest/download/Fraga.gsc)
