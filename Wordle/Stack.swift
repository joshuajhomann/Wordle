//
//  Stack.swift
//  Wordle
//
//  Created by Joshua Homann on 2/11/23.
//

import SwiftUI

struct Stack<Content: View>: View {
    var isVertical: Bool
    var horizontalAlignment: HorizontalAlignment = .center
    var verticalAlignment: VerticalAlignment = .center
    var spacing: CGFloat = 10
    @ViewBuilder var content: () -> Content
    var body: some View {
        let layout = isVertical
            ? AnyLayout(VStackLayout(alignment: horizontalAlignment, spacing: spacing))
            : AnyLayout(HStackLayout(alignment: verticalAlignment, spacing: spacing))
        return layout(content)
    }
}
