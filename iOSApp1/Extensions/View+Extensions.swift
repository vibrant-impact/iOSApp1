//
//  View+Extensions.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI

// Global SwiftUI Layout Utilities
extension View {
    // Contextually swaps a primary view layer for a placeholder framework icon when a condition is met
    @ViewBuilder
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        if shouldShow {
            ZStack(alignment: alignment) {
                placeholder()
                self.opacity(0) // Safe image frame allocation hidden state
            }
        } else {
            self
        }
    }
}

// Specialized Corner Layout Modifiers
extension View {
    // Applies a specific rounding radius to targeted, selective corners of a layout container frame
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerLayout(radius: radius, corners: corners))
    }
}

// A custom structural Shape blueprint that targets explicit layout corners for corner radius cuts
struct RoundedCornerLayout: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
