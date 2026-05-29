//
//  ProductCardView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI

struct ProductCardView: View {
    let product: JSONProduct
    var onSelected: () -> Void
    
    var body: some View {
        Button(action: { onSelected() }) {
            VStack(alignment: .leading, spacing: 8) {
                
                // Image layer container matching asset file name strings
                ZStack {
                    // FIXED: Changed inner box from harsh gray to match your custom background texture smoothly
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.timsDarkBrown.opacity(0.04))
                        .frame(height: 110)
                    
                    Image(product.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 95)
                        .placeholder(when: true) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.4))
                        }
                }
                
                // Product Title text label matching your deep espresso brown theme palette
                Text(product.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.timsDarkBrown)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 36, alignment: .topLeading)
                
                HStack {
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.timsRed)
                }
            }
            .padding(10)
            .background(Color.timsTan) // FIXED: Swapped harsh white card background out for your creamy Tims Tan theme!
            .cornerRadius(16)
            .shadow(color: Color.timsDarkBrown.opacity(0.12), radius: 6, x: 0, y: 3) // Softened shadow contrast
        }
        .buttonStyle(.plain)
    }
}
