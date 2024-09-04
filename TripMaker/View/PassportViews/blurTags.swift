//
//  blurTags.swift
//  TripMaker
//
//  Created by Megan Lin on 4/3/24.
//

import SwiftUI

struct blurTags:  View {
    
    var tags: Array<String>
    var size: CGFloat = 14
    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
                Text("\(tag)")
                    .font(Font.custom("Bradley Hand", size: size))
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    
            }
        }
    }
}

/*
 #Preview {
 blurTags()
 }
 */
