//
//  Supabase.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/28/26.
//

import Foundation
import Supabase

// MARK: - Supabase Client

let supabase = SupabaseClient(
    supabaseURL: URL(string: Secrets.supabaseURL)!,
    supabaseKey: Secrets.supabaseAnonKey
)
