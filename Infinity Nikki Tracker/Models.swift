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
