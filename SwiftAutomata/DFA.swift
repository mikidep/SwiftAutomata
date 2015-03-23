//
//  DFA.swift
//  SwiftNFA
//
//  Created by Michele De Pascalis on 13/03/15.
//  Copyright (c) 2015 Michele De Pascalis. All rights reserved.
//

public class DFA<StateType: Hashable, SymbolType: Hashable>: Automaton {
	var moves: Table<StateType, SymbolType, StateType>
	public var initialState: StateType
	public var acceptingStates: Set<StateType>
	var currentState: StateType
	
	public var movesTable: Table<StateType, SymbolType, StateType> {
		return moves
	}
	
	public init(movesTable: Table<StateType, SymbolType, StateType>, initialState iState: StateType, acceptingStates aStates: Set<StateType>) {
		moves = movesTable
		initialState = iState
		acceptingStates = aStates
		currentState = initialState
	}
	
	convenience init(initialState iState: StateType, acceptingStates aStates: Set<StateType>) {
		self.init(movesTable: Table<StateType, SymbolType, StateType>(), initialState: iState, acceptingStates: aStates)
	}

	public func setMoveFromState(fState: StateType, forSymbol symbol:SymbolType, toState tState: StateType) {
		moves[fState, symbol] = tState
	}
	
	public func setMove(moveTuple: (fState: StateType, symbol: SymbolType, tState: StateType)) {
		setMoveFromState(moveTuple.fState, forSymbol: moveTuple.symbol, toState: moveTuple.tState)
	}
	
	public func setMoves(movesTuples: [(fState: StateType, symbol: SymbolType, tState: StateType)]) {
		for t in movesTuples {
			setMove(t)
		}
	}

	public func initialize() {
		currentState = initialState
	}
	
	/// If the DFA has no moves for the current state with the given symbol it will not change state and this method will return nil. This also means that if this method is called afterwards it will behave exactly as if it had not been called with a non-accepted symbol.
	public func iterateWithSymbol(symbol: SymbolType) -> NFAStatus? {
		if let tState = moves[currentState, symbol] {
			currentState = tState
			if acceptingStates.contains(tState) {
				return .Accepting
			}
			else {
				return .Running
			}
		}
		else {
			return nil
		}
	}
}

extension DFA: Printable {
	public var description: String {
		var d = ""
		for (state, symbol) in self.movesTable.keys {
			let tState = self.movesTable[state, symbol]!
			d += "(\(state), \(symbol)) ➔ \(tState)"
			if self.acceptingStates.contains(tState) {
				d += " (accepting)"
			}
			d += "\n"
		}
		return d
	}
}