//
//  Animations.swift
//  Wordle
//
//  Created by Joshua Homann on 2/11/23.
//

import SwiftUI

struct HorizontalShakeAnimation: AnimatableModifier {
    var proportion: CGFloat
    var distance: CGFloat

    var animatableData: CGFloat {
        get { proportion }
        set { proportion = newValue }
    }

    func body(content: Content) -> some View {
        content
            .transformEffect(.init(
                translationX: sin(proportion * 6 * .pi) * distance,
                y: 0)
            )
    }
}

extension View {
    func horizontalShakeAnimation(proportion: CGFloat, distance: CGFloat) -> some View {
        modifier(HorizontalShakeAnimation(proportion: proportion, distance: distance))
    }
}
