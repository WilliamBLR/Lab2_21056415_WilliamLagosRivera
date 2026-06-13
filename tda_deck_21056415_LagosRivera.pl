:- module(tda_deck, [
    createDeck/2
    shuffleDeck/3
    randomPuro/2
]).



:- use_module(tda_carta_21056415_LagosRivera).






createDeck(Cards, Deck) :-
    length(Cards, 60),                  %Regla 1: Exactamente 60 cartas
    tienePokemonBasico(Cards),          %Regla 2: Al menos 1 Pokemon basico
    validarCopias(Cards, Cards),        %Regla 3: Maximo 4 copias (salvo energias)
    Deck = Cards.                       %i todo pasa, unifica la baraja

% --- FUNCIONES AUXILIARES----

% Descripcion: Verifica recursivamente si hay al menos un Pokemon basico.
% Caso base: Encontramos un Pokemon basico.
tienePokemonBasico([Carta | _]) :-
    getTipoCarta(Carta, Tipo),
    Tipo == "pokemon",
    nth0(4, Carta, EvolucionaDe),       % El indice 4 en nuestra carta es EvolucionaDe
    EvolucionaDe == null.

% Caso recursivo: Si la carta no es basico, revisamos el resto de la lista.
tienePokemonBasico([_ | Resto]) :-
    tienePokemonBasico(Resto).

% Descripcion: Recorre el mazo validando que ninguna carta supere las 4 copias.
% Caso base: Lista vacia, todo ok.
validarCopias([], _).

% Caso recursivo: Evaluamos la carta actual y pasamos al resto.
validarCopias([Carta | Resto], MazoCompleto) :-
    getTipoCarta(Carta, Tipo),
    validarLimites(Tipo, Carta, MazoCompleto),
    validarCopias(Resto, MazoCompleto).

% Descripcion: Valida el limite de 4 cartas dependiendo si es energia o no.
% Caso 1: Si es energia, siempre es valido (no importa la cantidad).
validarLimites("energia", _, _).

% Caso 2: Si no es energia, contamos cuantas hay en el mazo completo y vemos que sea <= 4.
validarLimites(Tipo, Carta, MazoCompleto) :-
    Tipo \== "energia",                 % \== significa "distinto de"
    getNombre(Carta, Nombre),
    contarCopias(Nombre, MazoCompleto, Cantidad),
    Cantidad =< 4.

% Descripcion: Cuenta cuantas veces aparece un nombre especifico en el mazo.
% Caso base: Mazo vacio, el total es 0.
contarCopias(_, [], 0).

% Caso recursivo 1: El nombre coincide, sumamos 1 al total.
contarCopias(NombreBuscado, [Carta | Resto], Total) :-
    getNombre(Carta, NombreCarta),
    NombreBuscado == NombreCarta,
    contarCopias(NombreBuscado, Resto, SubTotal),
    Total is SubTotal + 1.

% Caso recursivo 2: El nombre no coincide, no sumamos, pasamos al resto.
contarCopias(NombreBuscado, [Carta | Resto], Total) :-
    getNombre(Carta, NombreCarta),
    NombreBuscado \== NombreCarta,
    contarCopias(NombreBuscado, Resto, Total).







%RF07: SHUFFLE DECK


% Descripcion: Genera el siguiente numero de una secuencia pseudoaleatoria.
% Dominio: Xn (Int) X Xn1 (Int)
randomPuro(Xn, Xn1) :-
    Xn1 is (1103515245 * Xn + 12345) mod 2147483648.

% Descripcion: Revuelve una baraja de cartas haciendo uso de una semilla.
% Algoritmo: Utiliza la semilla para calcular un indice. Saca la carta en ese
% indice, genera una nueva semilla con randomPuro, y llama recursivamente 
% con el resto de la baraja para ir armando el mazo mezclado.
% Dominio: DeckIn (TDA Baraja) X Seed (Int) X DeckOut (TDA Baraja)

% Caso base: Una baraja vacia devuelve una baraja vacia.
shuffleDeck([], _, []).

% Caso recursivo: Selecciona una carta y mezcla el resto.
shuffleDeck(DeckIn, Seed, DeckOut) :-
    length(DeckIn, Largo),
    Largo > 0,
    Index is Seed mod Largo,
    sacarElemento(Index, DeckIn, CartaSacada, RestoDeck),
    randomPuro(Seed, NuevaSemilla),
    shuffleDeck(RestoDeck, NuevaSemilla, RestoMezclado),
    DeckOut = [CartaSacada | RestoMezclado].

% --- FUNCIONES AUXILIARES------

% Descripcion: Extrae un elemento en un indice N especifico de una lista.
% Dominio: Indice (Int) X ListaOriginal (List) X Elemento (Item) X ListaRestante (List)

% Caso base: Sacar el elemento 0 es simplemente tomar la cabeza de la lista.
sacarElemento(0, [Elemento | Resto], Elemento, Resto).

% Caso recursivo: Para sacar el elemento N, sacamos el N-1 del resto de la lista.
sacarElemento(N, [Cabeza | Resto], ElementoExtraido, [Cabeza | RestoActualizado]) :-
    N > 0,
    N1 is N - 1,
    sacarElemento(N1, Resto, ElementoExtraido, RestoActualizado).



