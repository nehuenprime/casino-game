import wollok.game.*
import billetera.*
import juego.*
import personaje.*

class ObjetoLluvia {
    var property position = game.origin()
    var columna = 0
    var fila = 0
    var activo = false

    method image()
    method estaActivo() = activo

    method aparecerEn(unaColumna, unaFila) {
        columna = unaColumna
        fila = unaFila
        activo = true
        self.actualizarPosicion()
        game.addVisual(self)
        self.iniciar()
    }

    method iniciar() {}

    method avanzar()

    method interactuar()

    method coincideConPersonaje() = personaje.position() == position

    method actualizarPosicion() {
        self.position(game.at(columna, fila))
    }

    method chocarConPersonaje() {
        self.interactuar()
    }

    method esquivada() {
        self.retirar()
    }

    method retirar() {
        if (activo) {
            activo = false
            if (game.hasVisual(self)) { 
                game.removeVisual(self)
            }
        }
    }
}

class Carta inherits ObjetoLluvia {
    var movimientosAcumulados = 0
    var columnaPersonajeAlAparecer = 0
    var movimientosPersonajeAlAparecer = 0

    method danio() = 0
    method movimientosPorCasilla() = 2

    override method iniciar() {
        columnaPersonajeAlAparecer = personaje.position().x()
        movimientosPersonajeAlAparecer = personaje.cantidadMovimientos()
    }

    override method avanzar() {
        if (activo) {
            if (self.coincideConPersonaje()) {
                self.interactuar()
            } else {
                movimientosAcumulados += 1
                if (movimientosAcumulados >= self.movimientosPorCasilla()) {
                    self.bajarUnaCasilla()
                }
            }
        }
    }

    method bajarUnaCasilla() {
        movimientosAcumulados = 0
        if (fila > 0) {
            fila -= 1
            self.actualizarPosicion()
            if (self.coincideConPersonaje()) {
                self.interactuar()
            } else if (fila == 0) {
                self.esquivada()
            }
        } else {
            self.esquivada()
        }
    }

    override method esquivada() {
        if (activo) {
            self.retirar()
        }
    }

    override method interactuar() {
        if (activo) {
            billetera.cobrarDanioCarta(self.danio())
            
            personaje.recibirDanio() 
            
            juego.verificarQuiebra()
            self.retirar()
        }
    }
}

class CartaNormal inherits Carta {
    override method image() = "mini-jefe-crupier/carta-crupier-mini.png"
    override method danio() = 50
}

class CartaEspecial inherits Carta {
    override method image() = "mini-jefe-crupier/carta-super-crupier-mini.png"
    override method danio() = 100
    override method movimientosPorCasilla() = 1
}


class CartaRapida inherits CartaNormal {
    override method image() = "mini-jefe-crupier/carta-crupier-rapida.png"
    override method danio() = 75
    override method movimientosPorCasilla() = 1
}

class Moneda inherits ObjetoLluvia {
    override method image() = "casino/premio-vaso.png"

    override method iniciar() {
        game.schedule(8000, { self.retirar() })
    }

    override method avanzar() {
        if (activo && self.coincideConPersonaje()) {
            self.interactuar()
        }
    }

    override method interactuar() {
        if (activo) {
            billetera.recogerMoneda()
            self.retirar()
        }
    }
}
