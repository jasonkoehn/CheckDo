//
//  Store.swift
//  CheckDo
//
//  Created by Jason Koehn on 3/30/23.
//

import Foundation

class Store: ObservableObject {
    @Published var categories: [Category] = []
    
    func saveArray() {
        let manager = FileManager.default
        guard let managerUrl = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let encoder = PropertyListEncoder()
        let dataArrayUrl = managerUrl.appendingPathComponent("dataArray.plist")
        manager.createFile(atPath: dataArrayUrl.path, contents: nil, attributes: nil)
        let encodedData = try! encoder.encode(categories)
        try! encodedData.write(to: dataArrayUrl)
    }
    
    func loadArray() {
        let manager = FileManager.default
        let decoder = PropertyListDecoder()
        guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let dataArrayUrl = url.appendingPathComponent("dataArray.plist")
        if let data = try? Data(contentsOf: dataArrayUrl) {
            if let response = try? decoder.decode([Category].self, from: data) {
                categories = response
            }
        }
    }
    
    func saveItems(id: UUID, listItems: [ListItem]) {
        if let idx = categories.firstIndex(where: {$0.id == id}) {
            categories[idx].listItems = listItems
        }
        saveArray()
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

}
