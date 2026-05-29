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
        Button(action: {
            // FIXED: Triggers tactile cup sound effect when this specific menu card gets pressed
            SoundManager.shared.playSound(named: "cup-on-table", withExtension: "mp3")
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelected()
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.timsDarkBrown.opacity(0.04))
                        .frame(height: 110)
                    
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
