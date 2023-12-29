//
//  PhotoStatView.swift
//  Rater
//
//  Created by Александр Семенов on 13.12.2023.
//

import SwiftUI

struct PhotoStatView: View {
    
    @StateObject var viewmodel = PhotoDetailViewModel()
    var id: Int
    
    var body: some View {
        VStack {
            if let photoStat = viewmodel.photoStat {
                PhotoProgressView(title: "Attractiveness", progressNum: photoStat.attractiveness_rating, color: Color.pink)
                PhotoProgressView(title: "Smartness",progressNum: photoStat.smart_rating, color: Color.blue)
                PhotoProgressView(title: "Trustworthy", progressNum: photoStat.trustworthy_rating, color: Color.red)
            } else {
                
            }
        }
        .task {
            await viewmodel.getStatOfPhoto(id: id)
        }
    }
}

struct PhotoProgressView: View {
    var title: String
    var progressNum: Float
    var color: Color
    
    var body: some View {
        ProgressView(value: (progressNum / 10)) {
                            Text("\(title)")
                        } currentValueLabel: {
                            Text("Current Value:" + String(format: "%.2f", progressNum))
                                .tint(color)
                        }
                    
    }
}

#Preview {
    PhotoStatView(id: 1)
}
