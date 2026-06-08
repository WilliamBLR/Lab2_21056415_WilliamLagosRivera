:- module(tda_carta, [
    getTipoCarta/2,
    getExpansion/2,
    getNumero/2,
    getNombre/2,
    createAttack/6,
    createEnergyCard/4,
    createPokemonCard/13,
    createTrainerCard/7
]).


%(RF01)
%Lista plana donde las primeras 4 posiciones siempre son:
%0: Tipo de Carta (pokemon, energia, entrenador)
%1: Expansion
%2: Numero
%3: Nombre


%Obtiene el tipo general de la carta
%Extrae el elemento en el ondice 0 de la lista
%Dom: Carta  X tipo de carta 
getTipoCarta(Carta, Tipo) :-
    nth0(0, Carta, Tipo).

%Descripción: Obtiene la expansion a la que pertenece la carta

getExpansion(Carta, Exp) :-
    nth0(1, Carta, Exp).

%Descripción: Obtiene el numero de coleccionista de la carta

getNumero(Carta, Num) :-
    nth0(2, Carta, Num).

%obtener el no,bre de la carta  
getNombre(Carta, Nom) :-
    nth0(3, Carta, Nom).


%RF02

createEnergyCard(Expansion, Numero, Nombre, EC) :-
    EC = ["energia", Expansion, Numero, Nombre].


%TDA ATAQUE (RF03)

createAttack(Cost, Nombre, Descripcion, Dagno, PredicadoAsociado, A) :-
    A = [Cost, Nombre, Descripcion, Dagno, PredicadoAsociado].




% CONSTRUCTOR DE POKEMON (RF04)

%Crea una carta de tipo PokE validando sus PS y lImite de ataques
createPokemonCard(Expansion, Numero, Nombre, EvolucionaDe, Ps, Tipo, Debilidad, Resistencia, CosteRetirada, EsEX, Habilidad, Ataques, PC) :-
    Ps > 0,                                %PS no pueden ser 0 ni negativos
    length(Ataques, CantidadAtaques),      %CUANTOS VIENEN EN LA LISTA
    (   Habilidad == null
    ->  CantidadAtaques =< 3               %
    ;   CantidadAtaques =< 2               % 
    ),
    PC = ["pokemon", Expansion, Numero, Nombre, EvolucionaDe, Ps, Tipo, Debilidad, Resistencia, CosteRetirada, EsEX, Habilidad, Ataques].



%RF05 creacion de carta entrenador

% Descripción: Crea una carta de entrenador (partidario u objeto) con sus acciones.

createTrainerCard(Expansion, Numero, Nombre, Tipo, Texto, PredicadoAsociado, C) :-
    C = ["entrenador", Expansion, Numero, Nombre, Tipo, Texto, PredicadoAsociado].