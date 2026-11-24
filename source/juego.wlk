import wollok.game.*
import personaje.*
import pantallaDeInicio.*
import escenarios.*
import teclado.*
import musica.*
import billetera.*
import miniJefe.*
import lluviadecartas.*
import dificultad.*
import npc.*


object juego {
    var escenarioActual = escenarioCasino

    method iniciar() {
        game.width(16)
        game.height(12)
        game.cellSize(50)
        game.title("casino")

        musica.iniciar()

        game.addVisual(fondo)
        game.addVisual(personaje)
        game.addVisual(marcadorFondo)
        game.addVisual(marcador)

        teclado.moverPersonaje.mover()

        self.irA(escenarioCasino, game.at(7, 1))

        menuInicio.configurar()
        personaje.bloquear()

        keyboard.enter().onPressDo { menuInicio.alPresionarEnter() }
        keyboard.h().onPressDo { self.cambiarDificultad() }

        game.start()
    }

    method empezarPartida() {
        [casino].filter({ p => game.hasVisual(p) }).forEach({ p => self.comenzar() })
    }

    method comenzar() {
        menuInicio.quitarPantallaActual()
        billetera.reiniciar()
        personaje.liberar()
    }
    
    method cambiarDificultad() {
        [casino].filter({ p => game.hasVisual(p) }).forEach({ p => self.activarDificil() })
    }

    method activarDificil() {
        dificultad.alternar()
        menuInicio.cambiarA(cinematica1)
    }

    method irA(escenario, posicionInicial) {
        [miniJefe, npcVasos, monedaFuente].filter({ v => game.hasVisual(v) }).forEach({ v => game.removeVisual(v) })
        escenarioActual = escenario
        escenario.cargar()
        personaje.position(posicionInicial)
    }

    // ---------- derrota ----------
    method verificarQuiebra() {
        [billetera].filter({ b => b.estaEnQuiebra() }).forEach({ b => self.mostrarGameOver() })
    }

    method mostrarGameOver() {
        personaje.bloquear()
        [pantallaGameOver].filter({ p => not game.hasVisual(p) }).forEach({ p => self.ponerGameOver() })
    }

    method ponerGameOver() {
        menuInicio.cambiarA(pantallaGameOver)
        game.schedule(50, { lluviaDeCartas.finalizar() })
    }

    method reiniciar() {
        [self].filter({ j => menuInicio.pantallaFinalActiva() }).forEach({ j => self.volverAEmpezar() })
    }

    // ---------- victoria ----------
    method verificarVictoria() {
        [billetera].filter({ b => b.alcanzoLaMeta() }).forEach({ b => self.mostrarVictoria() })
    }

    method mostrarVictoria() {
        personaje.bloquear()
        [pantallaVictoria].filter({ v => not game.hasVisual(v) }).forEach({ v => menuInicio.cambiarA(v) })
    }

    // ---------- reinicio (desde game over o desde los créditos finales) ----------
    method volverAEmpezar() {
        menuInicio.quitarPantallaActual()
        self.reiniciarTodo()
    }

    method reiniciarTodo() {
        billetera.reiniciar()
        lluviaDeCartas.finalizar()
        miniJefe.detenerMovimiento()
        miniJefe.position(game.at(6, 7)) 
        self.irA(escenarioCasino, game.at(7, 1))
        personaje.liberar()
    }

    method detenerMiniJefe() {
        miniJefe.detenerMovimiento()
        miniJefe.position(game.at(6, 7))
        self.irA(escenarioCasino, game.at(7, 1))
        self.verificarVictoria()
    }

    method estaEn(escenario) = escenarioActual == escenario

    method salidasEn(pos) = escenarioActual.salidas().filter({ salida => salida.activaEn(pos) })
}