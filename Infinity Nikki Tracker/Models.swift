//
//  Models.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/29/26.
//  Updated based on Supabase schema
//

import Foundation

// MARK: - Profile

struct Profile: Codable {
    let id: String?
    let username: String?
    let displayName: String?
    let avatarURL: String?
    let bannerURL: String?
    let isPremium: Bool?
    let role: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case bannerURL = "banner_url"
        case isPremium = "is_premium"
        case role
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Eureka Models

struct EurekaSet: Codable, Identifiable {
    let id: Int
    let slug: String
    let title: String
    let rarity: Int?
    let style: String?  // Foreign key to styles table
    let label: String?  // Foreign key to labels table
    let description: String?
    let createdAt: String?
    let updatedAt: String?
    let eurekaVariants: [EurekaVariant]
    
    // Computed property for image URL (from default variant)
    var imageURL: String? {
        eurekaVariants.first(where: { $0.isDefault })?.imageURL
    }
    
    // Computed unique categories from variants
    var categories: [EurekaCategory] {
        let uniqueCategories = Set(eurekaVariants.compactMap { $0.category })
        return uniqueCategories.map { EurekaCategory(slug: $0, title: $0, imageURL: "") }
    }
    
    // Computed unique colors from variants
    var colors: [EurekaColor] {
        let uniqueColors = Set(eurekaVariants.compactMap { $0.color })
        return uniqueColors.map { EurekaColor(slug: $0, title: $0, imageURL: "") }
    }
    
    func withVariants(_ variants: [EurekaVariant]) -> EurekaSet {
        EurekaSet(id: id, slug: slug, title: title, rarity: rarity, style: style, label: label, description: description, createdAt: createdAt, updatedAt: updatedAt, eurekaVariants: variants)
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, title, rarity, style, label, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case eurekaVariants = "eureka_variants"
    }
}

struct EurekaVariant: Codable, Identifiable {
    let id: Int
    let slug: String
    let eurekaSet: String?  // Foreign key to eureka_sets (slug)
    let category: String?   // Foreign key to eureka_categories (slug)
    let color: String?      // Foreign key to eureka_colors (slug)
    let imageURL: String?
    let isDefault: Bool
    let createdAt: String?
    let updatedAt: String?
    var obtained: Bool?  // User-specific tracking
    
    func withObtained(_ obtained: Bool) -> EurekaVariant {
        EurekaVariant(id: id, slug: slug, eurekaSet: eurekaSet, category: category, color: color, imageURL: imageURL, isDefault: isDefault, createdAt: createdAt, updatedAt: updatedAt, obtained: obtained)
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, category, color, obtained
        case eurekaSet = "eureka_set"
        case imageURL = "image_url"
        case isDefault = "default"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct EurekaCategory: Codable, Hashable, Identifiable {
    var id: String { slug }
    let slug: String
    let title: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case slug, title
        case imageURL = "image_url"
    }
}

struct EurekaColor: Codable, Hashable, Identifiable {
    var id: String { slug }
    let slug: String
    let title: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case slug, title
        case imageURL = "image_url"
    }
}

// MARK: - Supporting Types

struct Style: Codable, Identifiable {
    var id: String { slug }
    let slug: String
    let title: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case slug, title
        case createdAt = "created_at"
    }
}

struct Label: Codable, Identifiable {
    var id: String { slug }
    let slug: String
    let title: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case slug, title
        case createdAt = "created_at"
    }
}

struct Trial: Codable, Identifiable {
    let id: Int
    let slug: String
    let title: String
    let imageURL: String?
    let realm: String?
    let description: String?
    let location: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, slug, title, realm, description, location
        case imageURL = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct EurekaSetTrial: Codable {
    let eurekaSet: String  // Foreign key to eureka_sets (slug)
    let trial: String      // Foreign key to trials (slug)
    
    enum CodingKeys: String, CodingKey {
        case eurekaSet = "eureka_set"
        case trial
    }
}

// MARK: - CardDisplayable Protocol

protocol CardDisplayable {
    var cardImageURL: String? { get }
    var cardTitle: String { get }
    var cardLabel: String { get }
    var cardStyle: String { get }
    var cardRarity: Int? { get }
    var cardObtained: Int { get }
    var cardTotal: Int { get }
    var cardHasUserData: Bool { get }
    var cardIsSquare: Bool { get }
}

extension CardDisplayable {
    var cardIsSquare: Bool { false }
}

extension EurekaSet: CardDisplayable {
    var cardImageURL: String? { imageURL }
    var cardTitle: String { title }
    var cardLabel: String { label ?? "" }
    var cardStyle: String { style ?? "" }
    var cardRarity: Int? { rarity }
    var cardObtained: Int { eurekaVariants.filter { $0.obtained == true }.count }
    var cardTotal: Int { eurekaVariants.count }
    var cardHasUserData: Bool { eurekaVariants.contains { $0.obtained != nil } }
    var cardIsSquare: Bool { true }
}

extension EurekaVariant: CardDisplayable {
    var cardImageURL: String? { imageURL }
    var cardTitle: String { category?.capitalized ?? slug }
    var cardLabel: String { color ?? "" }
    var cardStyle: String { "" }
    var cardRarity: Int? { nil }
    var cardObtained: Int { obtained == true ? 1 : 0 }
    var cardTotal: Int { 1 }
    var cardHasUserData: Bool { obtained != nil }
    var cardIsSquare: Bool { true }
}

// MARK: - Outfit Models

struct OutfitSet: Codable, Identifiable {
    let id: Int
    let slug: String
    let title: String
    let subtitle: String?
    let rarity: Int?
    let style: String?      // Foreign key to styles table
    let label: String?      // Foreign key to labels table
    let label2: String?     // Foreign key to labels table
    let ability: String?    // Foreign key to abilities table
    let baseSet: String?    // Foreign key to outfit_sets (slug)
    let imageURL: String?
    let altImageURL: String?
    let description: String?
    let order: Int
    let handheldBaseOnly: Bool
    let seasonCategory: String?  // Foreign key to season_categories
    let seasons: String?         // Foreign key to seasons
    let createdAt: String?
    let updatedAt: String?
    let outfitVariants: [OutfitVariant]
    let carouselImages: [OutfitCarouselImage]

    init(id: Int, slug: String, title: String, subtitle: String?, rarity: Int?, style: String?, label: String?, label2: String?, ability: String?, baseSet: String?, imageURL: String?, altImageURL: String?, description: String?, order: Int, handheldBaseOnly: Bool, seasonCategory: String?, seasons: String?, createdAt: String?, updatedAt: String?, outfitVariants: [OutfitVariant], carouselImages: [OutfitCarouselImage]) {
        self.id = id
        self.slug = slug
        self.title = title
        self.subtitle = subtitle
        self.rarity = rarity
        self.style = style
        self.label = label
        self.label2 = label2
        self.ability = ability
        self.baseSet = baseSet
        self.imageURL = imageURL
        self.altImageURL = altImageURL
        self.description = description
        self.order = order
        self.handheldBaseOnly = handheldBaseOnly
        self.seasonCategory = seasonCategory
        self.seasons = seasons
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.outfitVariants = outfitVariants
        self.carouselImages = carouselImages
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        slug = try c.decode(String.self, forKey: .slug)
        title = try c.decode(String.self, forKey: .title)
        subtitle = try c.decodeIfPresent(String.self, forKey: .subtitle)
        rarity = try c.decode(Int.self, forKey: .rarity)
        style = try c.decodeIfPresent(String.self, forKey: .style)
        label = try c.decodeIfPresent(String.self, forKey: .label)
        label2 = try c.decodeIfPresent(String.self, forKey: .label2)
        ability = try c.decodeIfPresent(String.self, forKey: .ability)
        baseSet = try c.decodeIfPresent(String.self, forKey: .baseSet)
        imageURL = try c.decodeIfPresent(String.self, forKey: .imageURL)
        altImageURL = try c.decodeIfPresent(String.self, forKey: .altImageURL)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        order = try c.decode(Int.self, forKey: .order)
        handheldBaseOnly = try c.decodeIfPresent(Bool.self, forKey: .handheldBaseOnly) ?? false
        seasonCategory = try c.decodeIfPresent(String.self, forKey: .seasonCategory)
        seasons = try c.decodeIfPresent(String.self, forKey: .seasons)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)
        outfitVariants = (try? c.decode([OutfitVariant].self, forKey: .outfitVariants)) ?? []
        carouselImages = (try? c.decode([OutfitCarouselImage].self, forKey: .carouselImages)) ?? []
    }

    func withVariants(_ variants: [OutfitVariant]) -> OutfitSet {
        OutfitSet(
            id: id, slug: slug, title: title, subtitle: subtitle,
            rarity: rarity, style: style, label: label, label2: label2,
            ability: ability, baseSet: baseSet, imageURL: imageURL,
            altImageURL: altImageURL, description: description,
            order: order, handheldBaseOnly: handheldBaseOnly,
            seasonCategory: seasonCategory, seasons: seasons,
            createdAt: createdAt, updatedAt: updatedAt,
            outfitVariants: variants, carouselImages: carouselImages
        )
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, title, subtitle, description, rarity, style, label, ability, seasons, order
        case label2 = "label_2"
        case baseSet = "base_set"
        case imageURL = "image_url"
        case altImageURL = "alt_image_url"
        case handheldBaseOnly = "handheld_base_only"
        case seasonCategory = "season_category"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case outfitVariants = "outfit_variants"
        case carouselImages = "outfit_set_carousel_images"
    }
}

struct OutfitVariant: Codable, Identifiable {
    let id: Int
    let slug: String
    let altSlug: String?
    let outfitSet: String?       // Foreign key to outfit_sets (slug)
    let outfitCategory: String?  // Foreign key to outfit_categories (slug)
    let title: String?
    let description: String?
    let rarity: Int?
    let style: String?    // Foreign key to styles table
    let label: String?    // Foreign key to labels table
    let label2: String?   // Foreign key to labels table
    let imageURL: String?
    let altImageURL: String?
    let isDefault: Bool
    let seasonCategory: String?  // Foreign key to season_categories
    let seasons: String?         // Foreign key to seasons
    let createdAt: String?
    let updatedAt: String?
    var obtained: Bool?  // User-specific tracking

    func withObtained(_ obtained: Bool) -> OutfitVariant {
        OutfitVariant(id: id, slug: slug, altSlug: altSlug, outfitSet: outfitSet, outfitCategory: outfitCategory, title: title, description: description, rarity: rarity, style: style, label: label, label2: label2, imageURL: imageURL, altImageURL: altImageURL, isDefault: isDefault, seasonCategory: seasonCategory, seasons: seasons, createdAt: createdAt, updatedAt: updatedAt, obtained: obtained)
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, title, description, rarity, style, label, seasons, obtained
        case altSlug = "alt_slug"
        case outfitSet = "outfit_set"
        case outfitCategory = "outfit_category"
        case label2 = "label_2"
        case imageURL = "image_url"
        case altImageURL = "alt_image_url"
        case isDefault = "default"
        case seasonCategory = "season_category"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct OutfitCategory: Codable, Hashable, Identifiable {
    var id: String { slug }
    let slug: String
    let title: String
    let part: String?
    let imageURL: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case slug, title, part
        case imageURL = "image_url"
        case createdAt = "created_at"
    }
}

struct OutfitCarouselImage: Codable, Identifiable {
    let id: Int
    let imageURL: String
    let outfitSet: String
    let sortOrder: Int
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
        case outfitSet = "outfit_set"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
    }
}

extension OutfitSet: CardDisplayable {
    var cardImageURL: String? { imageURL }
    var cardTitle: String { title }
    var cardLabel: String { label ?? "" }
    var cardStyle: String { style ?? "" }
    var cardRarity: Int? { rarity }
    var cardObtained: Int { outfitVariants.filter { $0.obtained == true }.count }
    var cardTotal: Int { outfitVariants.count }
    var cardHasUserData: Bool { outfitVariants.contains { $0.obtained != nil } }
}

extension OutfitVariant: CardDisplayable {
    var cardImageURL: String? { imageURL }
    var cardTitle: String { title ?? outfitCategory?.capitalized ?? slug }
    var cardLabel: String { label ?? "" }
    var cardStyle: String { style ?? "" }
    var cardRarity: Int? { rarity }
    var cardObtained: Int { obtained == true ? 1 : 0 }
    var cardTotal: Int { 1 }
    var cardHasUserData: Bool { obtained != nil }
    var cardIsSquare: Bool { true }
}

// MARK: - User Progress Tracking

struct ObtainedEureka: Codable, Identifiable {
    let id: Int
    let userId: String?
    let eurekaSet: String?
    let category: String?
    let color: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, category, color
        case userId = "user_id"
        case eurekaSet = "eureka_set"
        case createdAt = "created_at"
    }
}

struct ObtainedOutfits: Codable, Identifiable {
    let id: Int
    let userId: String
    let outfitSet: String
    let outfitCategory: String
    let outfitVariant: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case outfitSet = "outfit_set"
        case outfitCategory = "outfit_category"
        case outfitVariant = "outfit_variant"
        case createdAt = "created_at"
    }
}
