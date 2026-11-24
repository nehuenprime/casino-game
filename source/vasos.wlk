import wollok.game.*
import billetera.*
import personaje.*
import juego.*
import escenarios.*
import dificultad.*

class Vaso {
    var property position
    var property tienePremio = false

    method image() = "casino/vaso.png"

    method levantar() {
        position = position.up(1)
    }

    method bajar() {
        position = position.down(1)
    }

    method moverHacia(destino) {
        const distancia = destino.x() - position.x()
        const direccion = distancia / distancia.abs()
        const ms = dificultad.actual().msPorCeldaVaso()
        (1..distancia.abs()).forEach({ paso => game.schedule(paso * ms, { position = position.right(direccion) }) })
    }
}

object panelVasos {
    method position() = game.at(3, 4)

    method image() = "casino/panel-vasos.png"
}

object premioVaso {
    var property position = game.at(4, 5)

    method image() = "casino/premio-vaso.png"
}

object mensajeVasos {
    var property text = ""

    method position() = game.at(7, 4)

    method textColor() = "FFD700"
}

class Fase {
    method interactuar() {}
    method numero(n) {}
}

object faseLibre inherits Fase {
    override method interactuar() {
        [juegoVasos].filter({ j => j.estaCerca() }).forEach({ j => j.mostrarApuestas() })
    }
}

object faseApuesta inherits Fase {
    override method interactuar() {
        juegoVasos.cerrar()
    }

    override method numero(n) {
        juegoVasos.apostar(n)
    }
}

object faseMezclando inherits Fase {}

object faseElegir inherits Fase {
    override method numero(n) {
        juegoVasos.elegir(n)
    }
}

object faseResultado inherits Fase {}

object juegoVasos {
    const slots = [game.at(4, 5), game.at(7, 5), game.at(10, 5)]
    const vasos = [new Vaso(position = game.at(4, 5)), new Vaso(position = game.at(7, 5)), new Vaso(position = game.at(10, 5))]
    const montos = [50, 100, 200]
    const celdasMesa = [game.at(6, 5), game.at(7, 5), game.at(8, 5), game.at(9, 5)]
    var fase = faseLibre
    var inversion = 0

    method interactuar() {
        fase.interactuar()
    }

    method numero(n) {
        fase.numero(n)
    }

    method estaCerca() = personaje.estaLibre() and juego.estaEn(escenarioVasos) and celdasMesa.contains(personaje.position())

    method mostrarApuestas() {
        personaje.bloquear()
        game.addVisual(panelVasos)
        vasos.forEach({ v => game.addVisual(v) })
        game.addVisual(mensajeVasos)
        mensajeVasos.text("Apostá: 1 = $50   2 = $100   3 = $200   (E cancelar)")
        fase = faseApuesta
    }

    method apostar(n) {
        const monto = montos.get(n - 1)
        const alcanza = billetera.puedeApostar(monto)
        [monto].filter({ m => alcanza }).forEach({ m => self.empezar(m) })
        [monto].filter({ m => not alcanza }).forEach({ m => mensajeVasos.text("No te alcanza el saldo para apostar $" + m) })
    }

    method empezar(monto) {
        inversion = monto
        vasos.forEach({ v => v.tienePremio(false) })
        vasos.anyOne().tienePremio(true)
        fase = faseMezclando
        mensajeVasos.text("Mirá bien dónde está el premio...")
        self.mostrarPremio()
        game.schedule(dificultad.actual().tiempoMuestraPremio(), { self.terminarMuestra() })
    }

    method vasoConPremio() = vasos.find({ v => v.tienePremio() })

    method mostrarPremio() {
        premioVaso.position(self.vasoConPremio().position())
        game.addVisual(premioVaso)
        self.vasoConPremio().levantar()
    }

    method terminarMuestra() {
        self.vasoConPremio().bajar()
        game.removeVisual(premioVaso)
        self.mezclar()
    }

    method mezclar() {
        const modo = dificultad.actual()
        mensajeVasos.text("Mezclando...")
        (1..modo.intercambiosVasos()).forEach({ i => game.schedule(i * modo.tiempoPasoVasos(), { self.intercambiarAlAzar() }) })
        game.schedule((modo.intercambiosVasos() + 1) * modo.tiempoPasoVasos(), { self.pedirEleccion() })
    }

    method vasoEn(posicion) = vasos.find({ v => v.position() == posicion })

    method intercambiarAlAzar() {
        const i = [0, 1].anyOne()
        const vasoA = self.vasoEn(slots.get(i))
        const vasoB = self.vasoEn(slots.get(i + 1))
        const destinoA = vasoB.position()
        const destinoB = vasoA.position()
        vasoA.levantar()
        vasoA.moverHacia(destinoA)
        vasoB.moverHacia(destinoB)
        game.schedule(dificultad.actual().tiempoBajarVaso(), { vasoA.bajar() })
    }

    method pedirEleccion() {
        fase = faseElegir
        mensajeVasos.text("¿Dónde está? Elegí 1, 2 o 3 (de izquierda a derecha)")
    }

    method elegir(n) {
        fase = faseResultado
        const elegido = vasos.find({ v => v.position() == slots.get(n - 1) })
        premioVaso.position(self.vasoConPremio().position())
        game.addVisual(premioVaso)
        vasos.forEach({ v => v.levantar() })
        [elegido].filter({ v => v.tienePremio() }).forEach({ v => self.ganar() })
        [elegido].filter({ v => not v.tienePremio() }).forEach({ v => self.perder() })
        game.schedule(2500, { self.cerrar() })
    }

    method ganar() {
        billetera.sumar(inversion)
        mensajeVasos.text("¡Ganaste! +$" + inversion)
    }

    method perder() {
        billetera.restar(inversion)
        mensajeVasos.text("Perdiste -$" + inversion)
    }

    method cerrar() {
        vasos.forEach({ v => game.removeVisual(v) })
        game.removeVisual(panelVasos)
        game.removeVisual(mensajeVasos)
        [premioVaso].filter({ p => game.hasVisual(p) }).forEach({ p => game.removeVisual(p) })
        self.reiniciarVasos()
        fase = faseLibre
        personaje.liberar()
        juego.verificarQuiebra()
    }

    method reiniciarVasos() {
        (0..2).forEach({ i => vasos.get(i).position(slots.get(i)) })
    }
}