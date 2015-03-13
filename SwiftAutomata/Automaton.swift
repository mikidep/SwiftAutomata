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

/// A common interface for NFA and DFA's
protocol Automaton {
	typealias StateType
	typealias SymbolType
	
	var initialState: StateType {get set}
	func iterateWithSymbol(symbol: SymbolType) -> NFAStatus?
}