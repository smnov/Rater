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
                Text("Attractiveness: " + String(format: "%.2f", photoStat.attractiveness_rating))
                Text("Smart: " + String(format: "%.2f", photoStat.smart_rating))
                Text("Trustworthy: " + String(format: "%.2f", photoStat.trustworthy_rating))
            } else {
                
            }
        }
        .task {
            await viewmodel.getStatOfPhoto(id: id)
        }
    }
}

#Preview {
    PhotoStatView(id: 1)
}
