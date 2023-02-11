//
//  Row.swift
//  Wordle
//


struct Row: Hashable, Identifiable {
    var id: Int
    var letters: [Letter]
}
