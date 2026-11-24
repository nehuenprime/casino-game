import wollok.game.*
import juego.*

class Pantalla {
    method image()
    method position()
    method mostrarExtras() {}
    method ocultarExtras() {}
    method siguiente() = self
    method alPresionarC() {}
    method alPresionarEnter() {}
    method alPresionarEspacio() {}
    method alPresionarV() {
        if (game.hasVisual(self)) {
            pantallaCreditos.volverA(self)
            menuInicio.cambiarA(pantallaCreditos)
        }
    }

    method representaFinal() = false
    method estaVisible() = game.hasVisual(self)

    method irA(pantalla) {
        if (self.estaVisible()) {
            menuInicio.cambiarA(pantalla)
        }
    }
}

object casino inherits Pantalla {
    override method image() = "casino/casino-poster-inicio.png"
    override method position() = game.origin()
    override method siguiente() = pantallaControles

    override method alPresionarC() {
        self.irA(self.siguiente())
    }

    override method alPresionarEnter() {
        self.irA(cinematica1)
    }
}

object cinematica1 inherits Pantalla {
    override method image() = "casino/cinematica1.png"
    override method position() = game.origin()

    override method alPresionarEspacio() {
        self.irA(cinematica2)
    }

    override method alPresionarEnter() {
        [self].filter({ p => p.estaVisible() }).forEach({ p => juego.comenzar() })
    }
}

object cinematica2 inherits Pantalla {
    override method image() = "casino/cinematica2.png"
    override method position() = game.origin()

    override method alPresionarEspacio() {
        [self].filter({ p => p.estaVisible() }).forEach({ p => juego.comenzar() })
    }

    override method alPresionarEnter() {
        [self].filter({ p => p.estaVisible() }).forEach({ p => juego.comenzar() })
    }
}

object pantallaGameOver inherits Pantalla {
    override method image() = "casino/game-over.png"
    override method position() = game.origin()
    override method representaFinal() = true
}

object pantallaVictoria inherits Pantalla {
    override method position() = game.origin()
    override method image() = "casino/game-win.png"
    override method representaFinal() = true

    override method alPresionarEnter() {
        pantallaCreditos.volverA(self)
        self.irA(pantallaCreditos)
    }
}

object pantallaControles inherits Pantalla {
    override method image() = "casino/Controles.png"
    override method position() = game.origin()
    override method siguiente() = casino
    override method alPresionarC() {
        self.irA(self.siguiente())
    }
}

object pantallaCreditos inherits Pantalla {
    var pantallaAnterior = casino

    override method image() = "casino/CreditosCodeTeam.png"

    override method position() = game.origin()

    override method alPresionarC() {
        self.irA(pantallaAnterior)
    }

    override method alPresionarV() {
        self.irA(pantallaAnterior)
    }

    override method alPresionarEnter() {
        [self].filter({ p => p.estaVisible() and p.representaFinal() }).forEach({ p => juego.volverAEmpezar() })
    }

    override method representaFinal() = pantallaAnterior.representaFinal()

    method volverA(pantalla) {
        pantallaAnterior = pantalla
    }
}


object menuInicio {
    var pantallaActual = casino

    method configurar() {
        game.addVisual(pantallaActual)
        keyboard.c().onPressDo { self.alternarPantalla() }
        keyboard.v().onPressDo { pantallaActual.alPresionarV() }
        keyboard.space().onPressDo { pantallaActual.alPresionarEspacio() }
    }

    method alPresionarEnter() {
        pantallaActual.alPresionarEnter()
    }

    method cambiarA(pantalla) {
        pantallaActual.ocultarExtras()
        if (game.hasVisual(pantallaActual)) {
            game.removeVisual(pantallaActual)
        }
        pantallaActual = pantalla
        game.addVisual(pantallaActual)
        pantallaActual.mostrarExtras()
    }

    method quitarPantallaActual() {
        pantallaActual.ocultarExtras()
        if (game.hasVisual(pantallaActual)) {
            game.removeVisual(pantallaActual)
        }
        pantallaActual = casino
    }

    method alternarPantalla() {
        [pantallaActual].filter({ p => game.hasVisual(p) }).forEach({ p =>
            self.quitarPantallaActual()
            pantallaActual = p.siguiente()
            game.addVisual(pantallaActual)
            pantallaActual.mostrarExtras()
        })
    }

    method pantallaFinalActiva() = pantallaActual.representaFinal()
}