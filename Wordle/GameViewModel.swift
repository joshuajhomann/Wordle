//
//  GameViewModel.swift
//  Wordle
//


import Combine
import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    typealias Action = Game.Action
    @Published private(set) var words: [Row] = []
    @Published private(set) var keys: [Row] = []
    let transactions: any Publisher<Game.Transaction, Never>

    let perform: (Action) -> Void

    init() {
        let actionSubject = PassthroughSubject<Action, Never>()
        perform = actionSubject.send

        let allWords = Bundle.main.url(forResource: "words", withExtension: "json")
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []

        let fiveLetterWords = Set<String>(allWords.lazy.filter { $0.count == 5 })
        let makeWord = { fiveLetterWords.randomElement() ?? "swift" }
        let game = Game()

        let allTransactions = actionSubject
            .scanMap(state: game) { game, action in
                game.reduce(action: action)
            }
            .share()

        transactions = allTransactions
            .filter { transaction in
                switch transaction {
                case .immediate: return false
                default: return true
                }
            }

        let state = allTransactions
            .compactMap { transaction -> Game.State? in
                guard case let .immediate(state) = transaction else { return nil }
                return state
            }

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
                                    status: word.offset - currentWordIndex >= 0 ? .unguessed : status,
                                    isShaking: word.offset == currentWordIndex ? state.shakeCurrentWord : false
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

        actionSubject.send(.reset)
    }
}


