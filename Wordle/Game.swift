//
//  Game.swift
//  Wordle
//
//  Created by Joshua Homann on 2/11/23.
//

import Foundation

final class Game {
    private(set) var state: State
    private let reduce: (inout State, Action) -> Transaction
    init() {
        let allWords = Bundle.main.url(forResource: "words", withExtension: "json")
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
        let fiveLetterWords = Set<String>(allWords.lazy.filter { $0.count == 5 })
        let makeWord = { [fiveLetterWords] in fiveLetterWords.randomElement() ?? "swift" }
        state = .init(targetWord: makeWord())
        reduce = { state, action -> Transaction in
            switch action {
            case let .tap(character):
                guard state.currentWord.count < 5 && state.isPlaying else { return .immediate(state) }
                state.currentWord.append(character.lowercased())
                return .immediate(state)
            case .submitWord:
                guard state.isPlaying else { return .immediate(state) }
                guard state.currentWord.count == 5 && fiveLetterWords.contains(state.currentWord) else {
                    return .shake(with(state) { $0.shakeCurrentWord = true }, state)
                }
                state.guess = zip(
                    state.currentWord,
                    Letter.Status.make(for: state.currentWord, target: state.targetWord)
                )
                .reduce(into: state.guess) { accumulated, next in
                    let (letter, status) = next
                    accumulated[letter] = accumulated[letter].map { max($0, status) } ?? status
                }
                state.guessedWords.append(state.currentWord)
                if state.guessedWords.count == 6 || state.currentWord == state.targetWord {
                    state.isPlaying = false
                }
                state.currentWord = ""
                return .immediate(state)
            case .delete:
                guard !state.currentWord.isEmpty && state.isPlaying else { return .immediate(state) }
                state.currentWord = String(state.currentWord.dropLast())
                return .immediate(state)
            case .reset: return .immediate(State(targetWord: makeWord()))
            case let .apply(newState):
                state = newState
                return .immediate(state)
            }
        }
    }
    func reduce(action: Action) -> Transaction {
        reduce(&state, action)
    }
}

extension Game {
    enum Action {
        case tap(Character), submitWord, delete, reset, apply(State)
    }
    enum Transaction {
        case shake(State, State), flip([State]), immediate(State), win([Transaction]), bounce([State])
    }
    struct State: Equatable {
        var targetWord: String
        var currentWord = ""
        var guessedWords: [String] = []
        var isPlaying = true
        var guess: [Character: Letter.Status] = [:]
        var shakeCurrentWord = false
    }
}
