//
//  Slider.swift
//  Rater
//
//  Created by Александр Семенов on 18.11.2023.
//

import SwiftUI

struct Slider: View {
    var body: some View {
        Slider (
            value: $viewmodel.rating,
            in: 0...10,
            step: 1,
            onEditingChanged: { editing in
                viewmodel.isEditing = editing
            }
        )
    }
}

#Preview {
    Slider()
}
