//
//  UserList.swift
//  Hako
//
//  Created by Gao Tianrun on 23/10/26.
//

import Foundation

struct UserList: Hashable {
    let username: String
    var id: UUID?
    var type: TypeEnum?
    var animeStatus: StatusEnum?
    var animeSort: SortEnum?
    var mangaStatus: StatusEnum?
    var mangaSort: SortEnum?
}
