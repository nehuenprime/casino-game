import wollok.game.*
import dificultad.*
import personaje.*

object billetera {
    const recompensaMoneda = 10
    const apuestaMinima = 50
    var saldo = 100

    method tieneAlMenos(monto) = saldo >= monto

    method saldo() = saldo

    method sumar(monto) {
        saldo = saldo + monto
    }

    method restar(monto) {
        saldo = (saldo - monto).max(0)
    }

    method cobrarDanioCarta(monto) {
        self.restar(monto)
    }

    method recogerMoneda() {
        self.sumar(recompensaMoneda)
    }

    method puedeApostar(monto) = saldo >= monto

    method necesitaMoneda() = saldo < apuestaMinima

    method completarApuestaMinima() {
        saldo = saldo.max(apuestaMinima)
    }

    method meta(){}

    method alcanzoLaMeta() = saldo >= dificultad.actual().meta()

    method estaEnQuiebra() = saldo == 0

    method reiniciar() {
        saldo = dificultad.actual().saldoInicial()
    }
}

object marcadorFondo {
    method position() = game.at(0, 11)

    method image() = "casino/marcador-fondo.png"
}

object marcador {
    method position() = game.at(1, 11)

    method text() = billetera.saldo().toString()

    method textColor() = "FFD700"
}

// moneda que aparece en la plaza cuando Robert tiene menos de la apuesta mínima
object monedaFuente {
    const lugares = [game.at(5, 2), game.at(5, 3), game.at(5, 4), game.at(9, 2), game.at(9, 3), game.at(9, 4), game.at(6, 5), game.at(7, 5), game.at(8, 5), game.at(6, 1), game.at(7, 1), game.at(8, 1)]
    var property position = game.at(5, 3)

    method image() = "casino/moneda-fuente.png"

    method aparecer() {
        position = lugares.anyOne()
        game.addVisual(self)
    }

    method retirar() {
        game.removeVisual(self)
    }
}

object encuentroMonedaFuente {
    method activaEn(pos) = game.hasVisual(monedaFuente) and pos == monedaFuente.position()

    method usar() {
        billetera.completarApuestaMinima()
        monedaFuente.retirar()
    }
}