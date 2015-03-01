//
//  NFA.swift
//  SwiftNFA
//
//  Created by Michele De Pascalis on 01/03/15.
//  Copyright (c) 2015 Michele De Pascalis. All rights reserved.
//

/// The type of a state of the automaton
public typealias NFAStateID = Int

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

public class NFA<T: Hashable> {
	var moves = Map<NFAStateID, T, Set<NFAStateID>>()
	var epsilonMoves: [NFAStateID: Set<NFAStateID>] = [:]
	public var initialState: NFAStateID
	var acceptingStates: Set<NFAStateID>
	var currentStates = Set<NFAStateID>()
	
	/**
	Initializes a new NFA with given initial states and accepting states.
	
	:param: initialState The initial state of the automaton.
	:param: acceptingStates The set of accepting automaton
	*/
	public init(initialState iState: NFAStateID, acceptingStates aStates: Set<NFAStateID>) {
		initialState = iState;
		acceptingStates = aStates
		initiate()
	}
	
	/**
	Adds a possible move to the automaton from a given state to a given state when reading a given symbol.
	
	:param: fState The state in which the move can be done.
	:param: symbol The input symbol that determines the move.
	:param: tState The target state for the move.
	*/
	public func addMoveFromState(fState: NFAStateID, forSymbol symbol: T, toState tState: NFAStateID) {
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
	public func addEpsilonMoveFromState(fState: NFAStateID, toState tState: NFAStateID) {
		if let states = epsilonMoves[fState] {
			epsilonMoves[fState]!.append(tState)
		}
		else {
			epsilonMoves[fState] = [tState]
		}
	}
	
	/**
	Initiates/resets the automaton into its initial state.
	WARNING: This method must be called after new moves are added.
	*/
	public func initiate() {
		currentStates = epsilonClosureForState(initialState)
	}
	
	public func iterateWithSymbol(symbol: T) -> NFAStatus? {
		var targetStates = Set<NFAStateID>()
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
	
	func epsilonClosureForState(state: NFAStateID, visitedStates:Set<NFAStateID> = []) -> Set<NFAStateID> {
		if let epsilonStates = epsilonMoves[state] {
			var nvStates = visitedStates
			nvStates.append(state)
			return [state] + epsilonClosureForSetOfStates(epsilonStates.setBySubtractingSet(nvStates), visitedStates: nvStates)
		}
		else {
			return [state]
		}
	}
	
	func epsilonClosureForSetOfStates(states: Set<NFAStateID>, visitedStates:Set<NFAStateID> = []) -> Set<NFAStateID> {
		var epsilonStates = Set<NFAStateID>()
		for state in states {
			epsilonStates += epsilonClosureForState(state, visitedStates: visitedStates)
		}
		return epsilonStates
	}
}