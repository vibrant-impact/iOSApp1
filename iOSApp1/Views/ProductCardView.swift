//
//  ProductCardView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI

struct ProductCardView: View {
    // The specific decoded product from your JSON file
    let product: JSONProduct
    
    // Closer notification callback to tell the parent view this card was tapped
    var onSelected: () -> Void
    
    var body: some View {
        Button(action: { onSelected() }) {
            VStack(alignment: .leading, spacing: 8) {
                // Image layer container matching your asset file name strings[cite: 1]
                // For now, it uses a placeholder look until you import your image assets next week.
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 110)
                    
                    // Attempts to render your image string asset name[cite: 1]
                    Image(product.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                        // Fallback image framework asset if the local file name isn't found yet
                        .placeholder(when: true) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                }
                
                // Product Metadata Titles Text Labels
                Text(product.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 36, alignment: .topLeading)
                
                HStack {
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.timsRed)
                }
            }
            .padding(10)
            .background(Color(.white))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain) // Prevents the cell click button style from overriding text attributes
    }
}

// Conditional View Extension
extension View {
    @ViewBuilder
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .center, @ViewBuilder placeholder: () -> Content) -> some View {
        if shouldShow {
            ZStack(alignment: alignment) {
                placeholder()
                self.opacity(0) // Hide primary asset rendering safely if placeholder runs
            }
        } else {
            self
        }
    }
}
