//
//  ContentView.swift
//  Wordle
//

import Combine
import SwiftUI

struct GameView: View {
    @StateObject var viewModel = GameViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var keyWidth: CGFloat = 80
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                let isVertical = reader.size.aspectRatio <= 1.0
                let maxKeySize: CGFloat = sizeClass == .regular ? 60 : 30
                let scaledMaxKeySize = isVertical ? maxKeySize : 24 * max(reader.size.width / 600, 1)
                let keyWidth = max(min(scaledMaxKeySize, (reader.size.width - (8.0 * 9.0)) / 10.0), 10)
                if isVertical{
                    VStack(spacing: 36) {
                        board(keyWidth: keyWidth)
                    }
                    .padding()
                    .centerInParent()
                } else {
                    HStack(spacing: 36) {
                        board(keyWidth: keyWidth)
                    }
                    .padding()
                    .centerInParent()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Wordle").font(.system(size: 44, weight: .bold)).foregroundColor(.darkGreen)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewModel.perform(.reset) }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
        }
    }
    @ViewBuilder func board(keyWidth: CGFloat) -> some View {
        Grid(alignment: .topLeading, horizontalSpacing: 12, verticalSpacing: 12) {
            ForEach(viewModel.words) { row in
                GridRow {
                    ForEach(row.letters) { letter in
                        LetterView(style: .word(letter))
                    }
                }
            }
        }
        .frame(maxWidth: sizeClass == .regular ? 600 : nil)
        VStack (spacing: 12) {
            ForEach(viewModel.keys) { row in
                HStack(spacing: 8) {
                    if viewModel.keys.last == row {
                        LetterView(style: .keyImage("return"))
                            .onTapGesture { viewModel.perform(.submitWord) }
                            .frame(width: keyWidth * 1.5)
                        keys(for: row, keyWidth: keyWidth)
                        LetterView(style: .keyImage("delete.backward"))
                            .onTapGesture { viewModel.perform(.delete) }
                            .frame(width: keyWidth * 1.5)
                    } else {
                        keys(for: row, keyWidth: keyWidth)
                    }
                }
            }
        }
    }
    private func keys(for row: Row, keyWidth: CGFloat) -> some View {
        ForEach(row.letters) { letter in
            LetterView(style: .key(letter))
                .onTapGesture { viewModel.perform(.tap(letter.character)) }
                .frame(width: keyWidth)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
