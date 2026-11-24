import wollok.game.*
import personaje.*
import pantallaDeInicio.*
import vasos.*
import dado.*
import juego.*

object moverPersonaje {
    method mover() {
        keyboard.w().onPressDo { personaje.arriba() }
        keyboard.s().onPressDo { personaje.abajo() }
        keyboard.d().onPressDo { personaje.derecha() }
        keyboard.a().onPressDo { personaje.izquierda() }

        keyboard.e().onPressDo { self.interactuar() }
        keyboard.num1().onPressDo { self.numero(1) }
        keyboard.num2().onPressDo { self.numero(2) }
        keyboard.num3().onPressDo { self.numero(3) }
        keyboard.num4().onPressDo { self.numero(4) }
        keyboard.num5().onPressDo { self.numero(5) }
        keyboard.num6().onPressDo { self.numero(6) }

        keyboard.r().onPressDo { juego.reiniciar() }
    }

    method interactuar() {
        juegoVasos.interactuar()
        juegoDado.interactuar()
    }



    method numero(n) {
        juegoDado.numero(n)
        [n].filter({ k => k <= 3 }).forEach({ k => juegoVasos.numero(k) })
    }
}