//
//  FAQView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct FAQView: View {
    
    private var faqData = FAQData()
    @StateObject var viewmodel = FAQViewModel()
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Switch to Russian", isOn: $viewmodel.isRussianSelected)
                        .padding()
                    
                    if viewmodel.isRussianSelected {
                        ForEach(faqData.russianVersion, id: \.self) { faqItem in
                            FAQItem(question: faqItem["question"]!, answer: faqItem["answer"]!)
                        }
                    } else {
                        ForEach(faqData.englishVersion, id: \.self) { faqItem in
                            FAQItem(question: faqItem["question"]!, answer: faqItem["answer"]!)
                        }
                        
                    }
                }
                .navigationTitle("Rater FAQ")
            }
        }
    }
    
    
    struct FAQItem: View {
        var question: String
        var answer: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(question)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}
