import wollok.game.*

object obstaculos {
    const posiciones = []

    method limpiar() {
        posiciones.clear()
    }

    method bloquearZona(xDesde, xHasta, yDesde, yHasta) {
        (xDesde..xHasta).forEach({ x =>
            (yDesde..yHasta).forEach({ y => posiciones.add(game.at(x, y)) })
        })
    }

    method estaBloqueada(pos) = posiciones.contains(pos)
}