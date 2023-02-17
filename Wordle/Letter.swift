//
//  Letter.swift
//  Wordle
//

import Foundation

struct Letter: Hashable, Identifiable {
    var id: Int
    var character: Character
    var status: Status
    var isShaking = false
    enum Status: Int, Comparable {
        static func < (lhs: Letter.Status, rhs: Letter.Status) -> Bool { lhs.rawValue < rhs.rawValue }
        case unguessed, wrong, wrongPosition, correct
        static func make(for word: String, target: String) -> [Self] {
            zip(word, target).map { character, targetCharacter in
                if character == targetCharacter { return .correct }
                if target.contains(character) { return .wrongPosition }
                return .wrong
            }
        }
    }
}
