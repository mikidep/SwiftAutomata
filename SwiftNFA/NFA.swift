//
//  NFA.swift
//  SwiftNFA
//
//  Created by Michele De Pascalis on 01/03/15.
//  Copyright (c) 2015 Michele De Pascalis. All rights reserved.
//

/// The type of the current running status for the automaton
public enum NFAStatus: Printable {
	case Running
	case Accepting
	
	public var description: String {
		switch self {
		case .Running:
			return "NFAStatus.Running"
		case .Accepting:
			return "NFAStatus.Accepting"
		}
	}
}

/// This class represents a Nondeterministic Finite Automaton, whose states are represented by objects of type StateType, and whose input is composed by symbols represented by objects of type SymbolType.
public class NFA<StateType: Hashable, SymbolType: Hashable> {
	var moves = Map<StateType, SymbolType, Set<StateType>>()
	var epsilonMoves: [StateType: Set<StateType>] = [:]
	public var initialState: StateType
	var acceptingStates: Set<StateType>
	var currentStates = Set<StateType>()
	
	/**
	Initializes a new NFA with given initial states and accepting states.
	
	:param: initialState The initial state of the automaton.
	:param: acceptingStates The set of accepting automaton
	*/
	public init(initialState iState: StateType, acceptingStates aStates: Set<StateType>) {
		initialState = iState;
		acceptingStates = aStates
		initialize()
	}
	
	/**
	Adds a possible move to the automaton from a given state to a given state when reading a given symbol.
	
	:param: fState The state in which the move can be done.
	:param: symbol The input symbol that determines the move.
	:param: tState The target state for the move.
	*/
	public func addMoveFromState(fState: StateType, forSymbol symbol: SymbolType, toState tState: StateType) {
		if let states = moves[fState, symbol] {
			moves[fState, symbol]!.append(tState)
		}
		else {
			moves[fState, symbol] = [tState]
		}
	}
	
	/**
	Adds a possible ε-move to the automaton from a given state to a given state.
	
	:param: fState The state in which the move can be done.
	:param: tState The target state for the move.
	*/
	public func addEpsilonMoveFromState(fState: StateType, toState tState: StateType) {
		if let states = epsilonMoves[fState] {
			epsilonMoves[fState]!.append(tState)
		}
		else {
			epsilonMoves[fState] = [tState]
		}
	}
	
	/**
	Initializes/resets the automaton into its initial state.
	WARNING: This method must be called after new moves are added.
	*/
	public func initialize() {
		currentStates = epsilonClosureForState(initialState)
	}
	
	public func iterateWithSymbol(symbol: SymbolType) -> NFAStatus? {
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