:- module(tda_juego, [
    initGame/4,
    printGame/2,
    playToBench/3,
    changeActivePokemon/3,
    drawCardFromDeck/3,
    useEnergyCard/4,
    evolvePokemon/4,
    usePokemonAbility/3,
    usePokemonAttack/5,
    useTrainerCard/3,
    endTurn/2
]).

:- use_module(tda_carta_21056415_LagosRivera).
:- use_module(tda_deck_21056415_LagosRivera).

% RF08: Inicializa la partida
% Dominio: Mazo1 x Mazo2 x Semilla x JuegoResultante
% Recorrido: El estado inicial del juego
initGame(DeckJugador1, DeckJugador2, Seed, G1) :-
    % Primero barajamos ambos mazos usando la semilla base
    shuffleDeck(DeckJugador1, Seed, DeckBarajado1),
    randomPuro(Seed, Seed2),
    % Repartimos 7 cartas y validamos que haya al menos un pokemon basico
    obtenerManoValida(DeckBarajado1, DeckJugador1, Seed2, ManoJ1, RestoDeckJ1, Seed3),
    repartirCartas(6, RestoDeckJ1, PremiosJ1, MazoFinalJ1),
    
    shuffleDeck(DeckJugador2, Seed3, DeckBarajado2),
    randomPuro(Seed3, Seed4),
    obtenerManoValida(DeckBarajado2, DeckJugador2, Seed4, ManoJ2, RestoDeckJ2, Seed5),
    repartirCartas(6, RestoDeckJ2, PremiosJ2, MazoFinalJ2),
    
    % Creamos la estructura de cada jugador: [ID, Mano, Premios, Mazo, Banca, Activo, Descarte]
    J1 = [1, ManoJ1, PremiosJ1, MazoFinalJ1, [], null, []],
    J2 = [2, ManoJ2, PremiosJ2, MazoFinalJ2, [], null, []],
    
    % Lanzamos moneda para ver quien parte
    randomPuro(Seed5, Seed6),
    Moneda is Seed6 mod 2,
    determinarTurno(Moneda, TurnoInicial),
    
    G1 = [J1, J2, TurnoInicial].

% Funcion auxiliar para repartir n cartas
repartirCartas(0, Mazo, [], Mazo).
repartirCartas(N, [Carta | RestoMazo], [Carta | RestoMano], MazoFinal) :-
    N > 0,
    N1 is N - 1,
    repartirCartas(N1, RestoMazo, RestoMano, MazoFinal).

% Valida que la mano tenga al menos un pokemon basico
obtenerManoValida(DeckBarajado, DeckOriginal, SeedActual, ManoFinal, MazoFinal, SeedFinal) :-
    repartirCartas(7, DeckBarajado, ManoTentativa, MazoTentativo),
    evaluarMano(ManoTentativa, DeckOriginal, SeedActual, ManoFinal, MazoTentativo, MazoFinal, SeedFinal).

evaluarMano(ManoTentativa, _, SeedActual, ManoTentativa, MazoTentativo, MazoTentativo, SeedActual) :-
    tienePokemonBasicoMano(ManoTentativa).

% Si no tiene basico, se rebaraja el mazo completo y se vuelve a intentar
evaluarMano(ManoTentativa, DeckOriginal, SeedActual, ManoFinal, _, MazoFinal, SeedFinal) :-
    noTienePokemonBasicoMano(ManoTentativa),
    randomPuro(SeedActual, NuevaSeed),
    shuffleDeck(DeckOriginal, NuevaSeed, NuevoDeckBarajado),
    randomPuro(NuevaSeed, OtraSeed),
    obtenerManoValida(NuevoDeckBarajado, DeckOriginal, OtraSeed, ManoFinal, MazoFinal, SeedFinal).

% Verifica si existe algun pokemon basico en la mano
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

% RF09: Genera el string para imprimir el estado del juego
printGame([J1, J2, Turno], Str) :-
    printJugador(J1, Turno, StrJ1),
    printJugador(J2, Turno, StrJ2),
    atomic_list_concat(['=== TABLERO DE JUEGO ===\n', 'Turno del Jugador: ', Turno, '\n\n', StrJ1, '\n', StrJ2], Str).

% Imprime info del jugador
printJugador([ID, Mano, Premios, Mazo, Banca, Activo, Descarte], Turno, Str) :-
    length(Premios, CantPremios),
    length(Mazo, CantMazo),
    printActivo(Activo, StrActivo),
    printBanca(Banca, StrBanca),
    printMano(Mano, ID, Turno, StrMano),
    printDescarte(Descarte, StrDescarte),
    atomic_list_concat([
        '--- JUGADOR ', ID, ' ---\n',
        'Premios restantes: ', CantPremios, '\n',
        'Cartas en mazo: ', CantMazo, '\n',
        StrActivo,
        StrBanca,
        StrMano,
        StrDescarte
    ], Str).

printActivo(null, 'Pokemon Activo: Ninguno\n').
printActivo(CardInGame, Str) :-
    CardInGame \== null,
    printCardInGame(CardInGame, StrCard),
    atomic_list_concat(['Pokemon Activo:\n', StrCard], Str).

printBanca([], 'Banca: Vacia\n').
printBanca(Banca, Str) :-
    Banca \== [],
    printListaBanca(Banca, StrLista),
    atomic_list_concat(['Banca:\n', StrLista], Str).

printListaBanca([], '').
printListaBanca([PJ | Resto], Str) :-
    printCardInGame(PJ, StrPJ),
    printListaBanca(Resto, StrResto),
    atomic_list_concat([StrPJ, StrResto], Str).

% Formato para mostrar pokemon en juego con sus contadores
printCardInGame([CartaBase, Energias, Dagno, Estado], Str) :-
    nth0(3, CartaBase, Nombre),
    nth0(6, CartaBase, Tipo),
    nth0(5, CartaBase, PS),
    nth0(4, CartaBase, EvolDe),
    (EvolDe == null -> TipoBc = 'Basico' ; TipoBc = 'Evolucion'),
    nth0(7, CartaBase, Debilidad),
    nth0(8, CartaBase, Resistencia),
    length(Energias, CantEnergias),
    atomic_list_concat([
        '  - Nombre: ', Nombre, ' | Tipo: ', Tipo, ' | PS Max: ', PS, 
        ' | Clase: ', TipoBc, ' | Dagno recibido: ', Dagno, ' | Estado: ', Estado,
        ' | Debilidad: ', Debilidad, ' | Resistencia: ', Resistencia,
        ' | Energias unidas: ', CantEnergias, '\n'
    ], Str).

printMano(Mano, ID, Turno, Str) :-
    ID == Turno,
    printListaCartasMano(Mano, StrMano),
    atomic_list_concat(['Cartas en Mano:\n', StrMano], Str).
printMano(Mano, ID, Turno, Str) :-
    ID \== Turno,
    length(Mano, Cant),
    atomic_list_concat(['Cartas en Mano: ', Cant, ' (Ocultas para este jugador)\n'], Str).

printListaCartasMano([], '').
printListaCartasMano([Carta | Resto], Str) :-
    nth0(3, Carta, Nombre),
    nth0(0, Carta, Tipo),
    printListaCartasMano(Resto, StrResto),
    atomic_list_concat(['  - ', Nombre, ' (', Tipo, ')\n', StrResto], Str).

printDescarte([], 'Pila de Descarte: Vacia\n').
printDescarte(Lista, Str) :-
    Lista \== [],
    printNombresDescarte(Lista, StrNombres),
    atomic_list_concat(['Pila de Descarte:\n', StrNombres], Str).

printNombresDescarte([], '').
printNombresDescarte([Carta | Resto], Str) :-
    (   nth0(0, Carta, Elem), is_list(Elem)
    ->  nth0(0, Carta, CartaBase), nth0(3, CartaBase, Nombre)
    ;   nth0(3, Carta, Nombre)
    ),
    printNombresDescarte(Resto, StrResto),
    atomic_list_concat(['  * ', Nombre, '\n', StrResto], Str).

% RF10: Agrega un pokemon a la banca
playToBench([J1, J2, Turno], PokemonCard, GameOut) :-
    (Turno == 1 ->
        jugarABanca(J1, PokemonCard, J1Out),
        GameOut = [J1Out, J2, Turno]
    ;
        jugarABanca(J2, PokemonCard, J2Out),
        GameOut = [J1, J2Out, Turno]
    ).

jugarABanca([ID, Mano, Premios, Mazo, Banca, Activo, Descarte], PokemonCard, JugadorOut) :-
    getTipoCarta(PokemonCard, "pokemon"),
    length(Banca, CantBanca),
    CantBanca < 5, % Limite de 5 en banca
    sacarDeMano(PokemonCard, Mano, ManoOut),
    % Iniciamos el pokemon en juego con 0 daño y sin energias
    CartaEnJuego = [PokemonCard, [], 0, "normal"],
    append(Banca, [CartaEnJuego], BancaOut),
    JugadorOut = [ID, ManoOut, Premios, Mazo, BancaOut, Activo, Descarte].

sacarDeMano(Carta, [Carta | Resto], Resto) :- !.
sacarDeMano(Carta, [Otra | Resto], [Otra | RestoOut]) :-
    sacarDeMano(Carta, Resto, RestoOut).

% RF11: Cambia el pokemon activo
changeActivePokemon([J1, J2, Turno], PokemonInBenchCard, GameOut) :-
    (   Turno == 1
    ->  cambiarActivo(J1, PokemonInBenchCard, J1Out),
        GameOut = [J1Out, J2, Turno]
    ;   cambiarActivo(J2, PokemonInBenchCard, J2Out),
        GameOut = [J1, J2Out, Turno]
    ).

% Caso cuando no hay activo previo, solo promovemos
cambiarActivo([ID, Mano, Premios, Mazo, Banca, null, Descarte], PokemonInBenchCard, JugadorOut) :-
    sacarDeMano(PokemonInBenchCard, Banca, BancaSinNuevo),
    JugadorOut = [ID, Mano, Premios, Mazo, BancaSinNuevo, PokemonInBenchCard, Descarte].

% Caso con activo previo: hay que pagar costo de retirada
cambiarActivo([ID, Mano, Premios, Mazo, Banca, [CartaBaseViejo, EnergiasViejas, DagnoViejo, EstadoViejo], Descarte], PokemonInBenchCard, JugadorOut) :-
    sacarDeMano(PokemonInBenchCard, Banca, BancaSinNuevo),
    nth0(9, CartaBaseViejo, CosteRetirada),
    length(EnergiasViejas, CantEnergias),
    CantEnergias >= CosteRetirada, % Validacion de costo
    repartirCartas(CosteRetirada, EnergiasViejas, EnergiasPagadas, EnergiasRestantes),
    ViejoActivoEnBanca = [[CartaBaseViejo, EnergiasRestantes, DagnoViejo, EstadoViejo]],
    append(BancaSinNuevo, ViejoActivoEnBanca, BancaOut),
    append(Descarte, EnergiasPagadas, DescarteOut), % Energias se van al descarte
    JugadorOut = [ID, Mano, Premios, Mazo, BancaOut, PokemonInBenchCard, DescarteOut].

% RF12: Roba carta del mazo
drawCardFromDeck([J1, J2, Turno], CardObtained, GameOut) :-
    (   Turno == 1
    ->  robarCarta(J1, CardObtained, J1Out),
        GameOut = [J1Out, J2, Turno]
    ;   robarCarta(J2, CardObtained, J2Out),
        GameOut = [J1, J2Out, Turno]
    ).

robarCarta([ID, Mano, Premios, [CartaSacada | MazoRestante], Banca, Activo, Descarte], CartaSacada, JugadorOut) :-
    ManoOut = [CartaSacada | Mano],
    JugadorOut = [ID, ManoOut, Premios, MazoRestante, Banca, Activo, Descarte].

% RF13: Une energia a un pokemon
useEnergyCard([J1, J2, Turno], PokemonInGame, EnergyCard, GameOut) :-
    (   Turno == 1
    ->  equiparEnergia(J1, PokemonInGame, EnergyCard, J1Out),
        GameOut = [J1Out, J2, Turno]
    ;   equiparEnergia(J2, PokemonInGame, EnergyCard, J2Out),
        GameOut = [J1, J2Out, Turno]
    ).

equiparEnergia([ID, Mano, Premios, Mazo, Banca, Activo, Descarte], PokemonInGame, EnergyCard, JugadorOut) :-
    getTipoCarta(EnergyCard, "energia"),
    sacarDeMano(EnergyCard, Mano, ManoOut),
    % Buscamos si el pokemon esta en activo o en banca
    (   Activo == PokemonInGame
    ->  PokemonInGame = [CartaBase, Energias, Dagno, Estado],
        append(Energias, [EnergyCard], NuevasEnergias),
        NuevoActivo = [CartaBase, NuevasEnergias, Dagno, Estado],
        JugadorOut = [ID, ManoOut, Premios, Mazo, Banca, NuevoActivo, Descarte]
    ;   sacarDeMano(PokemonInGame, Banca, BancaSinViejo),
        PokemonInGame = [CartaBase, Energias, Dagno, Estado],
        append(Energias, [EnergyCard], NuevasEnergias),
        NuevoEnBanca = [CartaBase, NuevasEnergias, Dagno, Estado],
        append(BancaSinViejo, [NuevoEnBanca], NuevaBanca),
        JugadorOut = [ID, ManoOut, Premios, Mazo, NuevaBanca, Activo, Descarte]
    ).

% RF14: Evoluciona un pokemon
evolvePokemon([J1, J2, Turno], PokemonInGame, EvolutionCard, GameOut) :-
    (   Turno == 1
    ->  evolucionar(J1, PokemonInGame, EvolutionCard, J1Out),
        GameOut = [J1Out, J2, Turno]
    ;   evolucionar(J2, PokemonInGame, EvolutionCard, J2Out),
        GameOut = [J1, J2Out, Turno]
    ).

evolucionar([ID, Mano, Premios, Mazo, Banca, Activo, Descarte], PokemonInGame, EvolutionCard, JugadorOut) :-
    getTipoCarta(EvolutionCard, "pokemon"),
    nth0(4, EvolutionCard, EvolucionaDe), % El nombre del basico previo
    EvolucionaDe \== null,
    PokemonInGame = [CartaBaseVieja, Energias, Dagno, Estado],
    nth0(3, CartaBaseVieja, NombreViejo),
    EvolucionaDe == NombreViejo, % Validamos que sean compatibles
    sacarDeMano(EvolutionCard, Mano, ManoOut),
    NuevoPokemonEnJuego = [EvolutionCard, Energias, Dagno, Estado],
    (   Activo == PokemonInGame
    ->  JugadorOut = [ID, ManoOut, Premios, Mazo, Banca, NuevoPokemonEnJuego, Descarte]
    ;   sacarDeMano(PokemonInGame, Banca, BancaSinViejo),
        append(BancaSinViejo, [NuevoPokemonEnJuego], NuevaBanca),
        JugadorOut = [ID, ManoOut, Premios, Mazo, NuevaBanca, Activo, Descarte]
    ).

% RF15: Usa habilidad
usePokemonAbility(GameIn, PokemonInGame, GameOut) :-
    PokemonInGame = [CartaBase | _],
    nth0(11, CartaBase, Habilidad),
    Habilidad \== null,
    nth0(4, Habilidad, PredicadoAsociado),
    call(PredicadoAsociado, GameIn, GameOut).

% RF16: Ejecuta ataque de pokemon
usePokemonAttack([J1, J2, Turno], PokemonCard, AttackName, AdditionalArgs, GameOut) :-
    (   AttackName == null
    ->  GameOut = [J1, J2, Turno]
    ;   
        % Buscamos el ataque en la lista del pokemon
        PokemonCard = [CartaBaseAtq, EnergiasAtq, _, _],
        nth0(12, CartaBaseAtq, ListaAtaques),
        buscarAtaque(AttackName, ListaAtaques, Ataque),
        Ataque = [Coste, _, _, DagnoBase, PredicadoAsociado],
        
        % Validamos que haya suficientes energias
        length(EnergiasAtq, CantEnergias),
        CantEnergias >= Coste,
        
        % Identificamos al rival
        (   Turno == 1 -> JDefensor = J2 ; JDefensor = J1 ),
        JDefensor = [IdDef, ManoDef, PremiosDef, MazoDef, BancaDef, DefensorActivo, DescarteDef],
        DefensorActivo \== null, 
        DefensorActivo = [CartaBaseDef, EnergiasDef, DagnoActualDef, EstadoDef],
        
        % Calculamos el daño aplicando debilidad o resistencia
        nth0(6, CartaBaseAtq, TipoAtq),
        nth0(7, CartaBaseDef, DebilidadDef),
        nth0(8, CartaBaseDef, ResistenciaDef),
        calcularDagnoFinal(DagnoBase, TipoAtq, DebilidadDef, ResistenciaDef, DagnoFinal),
        
        % Aplicamos daño acumulado
        NuevoDagnoDef is DagnoActualDef + DagnoFinal,
        nth0(5, CartaBaseDef, PsMaxDef),
        
        % Si el daño supera los PS, el pokemon rival cae
        (   NuevoDagnoDef >= PsMaxDef
        ->  % Se mueve al descarte y se roba premio
            NuevoDefensor = null,
            append(DescarteDef, [DefensorActivo], NuevoDescarteDef),
            (   Turno == 1
            ->  J1 = [IdAtq, ManoAtq, [PremioSacado | RestoPremios], MazoAtq, BancaAtq, ActivoAtq, DescarteAtq],
                J1Parcial = [IdAtq, [PremioSacado | ManoAtq], RestoPremios, MazoAtq, BancaAtq, ActivoAtq, DescarteAtq],
                J2Parcial = [IdDef, ManoDef, PremiosDef, MazoDef, BancaDef, NuevoDefensor, NuevoDescarteDef]
            ;   J2 = [IdAtq, ManoAtq, [PremioSacado | RestoPremios], MazoAtq, BancaAtq, ActivoAtq, DescarteAtq],
                J2Parcial = [IdAtq, [PremioSacado | ManoAtq], RestoPremios, MazoAtq, BancaAtq, ActivoAtq, DescarteAtq],
                J1Parcial = [IdDef, ManoDef, PremiosDef, MazoDef, BancaDef, NuevoDefensor, NuevoDescarteDef]
            )
        ;   % Si sobrevive, solo aumentamos el daño registrado
            NuevoDefensor = [CartaBaseDef, EnergiasDef, NuevoDagnoDef, EstadoDef],
            (   Turno == 1
            ->  J1Parcial = J1,
                J2Parcial = [IdDef, ManoDef, PremiosDef, MazoDef, BancaDef, NuevoDefensor, DescarteDef]
            ;   J2Parcial = J2,
                J1Parcial = [IdDef, ManoDef, PremiosDef, MazoDef, BancaDef, NuevoDefensor, DescarteDef]
            )
        ),
        
        GameCasiFinal = [J1Parcial, J2Parcial, Turno],
        
        % Si el ataque tiene un predicado extra, lo llamamos
        (   PredicadoAsociado \== null
        ->  call(PredicadoAsociado, GameCasiFinal, PokemonCard, AdditionalArgs, GameOut)
        ;   GameOut = GameCasiFinal
        )
    ).

% Helpers para calcular daño y buscar ataques
buscarAtaque(NombreBuscado, [Ataque | _], Ataque) :-
    nth0(1, Ataque, NombreBuscado), !.
buscarAtaque(NombreBuscado, [_ | Resto], Ataque) :-
    buscarAtaque(NombreBuscado, Resto, Ataque).

% Logica de tipos: Debilidad duplica, Resistencia resta 20
calcularDagnoFinal(DagnoBase, TipoAtq, Debilidad, _, DagnoFinal) :-
    Debilidad \== null,
    TipoAtq == Debilidad, !,
    DagnoFinal is DagnoBase * 2.
calcularDagnoFinal(DagnoBase, TipoAtq, _, Resistencia, DagnoFinal) :-
    Resistencia \== null,
    TipoAtq == Resistencia, !,
    DagnoFinal is max(0, DagnoBase - 20).
calcularDagnoFinal(DagnoBase, _, _, _, DagnoBase).

% RF17: Ejecuta accion de entrenador
useTrainerCard(GameIn, TrainerCard, GameOut) :-
    getTipoCarta(TrainerCard, "entrenador"),
    nth0(6, TrainerCard, PredicadoAsociado),
    call(PredicadoAsociado, GameIn, GameOut).

% RF18: Cambia turno
endTurn([J1, J2, 1], [J1, J2, 2]).
endTurn([J1, J2, 2], [J1, J2, 1]).