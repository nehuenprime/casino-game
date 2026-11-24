import wollok.game.*

object dificultad {
    var property actual = modoNormal

    method alternar() {
        actual = actual.siguiente()
    }
}

object modoNormal {
    method nombre() = "Normal"
    method siguiente() = modoDificil

    method saldoInicial() = 100
    method meta() = 1000
    method fichasParaElJefe() = 500

    method intercambiosVasos() = 6
    method tiempoPasoVasos() = 1100
    method msPorCeldaVaso() = 200
    method tiempoBajarVaso() = 700
    method tiempoMuestraPremio() = 2000

    method multiplicadorNumero() = 5
    method multiplicadorRango() = 1.8

    method danioCartaNormal() = 50
    method danioCartaRapida() = 75
    method danioCartaEspecial() = 100
    method gananciaPorSegundo() = 10
    method intervaloLanzamiento() = 500
    method intervaloMovimiento() = 200
    method intervaloMonedas() = 3000
    method segundosQuietoMaximo() = 4
    method ticsPatronInicial() = 20
    method ticsPatronMinimo() = 10
}

object modoDificil {
    method nombre() = "Difícil"
    method siguiente() = modoNormal

    method saldoInicial() = 100
    method meta() = 1500
    method fichasParaElJefe() = 800

    method intercambiosVasos() = 9
    method tiempoPasoVasos() = 700
    method msPorCeldaVaso() = 120
    method tiempoBajarVaso() = 450
    method tiempoMuestraPremio() = 1000

    method multiplicadorNumero() = 4
    method multiplicadorRango() = 1.5

    method danioCartaNormal() = 100
    method danioCartaRapida() = 150
    method danioCartaEspecial() = 200
    method gananciaPorSegundo() = 7
    method intervaloLanzamiento() = 350
    method intervaloMovimiento() = 140
    method intervaloMonedas() = 5000
    method segundosQuietoMaximo() = 2
    method ticsPatronInicial() = 14
    method ticsPatronMinimo() = 6
}
