# SwiftNFA
SwiftNFA is a way to implement Nondeterministic Finite Automata in Swift.
###Usage
SwiftNFA has a main generic class called `NFA` that represents the automaton. You can instantiate an automaton with `NFA<StateType, SymbolType>(initialState: iState, acceptingStates: aStates)`, where `StateType` is the type of the objects that represent states of the automaton, `SymbolType` is the type of the objects that the automaton will be receiving as input, `initialState` is a `StateType` representation for the initial state and `aStates` an array (or Set) with the accepting states of the automaton. For example:

    let automaton = NFA<Int, Character>(initialState: 0, acceptingStates: [1, 4])
Will give you an automaton that reads `Character`'s, uses `Int`'s to refer to its own states, starts in state `0` and accepts input if and only if there is a path in its graph ending in states `1` or `4` whose non-epsilon moves are sequentially given by the characters of the input. But I don't have to explain NFA's to you, do I?

The method `addMoveFromState(forSymbol:toState)` adds a transition with a given symbol of type `SymbolType`, or an ε-transition if the symbol is `nil`, from a given state to a given state. You may also use the methods `addEpsilonMoveFromState(toState:)`, `addMove()` and `addMoves()` to add moves in whatever fashion you prefer. `addMove()` will take a 3-tuple composed by the applicable state, the symbol (which, again, can be `nil` to signify an ε-move) and the target state; `addMoves()` will take an array of such tuples.

For example, consider the following NFA:

![NFA example](http://goo.gl/X6RWCC?gdriveurl)

Starting from the automaton instantiated above, the one in the picture is constructed with the following code (the order of the instructions is not relevant):

	automaton.addMoveFromState(1, forSymbol: "a", toState: 1)
	automaton.addMoveFromState(0, forSymbol: nil, toState: 2)   // nil symbol: ε-move!
	// Might as well have used automaton.addEpsilonMoveFromState(0, toState:2)
	automaton.addMove((2, "a", 3))
	automaton.addMoves([(3, "b", 4), (4, nil, 2)])

After you've added new moves, you need to call the `initialize()` method before you can run the automaton, like so:

    automaton.initialize()
 This is also the method you need to call if you want to reset the automaton to its initial state.
 After the initialization, the automaton is iterated via the method `iterateWithSymbol()`, with an argument of type `SymbolType` of course. The method returns a member of the enum `NFAStatus`, either `.Running` if the automaton is still running but has not reached an accepting state yet, or `.Accepting` if the automaton has reached an accepting state, or `nil` if the automaton dies (i.e. there is no possible move to follow for the given symbol).
 

    let test = "ababaa  "
    for c in test {
    	println(automaton.iterateWithSymbol(c))
    }
   The code above outputs:

    Optional(NFAStatus.Accepting)
    Optional(NFAStatus.Accepting)
    Optional(NFAStatus.Running)
    Optional(NFAStatus.Accepting)
    Optional(NFAStatus.Running)
    nil
    nil
    nil

###Initializers
NFA features two initializers, one for a machine without moves, and another, `init(movesTable: (symbolMoves:, epsilonMoves:), initialState:, acceptingStates:)` which lets you specify a moves table: this is given as a tuple composed by a 2D `Map` with the non-ε moves, such that `symbolMoves[state, symbol] = targetState`, and a `Dictionary` containing all the ε-moves such that `epsilonMoves[state] = targetState`.
A table of the same format is also the value of the read only property `movesTable`, which exposes the machine's current transitions table.
   
##About Set's
SwiftNFA currently uses [Nate Cook's Set object](https://github.com/natecook1000/SwiftSets)  to represent sets, and I am really grateful to him for the awesome implementation. However, Swift 1.2 will feature a native `Set` data structure, which I will migrate the code to as soon as it comes out of beta.
###What's with the Foundation free thing? Why not just use NSSet?
As far as I know, there is still a possibility that Apple will open source Swift as it consolidates into a more stable language; furthermore, an open source port called [Phoenix](https://ind.ie/about/phoenix/) is being developed. Anyway, in addition to me being a fan of standard libraries, I would love to see SwiftNFA used in some open source code outside the Apple ecosystem, and using Apple's `Foundation` wouldn't make it just as easy and clean.
