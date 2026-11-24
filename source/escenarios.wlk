import wollok.game.*
import obstaculos.*
import juego.*
import miniJefe.*
import personaje.*
import lluviadecartas.*
import billetera.*
import musica.*
import dificultad.*
import npc.*



object fondo {
    var property image = "casino/casino-tablero.png"

    method position() = game.origin()
}

// ---------- clase madre de todos los mapas ----------
class Escenario {
    method imagen()
    method cancion()
    method salidas()
    method cargarObstaculos()

    method alCargar() {}

    method puedeCargar() = true

    method cargar() {
        [self].filter({ e => e.puedeCargar() }).forEach({ e => e.prepararMapa() })
    }

    method prepararMapa() {
        musica.cambiarA(self.cancion())
        fondo.image(self.imagen())
        obstaculos.limpiar()
        self.cargarObstaculos()
        self.alCargar()
    }
}

// ---------- casino ----------
object escenarioCasino inherits Escenario {
    override method imagen() = "casino/casino-tablero.png"
    override method cancion() = "sonidos/Casino-game-ambiente1.mp3"
    override method salidas() = [salidaCasinoAVasos, encuentroMiniJefe, salidaCasinoADados, salidaCasinoAPlaza]

    override method cargarObstaculos() {
        self.cargarCrupier()
        self.cargarParedes()
        self.cargarMesas()
        self.cargarMaquinitas()
    }

    override method alCargar() {
        [miniJefe].filter({ m => not game.hasVisual(m) }).forEach({ m => game.addVisual(m) })
    }

    method cargarParedes() {
        obstaculos.bloquearZona(0, 15, 10, 11)    // pared y cortinas de arriba
        obstaculos.bloquearZona(0, 5, 0, 1)       // abajo a la izquierda (máquinas y cordón)
        obstaculos.bloquearZona(10, 15, 0, 1)     // abajo a la derecha (cordón y máquinas)
    }

    method cargarMesas() {
        obstaculos.bloquearZona(0, 3, 8, 9)       // mesa de arriba, izquierda
        obstaculos.bloquearZona(5, 7, 8, 9)       // semicírculo izquierdo
        obstaculos.bloquearZona(8, 10, 8, 9)      // semicírculo derecho
        obstaculos.bloquearZona(12, 15, 8, 9)     // ruleta de arriba
        obstaculos.bloquearZona(0, 3, 5, 6)       // mesa del medio, izquierda
        obstaculos.bloquearZona(12, 15, 5, 6)     // ruleta del medio
    }

    method cargarMaquinitas() {
        obstaculos.bloquearZona(0, 4, 3, 4)       // maquinitas de arriba, izquierda
        obstaculos.bloquearZona(11, 15, 3, 4)     // maquinitas de arriba, derecha
    }

    method cargarCrupier() {
        const base = miniJefe.position()
        obstaculos.bloquearZona(base.x(), base.x() + 1, base.y(), base.y() + 2)    // ocupa 2 casillas de ancho y 3 de alto, como su sprite
    }
}


object salidaCasinoAVasos {
    const celdas = [game.at(15, 2)]

    method activaEn(pos) = celdas.contains(pos)

    method usar() {
        juego.irA(escenarioVasos, game.at(1, 5))
    }
}

object salidaVasosACasino {
    const celdas = [game.at(0, 4), game.at(0, 5), game.at(0, 6)]

    method activaEn(pos) = celdas.contains(pos)

    method usar() {
        juego.irA(escenarioCasino, game.at(14, 2))
    }
}

// ---------- mesa de los vasos ----------
object escenarioVasos inherits Escenario {
    override method imagen() = "casino/escenario-vasos.png"
    override method cancion() = "sonidos/vasos.mp3"
    override method salidas() = [salidaVasosACasino, encuentroNpcVasos]

    override method cargarObstaculos() {
        self.cargarParedes()
        self.cargarEscenario()
        self.cargarMesas()
        self.cargarBarra()
        self.cargarNpc()
    }

    override method alCargar() {
        [npcVasos].filter({ n => not game.hasVisual(n) }).forEach({ n => game.addVisual(n) })
    }

    method cargarParedes() {
        obstaculos.bloquearZona(0, 15, 10, 11)  // pared de arriba
        obstaculos.bloquearZona(0, 0, 9, 9)      // plantas de arriba
        obstaculos.bloquearZona(3, 3, 9, 9)
        obstaculos.bloquearZona(12, 12, 9, 9)
        obstaculos.bloquearZona(15, 15, 9, 9)
        obstaculos.bloquearZona(0, 0, 7, 7)       // planta de la izquierda
        obstaculos.bloquearZona(15, 15, 6, 7)    // planta de la derecha
        obstaculos.bloquearZona(1, 2, 6, 6)       // cordón de arriba de la puerta
        obstaculos.bloquearZona(1, 3, 3, 3)       // cordón de abajo de la puerta
    }

    method cargarEscenario() {
        obstaculos.bloquearZona(5, 10, 6, 9)      // escenario con la mesa de vasos y las banquetas del frente
        obstaculos.bloquearZona(11, 11, 7, 9)     // borde derecho del escenario y banquetas de ese lado
        obstaculos.bloquearZona(4, 4, 8, 9)       // banquetas de la izquierda del escenario
    }

    method cargarMesas() {
        obstaculos.bloquearZona(12, 15, 4, 5)   // mesa redonda de la derecha
        obstaculos.bloquearZona(5, 7, 2, 3)      // mesa redonda del medio
        obstaculos.bloquearZona(0, 2, 0, 1)   // mesa de abajo, izquierda
        obstaculos.bloquearZona(4, 6, 0, 1)   // mesa de abajo, medio
    }

    method cargarBarra() {
        obstaculos.bloquearZona(11, 15, 0, 3)   // barra y estantes
        obstaculos.bloquearZona(10, 10, 1, 2)  // banquetas de la barra
    }

    method cargarNpc() {
        obstaculos.bloquearZona(13, 14, 7, 9)     // hitbox del NPC: su cuerpo y la fila de abajo, para que Robert no se le superponga
    }
}

// ---------- sala del jefe ----------
// al tocar al crupier se pasa a este mapa y no se puede salir: la única forma es derrotarlo
// esquivando todas sus cartas, y se sale con más o menos plata que al inicio.
object escenarioPelea inherits Escenario {
    override method imagen() = "casino/salon-casino-batalla.png"
    override method cancion() = "sonidos/jefe-final.mp3"
    override method salidas() = []

    override method puedeCargar() = not lluviaDeCartas.estaJugando()

    override method cargarObstaculos() {
        obstaculos.bloquearZona(4, 11, 8, 11)
        self.cargarParedes()
        self.cargarMesas()
        self.cargarPlantas()
    }

    override method alCargar() {
        miniJefe.position(game.at(6, 8))
        [miniJefe].filter({ m => not game.hasVisual(m) }).forEach({ m => game.addVisual(m) })
        lluviaDeCartas.iniciar()
    }

    method cargarParedes() {
        obstaculos.bloquearZona(0, 15, 10, 11)    // pared de arriba y escenario del fondo
        obstaculos.bloquearZona(0, 0, 0, 9)       // pared izquierda
        obstaculos.bloquearZona(15, 15, 0, 9)     // pared derecha
        obstaculos.bloquearZona(1, 6, 0, 1)       // pared de abajo, a la izquierda de la alfombra
        obstaculos.bloquearZona(9, 14, 0, 1)      // pared de abajo, a la derecha de la alfombra
    }

    method cargarMesas() {
        obstaculos.bloquearZona(1, 3, 7, 8)       // mesa de arriba, izquierda (con banquetas)
        obstaculos.bloquearZona(12, 14, 7, 8)     // mesa de arriba, derecha (con banquetas)
        obstaculos.bloquearZona(1, 4, 4, 5)       // ruleta de la izquierda
        obstaculos.bloquearZona(2, 4, 3, 3)       // banquetas de la ruleta izquierda
        obstaculos.bloquearZona(11, 14, 4, 5)     // ruleta de la derecha
        obstaculos.bloquearZona(11, 13, 3, 3)     // banquetas de la ruleta derecha
    }

    method cargarPlantas() {
        obstaculos.bloquearZona(4, 4, 9, 9)       // planta de arriba, izquierda
        obstaculos.bloquearZona(11, 11, 9, 9)     // planta de arriba, derecha
        obstaculos.bloquearZona(1, 1, 2, 2)       // planta de abajo, izquierda
        obstaculos.bloquearZona(14, 14, 2, 2)     // planta de abajo, derecha
    }
}

// ---------- mesa de dados ----------
object escenarioDados inherits Escenario {
    override method imagen() = "casino/tablero-dados.png"
    override method cancion() = "sonidos/dados.mp3"
    override method salidas() = [salidaDadosACasino]

    override method cargarObstaculos() {
        self.cargarParedes()
        self.cargarMesa()
        self.cargarPlantas()
    }

    method cargarParedes() {
        obstaculos.bloquearZona(0, 15, 9, 11)     // pared de arriba con plantas y escenario
        obstaculos.bloquearZona(0, 15, 0, 1)      // barandas y cordones de abajo
    }

    method cargarMesa() {
        obstaculos.bloquearZona(5, 10, 4, 6)      // mesa de dados y banquetas
    }

    method cargarPlantas() {
        obstaculos.bloquearZona(0, 0, 6, 7)       // plantas de la izquierda
        obstaculos.bloquearZona(0, 1, 2, 2)       // plantas de abajo, izquierda
        obstaculos.bloquearZona(14, 15, 2, 2)     // plantas de abajo, derecha
    }
}

object salidaCasinoADados {
    const celdas = [game.at(0, 2)]

    method activaEn(pos) = celdas.contains(pos)

    method usar() {
        juego.irA(escenarioDados, game.at(14, 5))
    }
}

object salidaDadosACasino {
    const celdas = [game.at(15, 5), game.at(15, 6)]

    method activaEn(pos) = celdas.contains(pos)

    method usar() {
        juego.irA(escenarioCasino, game.at(1, 2))
    }
}

object encuentroMiniJefe {
    method activaEn(pos) =
        (pos.x() - miniJefe.position().x()).between(-1, 2) and
        (pos.y() - miniJefe.position().y()).between(-1, 3)

    method usar() {
        const puedePasar = billetera.tieneAlMenos(dificultad.actual().fichasParaElJefe())
        [self].filter({ e => puedePasar }).forEach({ e => juego.irA(escenarioPelea, game.at(7, 1)) })
        [self].filter({ e => not puedePasar }).forEach({ e => e.advertir() })
    }

    method advertir() {
        game.say(miniJefe, "cuchame una cosa robert, necesitas " + dificultad.actual().fichasParaElJefe() + " fichas para pelear conmigo")
    }
}

// ---------- plaza ----------
object escenarioPlaza inherits Escenario {
    override method imagen() = "casino/casino-plaza.png"
    override method cancion() = "sonidos/viento.mp3"
    override method salidas() = [salidaPlazaACasino, encuentroMonedaFuente]

    override method cargarObstaculos() {
        self.cargarParedes()
        self.cargarOtrosObstaculos()
        self.cargarPlantas()
    }

    override method alCargar() {
        self.cargarMoneda()
    }

    method cargarMoneda() {
        [monedaFuente].filter({ m => billetera.necesitaMoneda() and not game.hasVisual(m) }).forEach({ m => m.aparecer() })
    }

    method cargarParedes() {
        obstaculos.bloquearZona(0, 6, 10, 10) // pared superior, parte izquierda
        obstaculos.bloquearZona(9, 15, 10, 10) // pared superior, parte derecha
        obstaculos.bloquearZona(9, 9, 9, 9) // columna derecha de la entrada
        obstaculos.bloquearZona(0, 0, 1, 8) // paredes laterales izq.
        obstaculos.bloquearZona(15, 15, 1, 8) // paredes laterales der.
        obstaculos.bloquearZona(0, 2, 0, 0)   // Valla inferior izquierda
        obstaculos.bloquearZona(12, 15, 0, 0) // Valla inferior derecha 
    }

    method cargarPlantas() {
        obstaculos.bloquearZona(1, 2, 9, 10) // arbol izq. arriba
        obstaculos.bloquearZona(13, 14, 9, 10) // arbol der. arriba
        obstaculos.bloquearZona(0, 1, 5, 6) // arbol izq. abajo
        obstaculos.bloquearZona(14, 15, 5, 6) // arbol der. abajo
        obstaculos.bloquearZona(0, 2, 7, 7) // jardinera izq.
        obstaculos.bloquearZona(13, 15, 7, 7) // jardinera der.
        obstaculos.bloquearZona(0, 1, 2, 2) // arbustos abajo izq.
        obstaculos.bloquearZona(14, 15, 2, 2) // arbustos abajo der.
        obstaculos.bloquearZona(5, 5, 8, 9) // maceta izq.
        obstaculos.bloquearZona(10, 10, 8, 9) // maceta der.
    }

    method cargarOtrosObstaculos() {
        obstaculos.bloquearZona(6, 8, 2, 4) // fuente
        obstaculos.bloquearZona(1, 1, 5, 6) // banco izq.
        obstaculos.bloquearZona(14, 14, 5, 6) // banco der.
        obstaculos.bloquearZona(2, 2, 7, 9) // farol izq. arriba
        obstaculos.bloquearZona(1, 1, 2, 3) // farol izq. abajo
        obstaculos.bloquearZona(12, 13, 7, 9) // farol der. arriba
        obstaculos.bloquearZona(13, 14, 2, 3) // farol der. abajo
    }
}

object salidaCasinoAPlaza {
    const celdas = [game.at(7, 0), game.at(8, 0)]

    method activaEn(pos) = celdas.contains(pos)

    method usar() {
        juego.irA(escenarioPlaza, game.at(7, 9))
    }
}

object salidaPlazaACasino {
    const celdas = [game.at(7, 10), game.at(8, 10)]

    method activaEn(pos) = celdas.contains(pos)

    method usar() {
        juego.irA(escenarioCasino, game.at(7, 1))
    }
}