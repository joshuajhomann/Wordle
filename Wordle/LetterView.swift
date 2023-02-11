//
//  LetterView.swift
//  Wordle
//


import SwiftUI

struct LetterView: View {
    var style: Style
    private let fontSize: CGFloat
    private let aspectRatio: CGFloat
    private let textColor: Color
    private let backgroundColor: Color
    private let outlineColor: Color
    enum Style {
        case key(Letter), word(Letter), keyImage(String)
    }
    init(style: Style) {
        self.style = style
        switch style {
        case let .key(letter):
            aspectRatio = 0.66
            fontSize = 48
            (textColor, backgroundColor, outlineColor) = colors(for: letter, isKey: true)
        case .keyImage:
            aspectRatio = 0.66 * 1.5
            fontSize = 48
            textColor = .black
            backgroundColor = .lightGray
            outlineColor = .clear
        case let .word(letter):
            aspectRatio = 1
            fontSize = 100
            (textColor, backgroundColor, outlineColor) = colors(for: letter, isKey: false)
        }
        func colors(for letter: Letter, isKey: Bool) -> (Color, Color, Color) {
            switch (letter.status, isKey) {
            case (.unguessed, true): return (.black, .lightGray, .clear)
            case (.unguessed, false): return (.black, .white, .black)
            case (.correct, _): return (.white, .darkGreen, .clear)
            case (.wrongPosition, _): return (.white, .darkYellow, .clear)
            case (.wrong, _): return (.white, .darkGray, .clear)
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(outlineColor, lineWidth: 4)
                .background(RoundedRectangle(cornerRadius: 8).fill(backgroundColor))
                .overlay {
                    switch style {
                    case let .keyImage(name):
                        Image(systemName: name)
                    case let .key(letter), let .word(letter):
                        Text(String(describing: letter.character).uppercased())
                    }
                }
                .foregroundColor(textColor)
                .font(.system(size: fontSize * proxy.size.height / 110, weight: .bold))
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LetterView(style: .word(.init(id: 1, character: "a", status: .unguessed))).frame(maxWidth: 60)
            LetterView(style: .word(.init(id: 2, character: "a", status: .wrong))).frame(maxWidth: 60)
            LetterView(style: .word(.init(id: 3, character: "a", status: .wrongPosition))).frame(maxWidth: 60)
            LetterView(style: .word(.init(id: 4, character: "a", status: .correct))).frame(maxWidth: 60)
            LetterView(style: .key(.init(id: 1, character: "a", status: .unguessed))).frame(maxWidth: 30)
            LetterView(style: .key(.init(id: 2, character: "a", status: .wrong))).frame(maxWidth: 30)
            LetterView(style: .key(.init(id: 3, character: "a", status: .wrongPosition))).frame(maxWidth: 30)
            LetterView(style: .key(.init(id: 4, character: "a", status: .correct))).frame(maxWidth: 30)
        }
    }
}
