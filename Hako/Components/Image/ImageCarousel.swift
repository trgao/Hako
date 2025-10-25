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
    @State private var selection = 0
    @State private var images: [String:UIImage?] = [:]
    @State private var isPicturesPresented = false
    @State private var isSuccessPresented = false
    @State private var isErrorPresented = false
    @State private var isZoomReset = false
    let id: String
    let imageUrl: String?
    let pictures: [Picture]
    
    init(id: String, imageUrl: String?, pictures: [Picture]?) {
        self.id = id
        self.imageUrl = imageUrl
        let allPictures = pictures ?? [Picture(medium: imageUrl, large: nil)]
        self.pictures = allPictures
    }
    
    var image: some View {
        Button {
            isPicturesPresented = true
        } label: {
            ImageFrame(id: id, imageUrl: imageUrl, imageSize: .large)
        }
    }
    
    var carousel: some View {
        ZStack {
            TabView(selection: $selection) {
                ForEach(Array(pictures.filter { $0.medium != nil }.enumerated()), id: \.0) { index, item in
                    let url = item.large ?? item.medium
                    if let url = url {
                        ZoomableScrollView(isZoomReset: $isZoomReset) {
                            AsyncImage(url: URL(string: url)!) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .onAppear {
                                        images[url] = image.render(scale: displayScale)?.removingAlpha()
                                    }
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width * 4 / 5)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                            .contextMenu {
                                if let image = images[url], let inputImage = image {
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
                .ignoresSafeArea()
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .ignoresSafeArea()
            .onChange(of: selection) {
                isZoomReset = true
            }
            Button {
                isPicturesPresented = false
            } label: {
                Image(systemName: "xmark")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding([.horizontal, .top], 20)
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
