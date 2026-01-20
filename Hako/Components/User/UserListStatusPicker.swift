//
//  UserListStatusPicker.swift
//  Hako
//  With adapted code from https://stackoverflow.com/a/79158800 for scrollview fading effect
//
//  Created by Gao Tianrun on 17/1/26.
//

import SwiftUI

struct UserListStatusPicker: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animationNamespace
    @Binding private var selection: StatusEnum
    @State private var firstZoneSize: CGFloat = 0
    @State private var lastZoneSize: CGFloat = 0
    private let options: [StatusEnum]
    
    init(selection: Binding<StatusEnum>, options: [StatusEnum]) {
        self._selection = selection
        self.options = options
    }
    
    private func getCornerRadius() -> CGFloat {
        if #available(iOS 26.0, *) {
            return 20
        } else {
            return 10
        }
    }
    
    private func getPadding() -> CGFloat {
        if #available(iOS 26.0, *) {
            return 20
        } else {
            return 12
        }
    }
    
    var body: some View {
        ZStack {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle((colorScheme == .light ? Color.white : Color.black).opacity(0.6))
                    .glassEffect(.regular)
                    .padding(.horizontal, 15)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                    .padding(.horizontal, 7)
            }
            ScrollViewReader { proxy in
                GeometryReader { outer in
                    ScrollView(.horizontal) {
                        HStack(spacing: 5) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    withAnimation(.snappy(duration: 0.1)) {
                                        selection = option
                                    }
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text(option.toString())
                                            .font(.system(size: 13, weight: selection == option ? .semibold : .regular))
                                            .foregroundStyle(Color.primary)
                                        Spacer()
                                    }
                                    .contentShape(RoundedRectangle(cornerRadius: getCornerRadius()))
                                }
                                .buttonStyle(.plain)
                                .frame(height: 28)
                                .background {
                                    if selection == option {
                                        RoundedRectangle(cornerRadius: getCornerRadius())
                                            .foregroundStyle(colorScheme == .light ? Color.white : Color(.systemGray2))
                                            .matchedGeometryEffect(id: "GlassLens", in: animationNamespace)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                        .frame(minWidth: screenSize.width - getPadding() * 2 - 10)
                        .onGeometryChange(for: CGRect.self) { proxy in
                            proxy.frame(in: .scrollView)
                        } action: { frame in
                            let outerSize = outer.size
                            let leadingZoneWidth = min(-frame.minX, 50)
                            let trailingZoneWidth = min(frame.maxX - outerSize.width, 50)
                            if firstZoneSize != leadingZoneWidth {
                                firstZoneSize = leadingZoneWidth
                            }
                            if lastZoneSize != trailingZoneWidth {
                                lastZoneSize = trailingZoneWidth
                            }
                        }
                    }
                    .scrollIndicators(.never)
                    .mask {
                        HStack(spacing: 0) {
                            LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                                .frame(width: max(1, firstZoneSize))
                            Color.black
                            LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                                .frame(width: max(1, lastZoneSize))
                        }
                    }
                    .frame(height: 32)
                    .background(Color(.systemGray4).opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: getCornerRadius()))
                    .padding(.horizontal, getPadding())
                    .sensoryFeedback(.impact(weight: .light), trigger: selection)
                    .onAppear {
                        proxy.scrollTo(selection, anchor: .center)
                    }
                    .onChange(of: selection) {
                        withAnimation {
                            proxy.scrollTo(selection, anchor: .center)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(5)
    }
}
