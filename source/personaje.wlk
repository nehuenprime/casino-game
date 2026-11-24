import wollok.game.*
import obstaculos.*
import juego.*

object personaje {

    var property position = game.origin()
    var puedeMoverse = true
    var property cantidadMovimientos = 0
    var direccion = "sur"
    var imagenActual = "robert/jugador-robert-sur-chiquito.png"

    method image() = imagenActual

    method recibirDanio() {
        if (direccion == "norte") imagenActual = "robert/jugador-robert-norte-dañado.png"
        else if (direccion == "sur") imagenActual = "robert/jugador-robert-sur-dañado.png"
        else if (direccion == "este") imagenActual = "robert/jugador-robert-este-dañado.png"
        else imagenActual = "robert/jugador-robert-oeste-dañado.png"

        game.schedule(500, { self.restaurarImagen() })
    }

    method restaurarImagen() {
        if (direccion == "norte") imagenActual = "robert/jugador-robert-norte-chiquito.png"
        else if (direccion == "sur") imagenActual = "robert/jugador-robert-sur-chiquito.png"
        else if (direccion == "este") imagenActual = "robert/jugador-robert-este-chiquito.png"
        else imagenActual = "robert/jugador-robert-oeste-chiquito.png"
    }


    method bloquear() { puedeMoverse = false }
    method liberar() { puedeMoverse = true }

    method estaDentroDelTablero(pos) =
        pos.x() >= 0 && pos.x() <= game.width() - 1 &&
        pos.y() >= 0 && pos.y() <= game.height() - 1

    method puedeIrA(pos) = puedeMoverse && self.estaDentroDelTablero(pos) && !obstaculos.estaBloqueada(pos)

    method moverA(nuevaPosicion) {
        [nuevaPosicion].filter({ pos => self.puedeIrA(pos) }).forEach({ pos => 
            self.position(pos)
            cantidadMovimientos += 1 
        })
        juego.salidasEn(position).forEach({ salida => salida.usar() })
    }

    method arriba() {
        direccion = "norte"
        imagenActual = "robert/jugador-robert-norte-chiquito.png"
        self.moverA(position.up(1))
    }

    method abajo() {
        direccion = "sur"
        imagenActual = "robert/jugador-robert-sur-chiquito.png"
        self.moverA(position.down(1))
    }

    method derecha() {
        direccion = "este"
        imagenActual = "robert/jugador-robert-este-chiquito.png"
        self.moverA(position.right(1))
    }

    method izquierda() {
        direccion = "oeste"
        imagenActual = "robert/jugador-robert-oeste-chiquito.png"
        self.moverA(position.left(1))
    }

    method estaLibre() = puedeMoverse
}