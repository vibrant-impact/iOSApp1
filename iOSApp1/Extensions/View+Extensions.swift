//
//  View+Extensions.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI

// MARK: - Global SwiftUI Layout Utilities
extension View {
    /// Contextually swaps a primary view layer for a placeholder framework icon when a condition is met
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
