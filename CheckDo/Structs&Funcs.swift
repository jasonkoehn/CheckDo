//
//  Structs&Funcs.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct Categories: Codable {
    var id: UUID
    var name: String
    var color: [CGFloat]
    var hasDueDate: Bool
    var listItems: [ListItems]
}

struct ListItems: Codable {
    var id: UUID
    var name: String
    var date: Date
    var hasDueDate: Bool
    var checked: Bool
    var color: [CGFloat]
}

func saveDataArray(dataArray: [Categories]) {
    let manager = FileManager.default
    guard let managerUrl = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
    let encoder = PropertyListEncoder()
    let dataArrayUrl = managerUrl.appendingPathComponent("dataArray.plist")
    manager.createFile(atPath: dataArrayUrl.path, contents: nil, attributes: nil)
    let encodedData = try! encoder.encode(dataArray)
    try! encodedData.write(to: dataArrayUrl)
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

func saveItems(id: UUID, categories: [Categories], listItems: [ListItems]) -> [Categories] {
    var newCategories: [Categories] = categories
    if let idx = newCategories.firstIndex(where: {$0.id == id}) {
        newCategories[idx].listItems = listItems
    }
    return newCategories
}

func colorListItems(listItems: [ListItems], color: [CGFloat]) -> [ListItems] {
    var newListItems: [ListItems] = listItems
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
