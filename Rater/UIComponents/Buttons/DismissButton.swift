//
//  DismissButton.swift
//  Rater
//
//  Created by Александр Семенов on 12.12.2023.
//

import SwiftUI

struct DismissButton: View {
    
    @Binding var isShowingDetail: Bool
    
    var body: some View {
        Button {
            isShowingDetail = false
        } label: {
            
            ZStack {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .opacity(0.6)
                Image(systemName: "xmark")
                    .imageScale(.small)
                    .frame(width: 44, height: 44)
                    .foregroundColor(.black)
            }
        }
    }
}
