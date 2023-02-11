//
//  GameViewModel.swift
//  Wordle
//


import Combine
import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var words: [Row] = []
    @Published private(set) var keys: [Row] = []

    let perform: (Action) -> Void

    init() {
        let actionSubject = PassthroughSubject<Action, Never>()
        perform = actionSubject.send

        let allWords = Bundle.main.url(forResource: "words", withExtension: "json")
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []

        let fiveLetterWords = Set<String>(allWords.lazy.filter { $0.count == 5 })
        let makeWord = { fiveLetterWords.randomElement() ?? "swift" }

        let state = actionSubject
            .scan(State(targetWord: makeWord())) { state, action in
                switch action {
                case let .tap(character):
                    guard state.currentWord.count < 5 && state.isPlaying else { return state }
                    return with(state) { $0.currentWord.append(character.lowercased()) }
                case .submitWord:
                    guard state.isPlaying && state.currentWord.count == 5 && fiveLetterWords.contains(state.currentWord) else { return state }
                    return with(state) { state in
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
                    }
                case .delete:
                    guard !state.currentWord.isEmpty && state.isPlaying else { return state }
                    return with(state) { $0.currentWord = String($0.currentWord.dropLast()) }
                case .reset: return State(targetWord: makeWord())
                }
            }
            .removeDuplicates()
            .handleEvents(receiveOutput: { print($0) })
            .multicast { CurrentValueSubject(State(targetWord: makeWord())) }
            .autoconnect()

        state
            .map { state in
                var words = state.guessedWords
                if state.isPlaying {
                    words += [state.currentWord.appending(String([Character](repeating: " ", count: 5 - state.currentWord.count)))]
                }
                words += [String](repeating: "     ", count: max(0, 6 - words.count))
                let currentWordIndex = state.guessedWords.count
                return words
                    .enumerated()
                    .map { word in
                        Row(
                            id: word.offset,
                            letters: zip(
                                word.element,
                                Letter.Status.make(for: word.element, target: state.targetWord)
                            ).enumerated().map { index, value in
                                let (letter, status) = value
                                return Letter(
                                    id: word.offset * 10 + index,
                                    character: letter,
                                    status: word.offset - currentWordIndex >= 0 ? .unguessed : status
                                )
                            }
                        )
                    }
            }
            .assign(to: &$words)

        state.map { state -> [Row] in
            ["qwertyuiop", "asdfghjkl", "zxcvbnm"]
                .enumerated()
                .map { string in
                    Row(
                        id: string.offset,
                        letters: string.element.enumerated().map { character in
                            Letter(
                                id: string.offset * 100 + character.offset,
                                character: character.element,
                                status: state.guess[character.element] ?? .unguessed
                            )
                        }
                    )
                }
        }.assign(to: &$keys)
    }
}


extension GameViewModel {
    enum Action {
        case tap(Character), submitWord, delete, reset
    }
    enum Transaction {
        case shake, flip(State)
    }
    struct State: Equatable {
        var targetWord: String
        var currentWord = ""
        var guessedWords: [String] = []
        var isPlaying = true
        var guess: [Character: Letter.Status] = [:]
    }
}
