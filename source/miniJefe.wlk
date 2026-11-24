import wollok.game.*
import juego.*       
import escenarios.* 

object miniJefe {
    var property position = game.at(6, 7)
    var direccion = 1
    var seEstaMoviendo = false

    method image() = "mini-jefe-crupier/crupier-mini-jefe-chiquito.png"

    method iniciarMovimiento() {
        if (not seEstaMoviendo) {
            seEstaMoviendo = true
            game.onTick(300, "caminar_jefe", { self.mover() })
        }
    }

    method detenerMovimiento() {
        if (seEstaMoviendo) {
            seEstaMoviendo = false
            game.removeTickEvent("caminar_jefe")
        }
    }

    method mover() {
        if (juego.estaEn(escenarioPelea)) {
            const proximoX = position.x() + direccion
            if (proximoX > 11 || proximoX < 4) {
                direccion = direccion * -1
            }
            position = game.at(position.x() + direccion, position.y())
        }
    }

}