//
//  AnchorToParentLayout.swift
//  Wordle
//


import SwiftUI

struct AnchorToParentLayout: Layout {
    var parentAnchor: UnitPoint = .center
    var anchor: UnitPoint = .center
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.forEach { view in
            view.place(
                at: .init(x: bounds.minX + bounds.width * parentAnchor.x, y: bounds.minY + bounds.height * parentAnchor.y),
                anchor: anchor,
                proposal: proposal
            )
        }
    }
}

extension View {
    func centerInParent() -> some View {
        AnchorToParentLayout(parentAnchor: .center, anchor: .center) { self }
    }
}
