# Fraga-Bo2

## Descargas
### New pluto (Versión recomendada)
- [Plutonium r2905+](https://github.com/Fraagaa/Fraga-Bo2/releases/download/FragaV13/FragaV13.Plutonium.r2905+.zip)
  - Los timer de ronda solo funcionan en new pluto.
### Versiones alternativas
- [Ancient (Con tracker de rondas escpeciales)](https://github.com/Fraagaa/Fraga-Bo2/releases/download/FragaV13/FragaV13.Ancient.rar)
- [Ancient (Sin trackers)](https://github.com/Fraagaa/Fraga-Bo2/releases/download/FragaV13/FragaV13.Ancient.+.trackers.rar)
- Estas versiones tienen limitaciones como: 
  - No tiene graficos mejorados ni modo noche
  - El wunderfizz no está fijo en el generador 4
  - No se puede manipular el rng de las ventajas (menos el pap y jug en nuketown)
  - Los templarios no se pueden manipular
- Redacted pronto, tengo problemas con el compilador
## Cambios del juego

- Velocidad arreglada
- Vida de los zombies arreglada
- Skybox animada
- Modo noche
- Sombras de jugadores

## Cambios en el HUD

    Timer de lobby
    Timer de ronda
    Timer de trampa
    Contador de tiradas de caja
    Contador SPH (apartir de la ronda 30 por defecto)
    Puedes cambiar el color del HUD
    Splits de rondas
    Se muestran las kills de cada jugadar en fr a partir de la ronda 6
    Se muestra la velocidad del jugador en fr a partir de la ronda 5

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
    1 = doubletap
    2 = quick revive

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

    Tiemr de trampa
    Puedes elegir la posición de la caja /box (1 para cafeteria / 2 para la oficina)
    La llave siempre spawnea donde la caja
    Tracker de brutus
    
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

## Splits **(r3705+)**

Ronda 5: Rondas 1,2,3,4,5

Ronda 30: Rondas 5, 10, 15, 20, 25, 30

Ronda 50: Rondas 10, 20, 30, 40, 50

Ronda 70: Rondas 10, 20, 30, 40, 50, 60, 70

Ronda 100: Rondas 30, 50, 70, 80, 90, 100

Ronda 150: Rondas 50, 70, 100, 125, 130, 140, 150

Ronda 200: Rondas 50, 70, 100, 150, 175, 200

SR **RoundNumeber** (necesita un fast_restart):
Example: SR 30

## DVars

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
    1 = En el medio a la izquierda
    2 = Arriba a la izquierda
    3 = Arriba a la derecha
    4 = Al lado del contador de munición

traptimer [0, 1]

    Activa el timer de trampa, por defecto está desactivado
    
color ("x x x")

    Cambia el color del timer (Solo en plutonium nuevo)

SR

    5 30 50 70 100 150 200

FragaDebug

    Da a cada jugador 69420 puntos y permite los chetos

score

    Cambia la cantidad de puntos que da el modo debug

perkRNG [0, 1]

    Vulture será la ultima perk que te dan las brujas
    El orden de ventajas en nuketown será QR -> JUG -> PAP -> SPEED -> DT
    El orden de ventajas de la wunderfizz será JUG -> DT -> SPEED -> MULE -> STAM -> QR -> PHD -> CHERRY
    Auto reinicia partida en nuketown hasta que el pap y el jug está en la casa azul

Templars [0, 1]

    Los templarios solo atacan el generador 4
    Puede causar errores si el generador 4 no está activado