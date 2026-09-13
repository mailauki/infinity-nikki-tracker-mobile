//
//  SeedData.swift
//  Infinity Nikki Tracker
//
//  Sample data for SwiftUI previews and component testing.
//

import Foundation

enum SeedData {

    // MARK: - EurekaVariants

    static let variantJacket = EurekaVariant(
        id: 1, slug: "first-snow-jacket", eurekaSet: "first-snow",
        category: "jacket", color: "white", imageURL: nil,
        isDefault: true, createdAt: nil, updatedAt: nil, obtained: true
    )
    static let variantSkirt = EurekaVariant(
        id: 2, slug: "first-snow-skirt", eurekaSet: "first-snow",
        category: "skirt", color: "white", imageURL: nil,
        isDefault: false, createdAt: nil, updatedAt: nil, obtained: true
    )
    static let variantBoots = EurekaVariant(
        id: 3, slug: "first-snow-boots", eurekaSet: "first-snow",
        category: "shoes", color: "white", imageURL: nil,
        isDefault: false, createdAt: nil, updatedAt: nil, obtained: true
    )
    static let variantHat = EurekaVariant(
        id: 4, slug: "first-snow-hat", eurekaSet: "first-snow",
        category: "headwear", color: "white", imageURL: nil,
        isDefault: false, createdAt: nil, updatedAt: nil, obtained: false
    )
    static let variantGloves = EurekaVariant(
        id: 5, slug: "first-snow-gloves", eurekaSet: "first-snow",
        category: "gloves", color: "white", imageURL: nil,
        isDefault: false, createdAt: nil, updatedAt: nil, obtained: false
    )

    // MARK: - EurekaSet (all variants obtained)

    static let eurekaSetComplete = EurekaSet(
        id: 1,
        slug: "first-snow",
        title: "First Snow",
        rarity: 4,
        style: "fairy",
        label: "sweet",
        description: "A delicate snow-inspired outfit.",
        createdAt: nil,
        updatedAt: nil,
        eurekaVariants: [variantJacket, variantSkirt, variantBoots]
    )

    // MARK: - EurekaSet (some variants obtained)

    static let eurekaSetPartial = EurekaSet(
        id: 2,
        slug: "moonlit-garden",
        title: "Moonlit Garden",
        rarity: 5,
        style: "elegant",
        label: "romance",
        description: "Blooms that glow beneath a silver moon.",
        createdAt: nil,
        updatedAt: nil,
        eurekaVariants: [variantJacket, variantSkirt, variantBoots, variantHat, variantGloves]
    )

    // MARK: - EurekaSet (no variants obtained)

    static let eurekaSetEmpty = EurekaSet(
        id: 3,
        slug: "starfall-dream",
        title: "Starfall Dream",
        rarity: 3,
        style: "cute",
        label: "fantasy",
        description: "Catch a falling star.",
        createdAt: nil,
        updatedAt: nil,
        eurekaVariants: [
            EurekaVariant(id: 6, slug: "starfall-top", eurekaSet: "starfall-dream",
                          category: "top", color: "blue", imageURL: nil,
                          isDefault: true, createdAt: nil, updatedAt: nil, obtained: false),
            EurekaVariant(id: 7, slug: "starfall-skirt", eurekaSet: "starfall-dream",
                          category: "skirt", color: "blue", imageURL: nil,
                          isDefault: false, createdAt: nil, updatedAt: nil, obtained: false)
        ]
    )
}
