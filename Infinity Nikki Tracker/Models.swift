//
//  Models.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/29/26.
//  Updated based on Supabase schema
//

import Foundation
import Supabase

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

// MARK: - User Preferences

enum ThemeMode: String, Codable, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: return "display"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

enum TextScale: String, Codable, CaseIterable, Identifiable {
    case compact, `default`, comfortable, large

    var id: String { rawValue }

    var label: String {
        switch self {
        case .compact: return "Compact"
        case .default: return "Default"
        case .comfortable: return "Comfortable"
        case .large: return "Large"
        }
    }
}

enum DefaultSortOrder: String, Codable, CaseIterable, Identifiable {
    case newest, oldest

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newest: return "Newest first"
        case .oldest: return "Oldest first"
        }
    }
}

enum ColorTheme: String, Codable, CaseIterable, Identifiable {
    case terracotta, moonlight, cherryBlossom = "cherry_blossom", forest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .terracotta: return "Terracotta"
        case .moonlight: return "Moonlight"
        case .cherryBlossom: return "Cherry Blossom"
        case .forest: return "Forest"
        }
    }

    var subtitle: String {
        switch self {
        case .terracotta: return "Warm earthy tones"
        case .moonlight: return "Cool purples and lavender"
        case .cherryBlossom: return "Deep rose and soft pinks"
        case .forest: return "Lush greens and foliage"
        }
    }

    /// Matches the theme's subfolder name under Assets.xcassets/Theme.
    var assetFolder: String {
        switch self {
        case .terracotta: return "Terracotta"
        case .moonlight: return "Moonlight"
        case .cherryBlossom: return "Cherry Blossom"
        case .forest: return "Forest"
        }
    }
}

struct UserPreferences: Codable {
    let userId: String?
    let theme: ThemeMode?
    let colorTheme: ColorTheme?
    let sortOrder: DefaultSortOrder?
    let textScale: TextScale?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case theme
        case colorTheme = "color_theme"
        case sortOrder = "sort_order"
        case textScale = "text_scale"
        case updatedAt = "updated_at"
    }
}

// MARK: - Eureka Models

struct EurekaSet: Codable, Hashable, Identifiable {
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

struct EurekaVariant: Codable, Hashable, Identifiable {
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
    var cardOrder: Int? { get }
}

extension CardDisplayable {
    var cardIsSquare: Bool { false }
    var cardOrder: Int? { nil }
}

// MARK: - DetailDisplayable Protocol

protocol DetailDisplayable: CardDisplayable {
    var detailDescription: String? { get }
    var detailAbility: String? { get }
    var detailSeasons: String? { get }
    var detailSeasonCategory: String? { get }
}

extension DetailDisplayable {
    var detailDescription: String? { nil }
    var detailAbility: String? { nil }
    var detailSeasons: String? { nil }
    var detailSeasonCategory: String? { nil }
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

extension EurekaSet: DetailDisplayable {}

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

struct OutfitSet: Codable, Hashable, Identifiable {
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

struct OutfitVariant: Codable, Hashable, Identifiable {
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
    let categoryId: Int
    let slug: String
    let title: String
    let part: String?
    let imageURL: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case slug, title, part
        case categoryId = "id"
        case imageURL = "image_url"
        case createdAt = "created_at"
    }
}

struct OutfitCarouselImage: Codable, Hashable, Identifiable {
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
    var cardOrder: Int? { order }
}

extension OutfitSet {
    // Shared PostgREST select used wherever outfit_sets are fetched with their variants.
    static let supabaseSelect = """
    id,
    slug,
    title,
    subtitle,
    description,
    rarity,
    style,
    label,
    label_2,
    ability,
    seasons,
    season_category,
    "order",
    base_set,
    handheld_base_only,
    season:seasons!outfit_sets_seasons_fkey ( title ),
    seasonCategory:season_categories!outfit_sets_season_category_fkey ( title ),
    image_url,
    alt_image_url,
    updated_at,
    outfit_set_carousel_images (
      id,
      image_url,
      sort_order
    ),
    outfit_variants (
      id,
      slug,
      alt_slug,
      outfit_set,
      outfit_category,
      title,
      description,
      rarity,
      style,
      label,
      label_2,
      image_url,
      alt_image_url,
      "default",
      season_category,
      seasons,
      updated_at
    )
    """
}

extension Array where Element == OutfitSet {
    private struct ObtainedVariantSlug: Codable {
        let outfitVariant: String
        enum CodingKeys: String, CodingKey {
            case outfitVariant = "outfit_variant"
        }
    }

    // Pages through obtained_outfit rows for a user and marks matching variants as obtained.
    func applyingObtainedOutfits(userId: UUID) async -> [OutfitSet] {
        do {
            var allRecords: [ObtainedVariantSlug] = []
            let pageSize = 1000
            var from = 0
            while true {
                let page: [ObtainedVariantSlug] = try await supabase
                    .from("obtained_outfit")
                    .select("outfit_variant")
                    .eq("user_id", value: userId)
                    .order("id", ascending: true)
                    .range(from: from, to: from + pageSize - 1)
                    .execute()
                    .value
                allRecords.append(contentsOf: page)
                if page.count < pageSize { break }
                from += pageSize
            }

            let obtainedSlugs = Set(allRecords.map { $0.outfitVariant })

            return map { set in
                set.withVariants(set.outfitVariants.map { variant in
                    variant.withObtained(obtainedSlugs.contains(variant.slug))
                })
            }
        } catch {
            print("⚠️ Failed to load obtained data: \(error)")
            return self
        }
    }
}

extension OutfitSet: DetailDisplayable {
    var detailDescription: String? { description }
    var detailAbility: String? { ability }
    var detailSeasons: String? { seasons }
    var detailSeasonCategory: String? { seasonCategory }
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

// MARK: - Makeup Models

struct MakeupSet: Codable, Hashable, Identifiable {
    let id: Int
    let slug: String
    let title: String
    let description: String?
    let rarity: Int?
    let style: String?
    let outfitSet: String?  // Foreign key to outfit_sets (slug)
    let baseSet: String?    // Foreign key to makeup_sets (slug)
    let imageURL: String?
    let altImageURL: String?
    let order: Int
    let seasonCategory: String?  // Foreign key to season_categories
    let seasons: String?         // Foreign key to seasons
    let createdAt: String?
    let updatedAt: String?
    let makeupVariants: [MakeupVariant]

    init(id: Int, slug: String, title: String, description: String?, rarity: Int?, style: String?, outfitSet: String?, baseSet: String?, imageURL: String?, altImageURL: String?, order: Int, seasonCategory: String?, seasons: String?, createdAt: String?, updatedAt: String?, makeupVariants: [MakeupVariant]) {
        self.id = id
        self.slug = slug
        self.title = title
        self.description = description
        self.rarity = rarity
        self.style = style
        self.outfitSet = outfitSet
        self.baseSet = baseSet
        self.imageURL = imageURL
        self.altImageURL = altImageURL
        self.order = order
        self.seasonCategory = seasonCategory
        self.seasons = seasons
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.makeupVariants = makeupVariants
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        slug = try c.decode(String.self, forKey: .slug)
        title = try c.decode(String.self, forKey: .title)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        rarity = try c.decodeIfPresent(Int.self, forKey: .rarity)
        style = try c.decodeIfPresent(String.self, forKey: .style)
        outfitSet = try c.decodeIfPresent(String.self, forKey: .outfitSet)
        baseSet = try c.decodeIfPresent(String.self, forKey: .baseSet)
        imageURL = try c.decodeIfPresent(String.self, forKey: .imageURL)
        altImageURL = try c.decodeIfPresent(String.self, forKey: .altImageURL)
        order = try c.decode(Int.self, forKey: .order)
        seasonCategory = try c.decodeIfPresent(String.self, forKey: .seasonCategory)
        seasons = try c.decodeIfPresent(String.self, forKey: .seasons)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)
        makeupVariants = (try? c.decode([MakeupVariant].self, forKey: .makeupVariants)) ?? []
    }

    func withVariants(_ variants: [MakeupVariant]) -> MakeupSet {
        MakeupSet(
            id: id, slug: slug, title: title, description: description,
            rarity: rarity, style: style, outfitSet: outfitSet, baseSet: baseSet,
            imageURL: imageURL, altImageURL: altImageURL, order: order,
            seasonCategory: seasonCategory, seasons: seasons,
            createdAt: createdAt, updatedAt: updatedAt, makeupVariants: variants
        )
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, title, description, rarity, style, seasons, order
        case outfitSet = "outfit_set"
        case baseSet = "base_set"
        case imageURL = "image_url"
        case altImageURL = "alt_image_url"
        case seasonCategory = "season_category"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case makeupVariants = "makeup_variants"
    }
}

struct MakeupVariant: Codable, Hashable, Identifiable {
    let id: Int
    let slug: String
    let altSlug: String?
    let makeupSet: String?       // Foreign key to makeup_sets (slug)
    let makeupCategory: String?  // Foreign key to makeup_categories (slug)
    let title: String?
    let description: String?
    let rarity: Int?
    let style: String?
    let imageURL: String?
    let altImageURL: String?
    let isDefault: Bool
    let seasonCategory: String?  // Foreign key to season_categories
    let seasons: String?         // Foreign key to seasons
    let createdAt: String?
    let updatedAt: String?
    var obtained: Bool?  // User-specific tracking

    func withObtained(_ obtained: Bool) -> MakeupVariant {
        MakeupVariant(id: id, slug: slug, altSlug: altSlug, makeupSet: makeupSet, makeupCategory: makeupCategory, title: title, description: description, rarity: rarity, style: style, imageURL: imageURL, altImageURL: altImageURL, isDefault: isDefault, seasonCategory: seasonCategory, seasons: seasons, createdAt: createdAt, updatedAt: updatedAt, obtained: obtained)
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, title, description, rarity, style, seasons, obtained
        case altSlug = "alt_slug"
        case makeupSet = "makeup_set"
        case makeupCategory = "makeup_category"
        case imageURL = "image_url"
        case altImageURL = "alt_image_url"
        case isDefault = "default"
        case seasonCategory = "season_category"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MakeupCategory: Codable, Hashable, Identifiable {
    var id: String { slug }
    let categoryId: Int
    let slug: String
    let title: String
    let imageURL: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case slug, title
        case categoryId = "id"
        case imageURL = "image_url"
        case createdAt = "created_at"
    }
}

extension MakeupSet: CardDisplayable {
    var cardImageURL: String? { imageURL }
    var cardTitle: String { title }
    var cardLabel: String { "" }
    var cardStyle: String { style ?? "" }
    var cardRarity: Int? { rarity }
    var cardObtained: Int { makeupVariants.filter { $0.obtained == true }.count }
    var cardTotal: Int { makeupVariants.count }
    var cardHasUserData: Bool { makeupVariants.contains { $0.obtained != nil } }
    var cardOrder: Int? { order }
}

extension MakeupSet: DetailDisplayable {
    var detailDescription: String? { description }
    var detailSeasons: String? { seasons }
    var detailSeasonCategory: String? { seasonCategory }
}

extension MakeupSet {
    // Shared PostgREST select used wherever makeup_sets are fetched with their variants.
    static let supabaseSelect = """
    id,
    slug,
    title,
    description,
    rarity,
    style,
    outfit_set,
    base_set,
    "order",
    season_category,
    seasons,
    image_url,
    alt_image_url,
    updated_at,
    makeup_variants (
      id,
      slug,
      alt_slug,
      makeup_set,
      makeup_category,
      title,
      description,
      rarity,
      style,
      image_url,
      alt_image_url,
      "default",
      season_category,
      seasons,
      updated_at
    )
    """
}

extension Array where Element == MakeupSet {
    private struct ObtainedMakeupVariantSlug: Codable {
        let makeupVariant: String
        enum CodingKeys: String, CodingKey {
            case makeupVariant = "makeup_variant"
        }
    }

    // Pages through obtained_makeup rows for a user and marks matching variants as obtained.
    func applyingObtainedMakeup(userId: UUID) async -> [MakeupSet] {
        do {
            var allRecords: [ObtainedMakeupVariantSlug] = []
            let pageSize = 1000
            var from = 0
            while true {
                let page: [ObtainedMakeupVariantSlug] = try await supabase
                    .from("obtained_makeup")
                    .select("makeup_variant")
                    .eq("user_id", value: userId)
                    .order("id", ascending: true)
                    .range(from: from, to: from + pageSize - 1)
                    .execute()
                    .value
                allRecords.append(contentsOf: page)
                if page.count < pageSize { break }
                from += pageSize
            }

            let obtainedSlugs = Set(allRecords.map { $0.makeupVariant })

            return map { set in
                set.withVariants(set.makeupVariants.map { variant in
                    variant.withObtained(obtainedSlugs.contains(variant.slug))
                })
            }
        } catch {
            print("⚠️ Failed to load obtained data: \(error)")
            return self
        }
    }
}

extension MakeupVariant: CardDisplayable {
    var cardImageURL: String? { imageURL }
    var cardTitle: String { title ?? makeupCategory?.capitalized ?? slug }
    var cardLabel: String { "" }
    var cardStyle: String { style ?? "" }
    var cardRarity: Int? { rarity }
    var cardObtained: Int { obtained == true ? 1 : 0 }
    var cardTotal: Int { 1 }
    var cardHasUserData: Bool { obtained != nil }
    var cardIsSquare: Bool { true }
}

// MARK: - Momo Cloak Models

struct MomoCloak: Codable, Hashable, Identifiable {
    let id: Int
    let slug: String
    let title: String
    let description: String?
    let rarity: Int?
    let style: String?     // Foreign key to styles table
    let label: String?     // Foreign key to labels table
    let location: String?  // Foreign key to locations table
    let outfitSet: String? // Foreign key to outfit_sets (slug)
    let imageURL: String?
    let altImageURL: String?
    let seasonCategory: String?  // Foreign key to season_categories
    let seasons: String?         // Foreign key to seasons
    let createdAt: String?
    let updatedAt: String?
    var obtained: Bool?  // User-specific tracking

    func withObtained(_ obtained: Bool) -> MomoCloak {
        MomoCloak(id: id, slug: slug, title: title, description: description, rarity: rarity, style: style, label: label, location: location, outfitSet: outfitSet, imageURL: imageURL, altImageURL: altImageURL, seasonCategory: seasonCategory, seasons: seasons, createdAt: createdAt, updatedAt: updatedAt, obtained: obtained)
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, title, description, rarity, style, label, location, seasons, obtained
        case outfitSet = "outfit_set"
        case imageURL = "image_url"
        case altImageURL = "alt_image_url"
        case seasonCategory = "season_category"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension MomoCloak {
    // Shared PostgREST select used wherever momo_cloaks are fetched.
    static let supabaseSelect = """
    id,
    slug,
    title,
    description,
    rarity,
    style,
    label,
    location,
    outfit_set,
    season_category,
    seasons,
    image_url,
    alt_image_url,
    updated_at
    """
}

extension Array where Element == MomoCloak {
    private struct ObtainedMomoCloakSlug: Codable {
        let momoCloak: String
        enum CodingKeys: String, CodingKey {
            case momoCloak = "momo_cloak"
        }
    }

    // Pages through obtained_momo_cloaks rows for a user and marks matching cloaks as obtained.
    func applyingObtainedMomoCloaks(userId: UUID) async -> [MomoCloak] {
        do {
            var allRecords: [ObtainedMomoCloakSlug] = []
            let pageSize = 1000
            var from = 0
            while true {
                let page: [ObtainedMomoCloakSlug] = try await supabase
                    .from("obtained_momo_cloaks")
                    .select("momo_cloak")
                    .eq("user_id", value: userId)
                    .order("id", ascending: true)
                    .range(from: from, to: from + pageSize - 1)
                    .execute()
                    .value
                allRecords.append(contentsOf: page)
                if page.count < pageSize { break }
                from += pageSize
            }

            let obtainedSlugs = Set(allRecords.map { $0.momoCloak })

            return map { cloak in
                cloak.withObtained(obtainedSlugs.contains(cloak.slug))
            }
        } catch {
            print("⚠️ Failed to load obtained data: \(error)")
            return self
        }
    }
}

extension MomoCloak: CardDisplayable {
    var cardImageURL: String? { imageURL }
    var cardTitle: String { title }
    var cardLabel: String { label ?? "" }
    var cardStyle: String { style ?? "" }
    var cardRarity: Int? { rarity }
    var cardObtained: Int { obtained == true ? 1 : 0 }
    var cardTotal: Int { 1 }
    var cardHasUserData: Bool { obtained != nil }
}

extension MomoCloak: DetailDisplayable {
    var detailDescription: String? { description }
    var detailSeasons: String? { seasons }
    var detailSeasonCategory: String? { seasonCategory }
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
