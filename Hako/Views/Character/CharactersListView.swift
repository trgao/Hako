//
//  CharactersListView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct CharactersListView: View {
    @State private var query = ""
    private let characters: [ListCharacter]
    
    init(characters: [ListCharacter]) {
        self.characters = characters
    }
    
    var body: some View {
        List {
            let charactersFiltered = characters.filter { item in
                guard let name = item.character.name else {
                    return false
                }
                if query == "" {
                    return true
                }
                let name1 = name.filter { $0 != "," }.lowercased()
                let name2 = name.split(separator: ",").reversed().joined(separator: " ").lowercased()
                let queryLowercased = query.lowercased()
                
                return name1.contains(queryLowercased) || name2.contains(queryLowercased)
            }
            ForEach(charactersFiltered) { character in
                CharacterListItem(character: character)
            }
        }
        .navigationTitle("Characters")
        .searchable(text: $query, prompt: "Search characters")
    }
}
