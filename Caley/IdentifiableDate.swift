//
//  IdentifiableDate.swift
//  Caley
//
//  Created by Rigels H on 2024-09-05.
//

import Foundation

// Add this at the top of CalendarView.swift
struct IdentifiableDate: Identifiable {
    let id = UUID() // This makes each instance unique
    let date: Date
}
