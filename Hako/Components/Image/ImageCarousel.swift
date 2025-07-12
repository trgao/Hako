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
    @State private var isSuccessPresented = false
    @State private var isErrorPresented = false
    let pictures: [Picture]
    
    init(pictures: [Picture]?) {
        self.pictures = pictures ?? []
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
                ForEach(pictures.filter { $0.medium != nil }, id: \.medium) { item in
                    let url = item.large == nil ? item.medium : item.large
                    var inputImage: UIImage?
                    if let url = url {
                        AsyncImage(url: URL(string: url)!) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .onAppear {
                                    inputImage = image.render(scale: displayScale)
                                }
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: UIScreen.main.bounds.width * 9 / 10, height: (UIScreen.main.bounds.width * 9 / 10) / 150 * 212)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contextMenu {
                            Button {
                                guard let inputImage = inputImage else { return }

                                let imageSaver = ImageSaver(isSuccessPresented: $isSuccessPresented, isErrorPresented: $isErrorPresented)
                                imageSaver.writeToPhotoAlbum(image: inputImage)
                            } label: {
                                Label("Save image", systemImage: "square.and.arrow.down")
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
