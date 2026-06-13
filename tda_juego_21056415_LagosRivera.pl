:- module(tda_juego, [
    initGame/4
]).

:- use_module(tda_carta_21056415_LagosRivera).
:- use_module(tda_deck_21056415_LagosRivera).

initGame(DeckJugador1, DeckJugador2, Seed, G1) :-
    shuffleDeck(DeckJugador1, Seed, DeckBarajado1),
    randomPuro(Seed, Seed2),
    obtenerManoValida(DeckBarajado1, DeckJugador1, Seed2, ManoJ1, RestoDeckJ1, Seed3),
    repartirCartas(6, RestoDeckJ1, PremiosJ1, MazoFinalJ1),
    
    shuffleDeck(DeckJugador2, Seed3, DeckBarajado2),
    randomPuro(Seed3, Seed4),
    obtenerManoValida(DeckBarajado2, DeckJugador2, Seed4, ManoJ2, RestoDeckJ2, Seed5),
    repartirCartas(6, RestoDeckJ2, PremiosJ2, MazoFinalJ2),
    
    J1 = [1, ManoJ1, PremiosJ1, MazoFinalJ1, [], null, []],
    J2 = [2, ManoJ2, PremiosJ2, MazoFinalJ2, [], null, []],
    
    randomPuro(Seed5, Seed6),
    Moneda is Seed6 mod 2,
    determinarTurno(Moneda, TurnoInicial),
    
    G1 = [J1, J2, TurnoInicial].

repartirCartas(0, Mazo, [], Mazo).

repartirCartas(N, [Carta | RestoMazo], [Carta | RestoMano], MazoFinal) :-
    N > 0,
    N1 is N - 1,
    repartirCartas(N1, RestoMazo, RestoMano, MazoFinal).

obtenerManoValida(DeckBarajado, DeckOriginal, SeedActual, ManoFinal, MazoFinal, SeedFinal) :-
    repartirCartas(7, DeckBarajado, ManoTentativa, MazoTentativo),
    evaluarMano(ManoTentativa, DeckOriginal, SeedActual, ManoFinal, MazoTentativo, MazoFinal, SeedFinal).

evaluarMano(ManoTentativa, _, SeedActual, ManoTentativa, MazoTentativo, MazoTentativo, SeedActual) :-
    tienePokemonBasicoMano(ManoTentativa).

evaluarMano(ManoTentativa, DeckOriginal, SeedActual, ManoFinal, _, MazoFinal, SeedFinal) :-
    noTienePokemonBasicoMano(ManoTentativa),
    randomPuro(SeedActual, NuevaSeed),
    shuffleDeck(DeckOriginal, NuevaSeed, NuevoDeckBarajado),
    randomPuro(NuevaSeed, OtraSeed),
    obtenerManoValida(NuevoDeckBarajado, DeckOriginal, OtraSeed, ManoFinal, MazoFinal, SeedFinal).

tienePokemonBasicoMano([Carta | _]) :-
    getTipoCarta(Carta, Tipo),
    Tipo == "pokemon",
    nth0(4, Carta, EvolucionaDe),
    EvolucionaDe == null.

tienePokemonBasicoMano([_ | Resto]) :-
    tienePokemonBasicoMano(Resto).

noTienePokemonBasicoMano([]).

noTienePokemonBasicoMano([Carta | Resto]) :-
    getTipoCarta(Carta, Tipo),
    Tipo \== "pokemon",
    noTienePokemonBasicoMano(Resto).

noTienePokemonBasicoMano([Carta | Resto]) :-
    getTipoCarta(Carta, Tipo),
    Tipo == "pokemon",
    nth0(4, Carta, EvolucionaDe),
    EvolucionaDe \== null,
    noTienePokemonBasicoMano(Resto).

determinarTurno(0, 1). 
determinarTurno(1, 2).