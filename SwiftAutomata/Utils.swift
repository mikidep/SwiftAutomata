//
//  Utils.swift
//  SwiftNFA
//
//  Created by Michele De Pascalis on 01/03/15.
//  Copyright (c) 2015 Michele De Pascalis. All rights reserved.
//

struct Pair<X: Hashable, Y: Hashable>: Hashable {
	let x: X
	let y: Y
	
	init(x: X, y: Y) {
		self.x = x
		self.y = y
	}
	
	internal var hashValue: Int {
		return x.hashValue << 32 | (y.hashValue & 0xffffffff)
	}
}

func == <X: Hashable, Y: Hashable> (lhs: Pair<X, Y>, rhs: Pair<X, Y>) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

/// A 2-dimensional table
public struct Table<X: Hashable, Y: Hashable, V> {
	var values: [Pair<X,Y>: V] = [:]
	
	subscript (x: X, y: Y) -> V? {
		get {
			return values[Pair<X, Y>(x: x, y: y)]
		}
		set {
			values[Pair<X, Y>(x: x, y: y)] = newValue
		}
	}
}