//
//  UserListStatusPicker.swift
//  Hako
//
//  Created by Gao Tianrun on 17/1/26.
//

import SwiftUI

struct UserListStatusPicker: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animationNamespace
    @Binding private var selection: StatusEnum
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
                ScrollView(.horizontal, showsIndicators: false) {
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
                }
                .frame(height: 32)
                .background(Color(.systemGray4).opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: getCornerRadius()))
                .padding(.horizontal, getPadding())
                .sensoryFeedback(.selection, trigger: selection)
                .onAppear {
                    proxy.scrollTo(selection, anchor: .center)
                }
                .onChange(of: selection) {
                    withAnimation {
                        proxy.scrollTo(selection, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(5)
    }
}
