import wollok.game.*
import billetera.*

// los dialogos estan sujeto a cambios
object dialogoPocasFichas {
    method aplica(saldo) = saldo < 200

    method texto() = "estas en el horno robert"
}

object dialogoIntermedio {
    method aplica(saldo) = saldo >= 200 and saldo <= 500

    method texto() = "va queriendo"
}

object dialogoBuenasFichas {
    method aplica(saldo) = saldo > 500 and saldo < 1000

    method texto() = "vamos seguí así pero con cuidado"
}

object dialogoMuchasFichas {
    method aplica(saldo) = saldo >= 1000

    method texto() = "robert has mejorado, pero tené precaución"
}

object npcVasos {
    const dialogos = [dialogoPocasFichas, dialogoIntermedio, dialogoBuenasFichas, dialogoMuchasFichas]
    var hablando = false

    method position() = game.at(13, 8)

    method image() = "casino/npc1.png"

    method dialogoActual() = dialogos.find({ d => d.aplica(billetera.saldo()) })

    method hablar() {
        [self].filter({ n => not hablando }).forEach({ n => n.decir() })
    }

    method decir() {
        hablando = true
        game.say(self, self.dialogoActual().texto())
        game.schedule(3000, { hablando = false })
    }
}

object encuentroNpcVasos {
    method activaEn(pos) =
        (pos.x() - npcVasos.position().x()).between(-1, 2) and
        (pos.y() - npcVasos.position().y()).between(-2, 1)

    method usar() {
        npcVasos.hablar()
    }
}