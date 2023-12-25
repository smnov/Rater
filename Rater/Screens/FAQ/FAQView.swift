//
//  FAQView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct FAQView: View {
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [.blue, .black]), center: .center, startRadius: 2, endRadius: 650)
            VStack {
                Text("FAQ View")
                Text("How is this works?")
        }
        }
    }
}

#Preview {
    FAQView()
}
