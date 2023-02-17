//
//  Publisher+ScanMap.swift
//  Wordle
//
//  Created by Joshua Homann on 2/11/23.
//

import Combine

extension Publisher {
    func scanMap<State, Transformed>(
        state: State,
        transform: @escaping (inout State, Output) -> Transformed
    ) -> some Publisher<Transformed, Failure> {
        var copy = state
        return map { value in
            transform(&copy, value)
        }
    }
}
