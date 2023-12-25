//
//  RaterTabView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct RaterTabView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
            PhotosView()
                .tabItem {
                    Image(systemName: "photo")
                    Text("Photos")
                }
            FAQView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("FAQ")
                }
        }
        .accentColor(Color(.red))
    }
}

#Preview {
    RaterTabView()
}
