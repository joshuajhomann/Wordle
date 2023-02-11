//
//  With.swift
//  Wordle
//


import Foundation

@discardableResult public func with<Value>(
    _ value: Value,
    update: (inout Value) throws -> Void
) rethrows -> Value {
    var copy = value
    try update(&copy)
    return copy
}
