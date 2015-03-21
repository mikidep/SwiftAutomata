//
//  NFA.swift
//  SwiftNFA
//
//  Created by Michele De Pascalis on 01/03/15.
//  Copyright (c) 2015 Michele De Pascalis. All rights reserved.
//

/// This class represents a Nondeterministic Finite Automaton, whose states are represented by objects of type StateType, and whose input is composed by symbols represented by objects of type SymbolType.
public class NFA<StateType: Hashable, SymbolType: Hashable>: Automaton {
	var moves: Table<StateType, SymbolType, Set<StateType>>
	var epsilonMoves: [StateType: Set<StateType>]
	public var initialState: StateType {
		didSet {
			initialized = false;
		}
	}
	var acceptingStates: Set<StateType>
	var currentStates = Set<StateType>()
	var initialized = false
	
	public var movesTable: (symbolMoves: Table<StateType, SymbolType, Set<StateType>>, epsilonMoves: [StateType: Set<StateType>]) {
		return (symbolMoves: moves, epsilonMoves: epsilonMoves)
	}
	
	// MARK: Initializers
	/**
	Initializes a new NFA with given states table, initial states and accepting states.
	
	:param: movesTable A tuple composed by a 2D map with the moves for a defined symbol and a Dictionary with the ε-moves.
	:param: initialState The initial state of the automaton.
	:param: acceptingStates The set of accepting automaton
	*/
	public init(movesTable: (symbolMoves: Table<StateType, SymbolType, Set<StateType>>, epsilonMoves: [StateType: Set<StateType>]), initialState iState: StateType, acceptingStates aStates: Set<StateType>) {
		moves = movesTable.symbolMoves
		epsilonMoves = movesTable.epsilonMoves
		initialState = iState;
		acceptingStates = aStates
		initialize()
	}
	
	/**
	Initializes a new NFA with given initial states and accepting states.
	
	:param: initialState The initial state of the automaton.
	:param: acceptingStates The set of accepting automaton
	*/
	public convenience init(initialState iState: StateType, acceptingStates aStates: Set<StateType>) {
		self.init(movesTable: (Table<StateType, SymbolType, Set<StateType>>(), [:]), initialState: iState, acceptingStates: aStates)
	}
	
	// MARK: Moves management
	/**
	Adds a possible move to the automaton from a given state to a given state when reading a given symbol.
	
	:param: fState The state in which the move can be done.
	:param: symbol The input symbol that determines the move, or nil for an ε-move.
	:param: tState The target state for the move.
	*/
	public func addMoveFromState(fState: StateType, forSymbol symbol: SymbolType?, toState tState: StateType) {
		if let unwrappedSymbol = symbol {
			if let states = moves[fState, unwrappedSymbol] {
				moves[fState, unwrappedSymbol]!.append(tState)
			}
			else {
				moves[fState, unwrappedSymbol] = [tState]
			}
		}
		else {
			if let states = epsilonMoves[fState] {
				epsilonMoves[fState]!.append(tState)
			}
			else {
				epsilonMoves[fState] = [tState]
			}
		}
		initialized = false
	}
	
	/**
	Adds a possible ε-move to the automaton from a given state to a given state.
	
	:param: fState The state in which the move can be done.
	:param: tState The target state for the move.
	*/
	public func addEpsilonMoveFromState(fState: StateType, toState tState: StateType) {
		addMoveFromState(fState, forSymbol: nil, toState: tState)
	}
	
	/**
	Adds a possible move based on a given 3-tuple.
	
	:param: moveTuple A 3-tuple composed by the state in which the move can be performed, the symbol on which it will be performed (nil for an ε-move), and the target state.
	*/
	public func addMove(moveTuple: (fState: StateType, symbol: SymbolType?, tState: StateType)) {
		addMoveFromState(moveTuple.fState, forSymbol: moveTuple.symbol, toState: moveTuple.tState)
	}
	
	/**
	Adds possible moves from a given array of 3-tuple.
	
	:param: movesTuples An array of 3-tuples composed by the state in which the move can be performed, the symbol on which it will be performed (nil for an ε-move), and the target state.
	*/
	public func addMoves(movesTuples: [(fState: StateType, symbol: SymbolType?, tState: StateType)]) {
		for t in movesTuples {
			addMove(t)
		}
	}
	
	// MARK: Automaton running methods
	/**
	Initializes/resets the automaton into its initial state.
	WARNING: This method must be called after new moves are added.
	*/
	public func initialize() {
		currentStates = epsilonClosureForState(initialState)
		initialized = true
	}
	
	public func iterateWithSymbol(symbol: SymbolType) -> NFAStatus? {
		if !initialized {
			println("NFA Error: trying to iterate a non-initialized NFA!")
			return nil
		}
		
		var targetStates = Set<StateType>()
		for state in currentStates {
			if let tStates = moves[state, symbol] {
				targetStates += tStates
			}
		}
		currentStates = epsilonClosureForSetOfStates(targetStates)
		if !(currentStates.setByIntersectionWithSet(acceptingStates).isEmpty) {
			return .Accepting
		}
		else if !(currentStates.isEmpty) {
			return .Running
		}
		
		// No possible moves for given symbol, automaton is dead.
		return nil
	}
	
	
	// MARK: ε-closures helper methods
	func epsilonClosureForState(state: StateType, visitedStates:Set<StateType> = []) -> Set<StateType> {
		if let epsilonStates = epsilonMoves[state] {
			var nvStates = visitedStates
			nvStates.append(state)
			return [state] + epsilonClosureForSetOfStates(epsilonStates.setBySubtractingSet(nvStates), visitedStates: nvStates)
		}
		else {
			return [state]
		}
	}
	
	func epsilonClosureForSetOfStates(states: Set<StateType>, visitedStates:Set<StateType> = []) -> Set<StateType> {
		var epsilonStates = Set<StateType>()
		for state in states {
			epsilonStates += epsilonClosureForState(state, visitedStates: visitedStates)
		}
		return epsilonStates
	}
}

/* For some reason Swift's still shitty types system won't accept them.

// MARK: << overloading
/**
Shorthand operator for left.addMove(right)
*/
public func << <StateType: Hashable, SymbolType: Hashable> (inout left: NFA<StateType, SymbolType>, right: (fState: StateType, symbol: SymbolType?, tState: StateType)) {
	left.addMove(right)
}

/**
Shorthand operator for left.addMoves(right)
*/
public func << <StateType: Hashable, SymbolType: Hashable> (inout left: NFA<StateType, SymbolType>, right: [(fState: StateType, symbol: SymbolType?, tState: StateType)]) {
	left.addMoves(right)
}
*/
