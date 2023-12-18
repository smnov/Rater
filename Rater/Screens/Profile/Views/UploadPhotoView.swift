//
//  UploadPhotoView.swift
//  Rater
//
//  Created by Александр Семенов on 17.12.2023.
//

import SwiftUI
import PhotosUI

struct UploadPhotoView: View {
    
    @State private var photoItem: PhotosPickerItem?
    @StateObject var viewmodel = ProfileViewModel()
    
    var body: some View {
        VStack {
            PhotosPicker("Upload Photo", selection: $photoItem, matching: .images)
        }
        .onChange(of: photoItem) {
            Task {
                if let loaded = try? await photoItem?.loadTransferable(type: Image.self) {
                    viewmodel.uploadPhoto(photo: loaded)
                } else {
                    print("Failed")
                }
            }
        }
    }
}

#Preview {
    UploadPhotoView()
}
