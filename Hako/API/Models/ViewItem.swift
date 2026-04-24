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
    var name: String? = nil
    var itemType: TypeEnum? = nil
    var animeStatus: StatusEnum? = nil
    var animeSort: SortEnum? = nil
    var mangaStatus: StatusEnum? = nil
    var mangaSort: SortEnum? = nil
    var animeRanking: RankingEnum? = nil
    var mangaRanking: RankingEnum? = nil
}
