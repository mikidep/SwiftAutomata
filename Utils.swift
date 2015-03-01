//
//  Utils.swift
//  SwiftNFA
//
//  Created by Michele De Pascalis on 01/03/15.
//  Copyright (c) 2015 Michele De Pascalis. All rights reserved.
//

struct Map<X:Hashable,Y:Hashable,V> {
	var values = [X:[Y:V]]()
	subscript (x:X, y:Y)->V? {
		get { return values[x]?[y] }
		set {
			if values[x] == nil {
				values[x] = [Y:V]()
			}
			values[x]![y] = newValue
		}
	}
}