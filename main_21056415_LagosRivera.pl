% Importamos todos tus modulos
:- use_module(tda_carta_21056415_LagosRivera).
:- use_module(tda_deck_21056415_LagosRivera).
:- use_module(tda_juego_21056415_LagosRivera).

% ==============================================================================
% PREDICADOS DUMMY PARA EFECTOS (Exigido por RNF8)
% ==============================================================================
% Como los ataques y habilidades llaman a funciones, debemos definirlas aqui.

efecto_paralizar(GameIn, _, _, GameOut) :-
    write('   >>> EFECTO DE ESTAD<: El Pokemon defensor ha sido PARALIZADO.\n'),
    GameOut = GameIn.

efecto_curar(GameIn, GameOut) :-
    write('   >>> EFECTO ENTRENADOR: Se han curado 20 PS de tu Pokemon activo.\n'),
    GameOut = GameIn.

efecto_robar(GameIn, GameOut) :-
    write('   >>> EFECTO ENTRENADOR: Has robado 2 cartas.\n'),
    GameOut = GameIn.

% ==============================================================================
% SCRIPT DE PRUEBAS PRINCIPAL (TESTING RNF8)
% ==============================================================================

test :-
    write('============================================='), nl,
    write('INICIANDO SIMULACION)'), nl,
    write('==========================================='), nl, nl,
    
    write('1. CREANDO SET DE CARTAS REQUERIDAS...'), nl,
    % Creamos ataques (el ataque de Raichu tiene efecto de estado y cuesta 1 energia)
    createAttack(1, "Burbuja", "Pega 20", 20, null, AtqSquirtle),
    createAttack(1, "Rayo Paralizante", "Pega 60 y paraliza", 60, efecto_paralizar, AtqRai),
    
    % Creamos los 3 Basicos exigidos
    createPokemonCard("Base", 1, "Pikachu", null, 60, "Electrico", "Lucha", "Metal", 1, false, null, [], Pikachu),
    createPokemonCard("Base", 2, "Squirtle", null, 60, "Agua", "Electrico", null, 1, false, null, [AtqSquirtle], Squirtle),
    createPokemonCard("Base", 3, "Charmander", null, 60, "Fuego", "Agua", null, 1, false, null, [], Charmander),
    
    % Creamos las 2 Evoluciones exigidas
    createPokemonCard("Base", 4, "Raichu", "Pikachu", 90, "Electrico", "Lucha", "Metal", 1, false, null, [AtqRai], Raichu),
    createPokemonCard("Base", 5, "Wartortle", "Squirtle", 90, "Agua", "Electrico", null, 2, false, null, [], Wartortle),
    
    % Creamos 1 Pokemon EX exigido
    createPokemonCard("Base", 6, "Mewtwo EX", null, 180, "Psiquico", "Oscuro", null, 2, true, null, [], MewtwoEX),
    
    % Creamos 3 Entrenadores exigidos
    createTrainerCard("Base", 7, "Pocion", "Cura 20 PS", "Item", efecto_curar, Pocion),
    createTrainerCard("Base", 8, "Profesor Oak", "Roba cartas", "Support", efecto_robar, ProfOak),
    createTrainerCard("Base", 9, "Cambio", "Cambia activo", "Item", efecto_curar, Cambio),
    
    % Creamos Energia
    createEnergyCard("Base", 10, "Energia Electrica", EElectrica),
    write('   [OK] Todas las cartas creadas con exito.'), nl, nl,

    write('2. CONFIGURANDO ESCENARIO DE COMBATE...'), nl,
    % Configuramos un tablero exacto para demostrar el combate sin depender del azar del mazo
    
    ActivoJ1 = [Pikachu, [], 0, "normal"], 
    ManoJ1 = [Raichu, MewtwoEX, EElectrica, Pocion, ProfOak, Cambio], 
    
    % AQUI ESTA EL ARREGLO: Llenamos los premios con cartas reales para que printGame no colapse al robarlas
    PremiosJ1 = [EElectrica, EElectrica, EElectrica, EElectrica, EElectrica, EElectrica],
    J1 = [1, ManoJ1, PremiosJ1, ["MazoJ1_Restante"], [], ActivoJ1, []],
    
    ActivoJ2 = [Squirtle, [], 0, "normal"], 
    PremiosJ2 = [Pocion, Pocion, Pocion, Pocion, Pocion, Pocion], 
    J2 = [2, [Charmander, Wartortle], PremiosJ2, ["MazoJ2_Restante"], [], ActivoJ2, []],
    
    G_Start = [J1, J2, 1],
    write('   [OK] Tablero configurado. J1 (Pikachu) vs J2 (Squirtle).'), nl, nl,
    
    write('3. ACCIONES DEL JUGADOR 1 (TURNO 1):'), nl,
    
    write('   -> Jugador 1 baja a Mewtwo EX a su banca (playToBench)'), nl,
    playToBench(G_Start, MewtwoEX, G_Banca),
    
    write('   -> Jugador 1 une Energia Electrica a su Pikachu activo (useEnergyCard)'), nl,
    G_Banca = [J1_Banca, _, _], J1_Banca = [_, _, _, _, _, PikachuEnBanca, _], % Extraemos el pokemon para actualizarlo
    useEnergyCard(G_Banca, PikachuEnBanca, EElectrica, G_Energia),
    
    write('   -> Jugador 1 usa Entrenador Pocion (useTrainerCard)'), nl,
    useTrainerCard(G_Energia, Pocion, G_Trainer),
    
    write('   -> Jugador 1 Evoluciona a Pikachu en Raichu (evolvePokemon)'), nl,
    G_Trainer = [J1_Trainer, _, _], J1_Trainer = [_, _, _, _, _, PikachuEquipado, _],
    evolvePokemon(G_Trainer, PikachuEquipado, Raichu, G_Evol),
    
    write('   -> Jugador 1 ATACA con "Rayo Paralizante" (usePokemonAttack)'), nl,
    write('      * Matematica: Raichu pega 60. Squirtle es debil al Electrico (x2).'), nl,
    write('      * Dano total = 120. Squirtle tiene 60 PS. !K.O. INMINENTE!'), nl,
    G_Evol = [J1_Evol, _, _], J1_Evol = [_, _, _, _, _, RaichuActivo, _],
    usePokemonAttack(G_Evol, RaichuActivo, "Rayo Paralizante", [], G_Ataque),
    
    write('\n=============================================================='), nl,
    write('RESULTADO DEL COMBATE Y TABLERO FINAL'), nl,
    write('=============================================================='), nl,
    printGame(G_Ataque, TableroFinal),
    write(TableroFinal), nl,
    write(' el Jugador 1 ahora tiene 5 premios y el Activo de J2 dice "Ninguno". *'), nl,
    write('Scrip/archivo de prueba finaliuzado').