//
//  ViewItem.swift
//  Hako
//
//  Created by Gao Tianrun on 6/1/26.
//

import Foundation

struct ViewItem: Hashable {
    let type: ViewTypeEnum
    var id: Int = 0
    var name: String?
    var itemType: TypeEnum?
    var animeStatus: StatusEnum?
    var animeSort: SortEnum?
    var mangaStatus: StatusEnum?
    var mangaSort: SortEnum?
    var animeRanking: RankingEnum?
    var mangaRanking: RankingEnum?
}
