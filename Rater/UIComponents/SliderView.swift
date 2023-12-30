//
//  Slider.swift
//  Rater
//
//  Created by Александр Семенов on 18.11.2023.
//

import SwiftUI

struct SliderView: View {
    
    @Binding var rating: Float
    var text: String
    @State var isEditing: Bool = false
    
    var body: some View {
        Text("\(text): \(rating, specifier: "%.2f")")
        Slider (
            value: $rating,
            in: 1...10,
            step: 1,
            onEditingChanged: { editing in
                isEditing = editing
            }
        )
        .tint(Color(.red))
    }
}


