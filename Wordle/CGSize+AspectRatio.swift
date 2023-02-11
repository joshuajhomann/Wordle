//
//  CGSize+AspectRatio.swift
//  Wordle
//

import CoreGraphics.CGBase

extension CGSize {
    var aspectRatio: CGFloat { width / height }
}
