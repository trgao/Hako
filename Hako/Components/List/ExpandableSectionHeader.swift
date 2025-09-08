//
//  ExpandableSectionHeader.swift
//  Hako
//
//  Created by Gao Tianrun on 8/9/25.
//

import SwiftUI

struct ExpandableSectionHeader: View {
    @Binding private var isExpanded: Bool
    private var title: String
    
    init(title: String, isExpanded: Binding<Bool>) {
        self.title = title
        self._isExpanded = isExpanded
    }
    
    var body: some View {
        HStack {
            Text(title)
                .textCase(nil)
                .foregroundColor(Color.primary)
                .font(.system(size: 17))
                .bold()
            Spacer()
            Button{
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .rotationEffect(
                        !isExpanded ? Angle(degrees: 0) : Angle(degrees: 90)
                    )
                    .foregroundStyle(Color(.systemGray2))
            }
            .frame(width: 15, height: 15)
        }
    }
}
