//
//  CheckDoApp.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

@main
struct CheckDoApp: App {
    @StateObject var store = Store()
    var body: some Scene {
        WindowGroup {
            CategoriesListView()
                .environmentObject(store)
        }
    }
}
