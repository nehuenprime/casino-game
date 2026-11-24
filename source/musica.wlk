import wollok.game.*

object sinMusica {
    method stop() {}
    method volume(valor) {}
}

object musica {
    var pista = sinMusica
    var archivoActual = ""
    var volumen = 1
    var sonando = false

    method iniciar() {
        keyboard.up().onPressDo({ self.cambiarVolumen(1) })
        keyboard.down().onPressDo({ self.cambiarVolumen(0) })
    }

    method cambiarVolumen(nuevo) {
        volumen = nuevo
        pista.volume(volumen)
    }

    method cambiarA(archivo) {
        [archivo].filter({ a => not (a == archivoActual) }).forEach({ a => self.reproducir(a) })
    }

    method detener() {
        [pista].filter({ p => sonando }).forEach({ p => p.stop() })
        sonando = false
    }

    method reproducir(archivo) {
        self.detener()
        archivoActual = archivo
        const nueva = game.sound(archivo) // carga el sonido 
        nueva.shouldLoop(true) // ni bien termina vuelve a empezar
        nueva.volume(volumen)
        pista = nueva
        game.schedule(500, { self.empezar(nueva) })
    }

    method empezar(sonido) {
        [sonido].filter({ s => s == pista }).forEach({ s => self.sonar(s) })
    }

    method sonar(sonido) {
        sonido.play()
        sonando = true
    }
}

