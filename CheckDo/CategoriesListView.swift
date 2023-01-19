//
//  CategoriesListView.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct CategoriesListView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var showAddCategoryView: Bool = false
    @State private var showSortCategoriesView: Bool = false
    @State private var selectedRow: SelectedCategoryRow? = nil
    @State var categories: [Categories] = []
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.id) { category in
                    NavigationLink(destination: ItemsListView(categories: $categories, catId: category.id, name: category.name, color: category.color, hasDueDate: category.hasDueDate, listItems: colorListItems(listItems: category.listItems, color: category.color))) {
                        Text(category.name)
                            .font(.system(size: 23))
                            .foregroundColor(.black)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(decodeColor(color: category.color))
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive, action: {
                            if let idx = categories.firstIndex(where: {$0.id == category.id}) {
                                categories.remove(at: idx)
                                saveDataArray(dataArray: categories)
                            }
                        }) {
                            Text("Delete")
                        }
                        Button(action: {
                            selectedRow = SelectedCategoryRow(id: category.id, name: category.name, color: category.color, hasDueDate: category.hasDueDate)
                        }) {
                            Text("Edit")
                        }
                    }
                    .sheet(item: $selectedRow) { row in
                        NavigationStack {
                            EditCategoriesView(categories: $categories, id: row.id, name: row.name, color: row.color, hasDueDate: row.hasDueDate)
                        }
                        .presentationDetents([.medium, .large])
                    }
                }
                .onMove { indexSet, offset in
                    categories.move(fromOffsets: indexSet, toOffset: offset)
                    saveDataArray(dataArray: categories)
                }
                .onDelete { indexSet in
                    categories.remove(atOffsets: indexSet)
                    saveDataArray(dataArray: categories)
                }
            }
            .navigationTitle("Categories")
            .listStyle(PlainListStyle())
            .searchable(text: $searchText)
            .toolbarBackground(Color(red: 0, green: 0.372549019607843, blue: 0.96078431372549), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .environment(\.defaultMinListRowHeight, 60)
            .toolbar {
                Button(action: {
                    showSortCategoriesView.toggle()
                }) {
                    Text("Sort")
                }
                EditButton()
                Button(action: {
                    showAddCategoryView.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddCategoryView) {
                NavigationStack {
                    AddCategoryView(categories: $categories)
                }
            }
            .sheet(isPresented: $showSortCategoriesView) {
                NavigationStack {
                    SortCategoriesView(categories: $categories)
                }
                .presentationDetents([.medium])
            }
            .task {
                let manager = FileManager.default
                let decoder = PropertyListDecoder()
                guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
                let dataArrayUrl = url.appendingPathComponent("dataArray.plist")
                if let data = try? Data(contentsOf: dataArrayUrl) {
                    if let response = try? decoder.decode([Categories].self, from: data) {
                        categories = response
                    }
                }
            }
        }
    }
    var searchResults: [Categories] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter {$0.name.contains(searchText)}
        }
    }
}
