//
//  ProfileView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewmodel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                if let profile = viewmodel.profile {
                    HStack {
                        Text("Profile:")
                        Text("\(profile.name)")
                        Spacer()
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "gear")
                                .foregroundColor(.black)
                        })
                    }
                    Spacer()
                    ProfileImages()
                }
                Button(action: {
                    viewmodel.uploadPhoto()
                }, label: {
                    Text("Upload")
                        
                })
                .padding(10)
            }
            .task {
                do {
                    try await viewmodel.loadProfile()
                } catch let error {
                    print(error)
                }
            }
           
        }
    }
    }

#Preview {
    ProfileView()
}
