:- module(tda_carta, [
    getTipoCarta/2,
    getExpansion/2,
    getNumero/2,
    getNombre/2
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