%Importamos los modulos necesairos para ejecutar el script
:- use_module(tda_carta_21056415_LagosRivera).
:- use_module(tda_deck_21056415_LagosRivera).
:- use_module(tda_juego_21056415_LagosRivera).




%Creo una Funcion auxiliar para multiplicar una carta N veces y llenar el mazo rápido
repetirCarta(_, 0, []).
repetirCarta(Carta, N, [Carta | Resto]) :-
    N > 0,
    N1 is N - 1,
    repetirCarta(Carta, N1, Resto).

%Funcion principal de mi script de prueba, que crea un mazo valido, lo baraja y reparte a dos jugadores, luego imprime el tablero inicial
test :-
    % 1. CREAR CARTAS
    write('1. Creando cartas'), nl,
    createPokemonCard("Base Set", 25, "Pikachu", null, 60, "Electrico", "Lucha", "Metal", 1, false, null, [], Pikachu),
    createEnergyCard("Base Set", 100, "Energia Electrica", Energia),
    
    % 2. ARMAR MAZOS VALIDOS (1 Pikachu + 59 Energias = 60 cartas)
    write('2. Construyendo mazos'), nl,
    repetirCarta(Energia, 59, ListaEnergias),
    append([Pikachu], ListaEnergias, CartasMazo),
    createDeck(CartasMazo, MazoJ1),
    createDeck(CartasMazo, MazoJ2),
    
    % 3. INICIAR EL JUEGO (Usamos una semilla cualquiera, ej: 12345)
    write('3. Inicializando juego (barajando y repartiendo)'), nl,
    initGame(MazoJ1, MazoJ2, 12345, JuegoInicial),
    
    % 4. MOSTRAR TABLERO
    write('4. Imprimiendo el tablero:'), nl, nl,
    printGame(JuegoInicial, TableroStr),
    write(TableroStr), nl,
    write('Archivo/script de prueba terminado').