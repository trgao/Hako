//
//  ImageCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 12/7/25.
//

import SwiftUI

struct ImageCarousel: View {
    @Environment(\.displayScale) var displayScale
    @Namespace private var transitionNamespace
    @State private var images: [UIImage?]
    @State private var isPicturesPresented = false
    @State private var isSuccessPresented = false
    @State private var isErrorPresented = false
    let id: String
    let imageUrl: String?
    let pictures: [Picture]
    
    init(id: String, imageUrl: String?, pictures: [Picture]?) {
        self.id = id
        self.imageUrl = imageUrl
        self.pictures = pictures ?? []
        self.images = pictures?.map { _ in nil } ?? []
    }
    
    var image: some View {
        Button {
            isPicturesPresented = true
        } label: {
            ImageFrame(id: id, imageUrl: imageUrl, imageSize: .large)
        }
    }
    
    var carousel: some View {
        VStack(alignment: .trailing) {
            Button {
                isPicturesPresented = false
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
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 70)
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
    
    var body: some View {
        VStack {
            if #available(iOS 18.0, *) {
                image
                    .matchedTransitionSource(id: "pictures", in: transitionNamespace)
            } else {
                image
            }
        }
        .fullScreenCover(isPresented: $isPicturesPresented) {
            if #available(iOS 18.0, *) {
                carousel
                    .navigationTransition(.zoom(sourceID: "pictures", in: transitionNamespace))
            } else {
                carousel
            }
        }
    }
}
