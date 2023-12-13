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
                Text("\(photoStat.attractiveness_rating)")
                Text("\(photoStat.smart_rating)")
                Text("\(photoStat.trustworthy_rating)")
            } else {
                Text("NOOO")
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
