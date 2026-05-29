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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.timsDarkBrown.opacity(0.04))
                        .frame(height: 110)
                    
                    // FIXED: Check if the PNG asset exists in the app bundle catalog.
                    // If it is one of the missing 60 items, it smoothly renders our custom cup placeholder!
                    Image(product.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 95)
                        .placeholder(when: UIImage(named: product.image) == nil) {
                            VStack(spacing: 4) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.title)
                                    .foregroundColor(.timsDarkBrown.opacity(0.2))
                                Text("Coming Soon")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(.timsDarkBrown.opacity(0.4))
                            }
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
            .background(Color.timsTan)
            .cornerRadius(16)
            .shadow(color: Color.timsDarkBrown.opacity(0.12), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
