
:- module(tda_deck, [
    createDeck/2,
    shuffleDeck/3,
    randomPuro/2
]).



:- use_module(tda_carta_21056415_LagosRivera).







% revisa que no le falte ni una carta
createDeck(Cards, Deck) :-


    length(Cards, 60),                  %Regla 1: 60 cartas o nada
    tienePokemonBasico(Cards),          %tiene que haber al menos un basic
    validarCopias(Cards, Cards),        %no se puede tener 50 pikachus, max 4
    Deck = Cards.                       %si paso todo el filtro, unificamos y listo


% --- FUNCIONES AUXILIARES-----


% Descripcion: busca si hay un basico en el mazo, si no lo encuentra explota o retorna falso
% caso base, pillamos un pokemon basico
tienePokemonBasico([Carta | _]) :-
    getTipoCarta(Carta, Tipo),
    Tipo == "pokemon",
    nth0(4, Carta, EvolucionaDe),       
    EvolucionaDe == null.               %si es null es que es basico pos


% caso recursivo, seguimos buscando en el resto
tienePokemonBasico([_ | Resto]) :-
    tienePokemonBasico(Resto).



% Descripcion: recorre todo el mazo validando 
% Caso base: llegamos al final, todo ok
validarCopias([], _).



% Caso recursivo: evaluamos la cartita actual y seguimos con el resto
validarCopias([Carta | Resto], MazoCompleto) :-
    getTipoCarta(Carta, Tipo),
    validarLimites(Tipo, Carta, MazoCompleto),
    validarCopias(Resto, MazoCompleto).



% Descripcion: valida si la carta se puede meter o ya hay muchas
% si es energia da lo mismo la cantidad
validarLimites("energia", _, _).


% si no es energia hay que contar
validarLimites(Tipo, Carta, MazoCompleto) :-
    Tipo \== "energia",                 
    getNombre(Carta, Nombre),
    contarCopias(Nombre, MazoCompleto, Cantidad),
    Cantidad =< 4.                      %el limite de siempre


% Descripcion: cuenta las copias de una carta en especifico
% Caso base: lista vacia retorna 0
contarCopias(_, [], 0).



% si la carta es igual sumamos uno
contarCopias(NombreBuscado, [Carta | Resto], Total) :-
    getNombre(Carta, NombreCarta),
    NombreBuscado == NombreCarta,
    contarCopias(NombreBuscado, Resto, SubTotal),
    Total is SubTotal + 1.


% si no es igual no sumamos 
contarCopias(NombreBuscado, [Carta | Resto], Total) :-
    getNombre(Carta, NombreCarta),
    NombreBuscado \== NombreCarta,
    contarCopias(NombreBuscado, Resto, Total).







% RF07: SHUFFLE DECK que el mazo no este ordenado


% Descripcion: genera el numerito pseudoaleatorio
randomPuro(Xn, Xn1) :-
    Xn1 is (1103515245 * Xn + 12345) mod 2147483648.



% Descripcion: mezcla el mazo con la semilla
% Algoritmo: saca una carta, mezcla el resto, se repite
% Dominio: deckin x semilla x deckout

% baraja vacia es vacia
shuffleDeck([], _, []).



% caso recursivo: seleccionamos carta y mezclamos lo que queda
shuffleDeck(DeckIn, Seed, DeckOut) :-
    length(DeckIn, Largo),
    Largo > 0,
    Index is Seed mod Largo,
    sacarElemento(Index, DeckIn, CartaSacada, RestoDeck),
    randomPuro(Seed, NuevaSemilla),
    shuffleDeck(RestoDeck, NuevaSemilla, RestoMezclado),
    DeckOut = [CartaSacada | RestoMezclado].



% --- FUNCIONES AUXILIARES PARA SACAR ELEMENTOS------


% Descripcion: extrae elemento en indice n
% esto es sacar la carta del mazo y no dejar el hueco

% caso base, el elemento es el primero
sacarElemento(0, [Elemento | Resto], Elemento, Resto).


% caso recursivo, buscamos el n-1 en el resto
sacarElemento(N, [Cabeza | Resto], ElementoExtraido, [Cabeza | RestoActualizado]) :-
    N > 0,
    N1 is N - 1,
    sacarElemento(N1, Resto, ElementoExtraido, RestoActualizado).