import wollok.game.*
import billetera.*
import personaje.*
import juego.*
import escenarios.*
import vasos.*
import dificultad.*

// tipos de apuestas
class Apuesta {
    method gana(resultado)
    method multiplicador()
    method nombre()
}

class ApuestaNumero inherits Apuesta {
    const numero

    override method gana(resultado) = resultado == numero
    override method multiplicador() = dificultad.actual().multiplicadorNumero()
    override method nombre() = "al número " + numero
}

object apuestaPar inherits Apuesta {
    override method gana(resultado) = resultado % 2 == 0
    override method multiplicador() = dificultad.actual().multiplicadorRango()
    override method nombre() = "a que salga par"
}

object apuestaImpar inherits Apuesta {
    override method gana(resultado) = resultado % 2 == 1
    override method multiplicador() = dificultad.actual().multiplicadorRango()
    override method nombre() = "a que salga impar"
}

object apuestaMayorA3 inherits Apuesta {
    override method gana(resultado) = resultado > 3
    override method multiplicador() = dificultad.actual().multiplicadorRango()
    override method nombre() = "a mayor que 3"
}

object apuestaMenorOIgualA3 inherits Apuesta {
    override method gana(resultado) = resultado <= 3
    override method multiplicador() = dificultad.actual().multiplicadorRango()
    override method nombre() = "a menor o igual a 3"
}

// visuales
object panelDado {
    method position() = game.at(3, 4)

    method image() = "casino/panel-vasos.png"
}

object dadoVisual {
    var property valor = 1

    method position() = game.at(7, 5)

    method image() = "casino/dado-" + valor + ".png"
}

// renglón de arriba: títulos y resultados
object mensajeDado {
    var property text = ""

    method position() = game.at(7, 7)

    method textColor() = "FFD700"
}

// renglon de abajo: opciones para elegir
object opcionesDado {
    var property text = ""

    method position() = game.at(7, 4)

    method textColor() = "FFFFFF"
}

// fases
object faseDadoLibre inherits Fase {
    override method interactuar() {
        [juegoDado].filter({ j => j.estaCerca() }).forEach({ j => j.mostrarApuestas() })
    }
}

object faseDadoMonto inherits Fase {
    override method interactuar() {
        juegoDado.cerrar()
    }

    override method numero(n) {
        juegoDado.elegirMonto(n)
    }
}

object faseDadoTipo inherits Fase {
    override method interactuar() {
        juegoDado.cerrar()
    }

    override method numero(n) {
        juegoDado.elegirTipo(n)
    }
}

object faseDadoNumero inherits Fase {
    override method interactuar() {
        juegoDado.cerrar()
    }

    override method numero(n) {
        juegoDado.elegirNumero(n)
    }
}

object faseDadoTirando inherits Fase {}

// juego de los dados
object juegoDado {
    const montos = [50, 100, 200]
    const tiposFijos = [apuestaPar, apuestaImpar, apuestaMayorA3, apuestaMenorOIgualA3]
    const caras = [1, 2, 3, 4, 5, 6]
    const celdasMesa = [game.at(6, 3), game.at(7, 3), game.at(8, 3), game.at(9, 3), game.at(6, 7), game.at(7, 7), game.at(8, 7), game.at(9, 7)]
    const cantidadTics = 14
    const tiempoTic = 120
    var fase = faseDadoLibre
    var inversion = 0
    var apuesta = apuestaPar

    method interactuar() {
        fase.interactuar()
    }

    method numero(n) {
        fase.numero(n)
    }

    method estaCerca() = personaje.estaLibre() and juego.estaEn(escenarioDados) and celdasMesa.contains(personaje.position())

    method mostrarApuestas() {
        personaje.bloquear()
        game.addVisual(panelDado)
        game.addVisual(dadoVisual)
        game.addVisual(mensajeDado)
        game.addVisual(opcionesDado)
        mensajeDado.text("¿Cuánto apostás? (E cancelar)")
        opcionesDado.text("1 - $50     2 - $100     3 - $200")
        fase = faseDadoMonto
    }

    method elegirMonto(n) {
        [n].filter({ k => k <= montos.size() }).forEach({ k => self.fijarMonto(montos.get(k - 1)) })
    }

    method fijarMonto(monto) {
        const alcanza = billetera.puedeApostar(monto)
        [monto].filter({ m => alcanza }).forEach({ m => self.pedirTipo(m) })
        [monto].filter({ m => not alcanza }).forEach({ m => mensajeDado.text("No te alcanza el saldo para apostar $" + m) })
    }

    method pedirTipo(monto) {
        inversion = monto
        fase = faseDadoTipo
        mensajeDado.text("¿A qué apostás? (E cancela)")
        opcionesDado.text("1 - Número   2 - Par   3 - Impar   4 - Mayor a 3   5 - Menor o igual a 3")
    }

    method elegirTipo(n) {
        [n].filter({ k => k == 1 }).forEach({ k => self.pedirNumero() })
        [n].filter({ k => k > 1 and k <= 5 }).forEach({ k => self.tirar(tiposFijos.get(k - 2)) })
    }

    method pedirNumero() {
        fase = faseDadoNumero
        mensajeDado.text("¿a que numero? (pulsa E para cancelar)")
        opcionesDado.text("1  -  2  -  3  -  4  -  5  -  6")
    }

    method elegirNumero(n) {
        self.tirar(new ApuestaNumero(numero = n))
    }

    method tirar(unaApuesta) {
        apuesta = unaApuesta
        fase = faseDadoTirando
        opcionesDado.text("")
        mensajeDado.text("Apostaste $" + inversion + " " + unaApuesta.nombre() + ". ¡Tirando!")
        const resultado = caras.anyOne()
        (1..cantidadTics).forEach({ i => game.schedule(i * tiempoTic, { dadoVisual.valor(caras.anyOne()) }) })
        game.schedule((cantidadTics + 1) * tiempoTic, { self.mostrarResultado(resultado) })
    }

    method mostrarResultado(resultado) {
        dadoVisual.valor(resultado)
        [resultado].filter({ r => apuesta.gana(r) }).forEach({ r => self.ganar(r) })
        [resultado].filter({ r => not apuesta.gana(r) }).forEach({ r => self.perder(r) })
        game.schedule(2500, { self.cerrar() })
    }

    method ganar(resultado) {
        const ganancia = inversion * apuesta.multiplicador()
        billetera.sumar(ganancia)
        mensajeDado.text("Salió " + resultado + ". ¡Ganaste! +$" + ganancia)
    }

    method perder(resultado) {
        billetera.restar(inversion)
        mensajeDado.text("Salió " + resultado + ". Perdiste -$" + inversion)
    }

    method cerrar() {
        game.removeVisual(opcionesDado)
        game.removeVisual(mensajeDado)
        game.removeVisual(dadoVisual)
        game.removeVisual(panelDado)
        dadoVisual.valor(1)
        fase = faseDadoLibre
        personaje.liberar()
        juego.verificarQuiebra()
    }
}