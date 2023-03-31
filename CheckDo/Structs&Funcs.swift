//
//  Structs&Funcs.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct Category: Codable {
    var id: UUID
    var name: String
    var color: [CGFloat]
    var hasDueDate: Bool
    var listItems: [ListItem]
}

struct ListItem: Codable, Equatable {
    var id: UUID
    var name: String
    var date: Date
    var hasDueDate: Bool
    var checked: Bool
    var color: [CGFloat]
}

struct SelectedCategoryRow: Identifiable {
    var id: UUID
    var name: String
    var color: [CGFloat]
    var hasDueDate: Bool
}

struct SelectedItemRow: Identifiable {
    var id: UUID
    var name: String
    var date: Date
    var hasDueDate: Bool
}

func encodeColor(color: Color) -> [CGFloat] {
    let color = UIColor(color).cgColor
    let components = color.components ?? [0.0, 0.372549019607843, 0.96078431372549, 1.0]
    return components
}

func decodeColor(color: [CGFloat]) -> Color {
    let array = color
    let color = Color(red: array[0], green: array[1], blue: array[2], opacity: array[3])
    return color
}

func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd"
    return dateFormatter.string(from: date)
}

func colorListItems(listItems: [ListItem], color: [CGFloat]) -> [ListItem] {
    var newListItems: [ListItem] = listItems
    var color: [CGFloat] = color
    let divider: CGFloat = (0.9 / CGFloat(listItems.count))
    for listItem in listItems {
        if listItems.count > 18 {
            color[3] -= divider
        } else {
            color[3] -= 0.05
        }
        if let idx = newListItems.firstIndex(where: {$0.id == listItem.id}) {
            newListItems[idx].color = color
        }
    }
    return newListItems
}
