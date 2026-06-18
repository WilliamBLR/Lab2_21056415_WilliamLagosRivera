%funcion prinpal 

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

%obtiene el tipo de carta nomas
%dom: carta x tipo
%recorrido: el string del tipo


getTipoCarta(Carta, Tipo) :-
    nth0(0, Carta, Tipo).

%Descripcion: saca la expansion de la carta
%dom: carta x expansion
%recorrido: string de la expansion

getExpansion(Carta, Exp) :-
    nth0(1, Carta, Exp).

%Descripcion: te da el numerito de la carta en la coleccion
%dom: carta x numero
%recorrido: int del numero

getNumero(Carta, Num) :-
    nth0(2, Carta, Num).

%obtener el no,bre de la carta  
getNombre(Carta, Nom) :-
    nth0(3, Carta, Nom).


%RF02
%crea la carta de energia basica
%dom: expansion x numero x nombre x cartaResultante
%recorrido: tda carta energia

createEnergyCard(Expansion, Numero, Nombre, EC) :-
    EC = ["energia", Expansion, Numero, Nombre].


%TDA ATAQUE (RF03)
%crea un ataque pa los pokemon
%dom: coste x nombre x descripcion x dagno x predicado x ataque
%recorrido: tda ataque

createAttack(Cost, Nombre, Descripcion, Dagno, PredicadoAsociado, A) :-
    A = [Cost, Nombre, Descripcion, Dagno, PredicadoAsociado].



% CONSTRUCTOR DE POKEMON (RF04)
%crea la carta pokemon, revisa que tenga vida y que no tenga mas ataques de los que puede
%dom: exp x num x nom x evolucionaDe x ps x tipo x debilidad x resist x costeRetirada x esEX x hab x ataques x carta
%recorrido: tda pokemon

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

% Descripción: Crea una carta de entrenador con sus acciones.

createTrainerCard(Expansion, Numero, Nombre, Tipo, Texto, PredicadoAsociado, C) :-
    C = ["entrenador", Expansion, Numero, Nombre, Tipo, Texto, PredicadoAsociado].