//
//  ImageCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 12/7/25.
//

import SwiftUI

struct ImageCarousel: View {
    @Environment(\.displayScale) var displayScale
    @Environment(\.dismiss) private var dismiss
    @State private var images: [UIImage?]
    @State private var isSuccessPresented = false
    @State private var isErrorPresented = false
    let pictures: [Picture]
    
    init(pictures: [Picture]?) {
        self.pictures = pictures ?? []
        self.images = pictures?.map { _ in nil } ?? []
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .padding([.horizontal, .top], 20)
            TabView {
                ForEach(Array(pictures.filter { $0.medium != nil }.enumerated()), id: \.0) { index, item in
                    let url = item.large == nil ? item.medium : item.large
                    if let url = url {
                        AsyncImage(url: URL(string: url)!) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .onAppear {
                                    images[index] = image.render(scale: displayScale)
                                }
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: UIScreen.main.bounds.width * 4 / 5, height: (UIScreen.main.bounds.width * 4 / 5) / 150 * 213)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contextMenu {
                            if let inputImage = images[index] {
                                Button {
                                    let imageSaver = ImageSaver(isSuccessPresented: $isSuccessPresented, isErrorPresented: $isErrorPresented)
                                    imageSaver.writeToPhotoAlbum(image: inputImage)
                                } label: {
                                    Label("Save image", systemImage: "square.and.arrow.down")
                                }
                            }
                        }
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .alert("Successfully saved photo", isPresented: $isSuccessPresented) {
            Button("Ok") {}
        }
        .alert("Could not successfully save photo", isPresented: $isErrorPresented) {
            Button("Ok") {}
        } message: {
            Text("Check that you have provided permission for the app to access your photo library, in the Settings app under Apps > Hako > Photos > Add Photos Only")
        }
    }
}
