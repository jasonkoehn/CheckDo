//
//  CategoriesListView.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct CategoriesListView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var store: Store
    @State private var showAddCategoryView: Bool = false
    @State private var showSortCategoriesView: Bool = false
    @State private var selectedRow: SelectedCategoryRow? = nil
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.id) { category in
                    NavigationLink(destination: ItemsListView(catId: category.id, name: category.name, color: category.color, hasDueDate: category.hasDueDate, listItems: colorListItems(listItems: category.listItems, color: category.color))) {
                        Text(category.name)
                            .font(.system(size: 23))
                            .foregroundColor(.black)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(decodeColor(color: category.color))
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive, action: {
                            if let idx = store.categories.firstIndex(where: {$0.id == category.id}) {
                                store.categories.remove(at: idx)
                                store.saveArray()
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
                            EditCategoriesView(id: row.id, name: row.name, color: row.color, hasDueDate: row.hasDueDate)
                        }
                        .presentationDetents([.medium, .large])
                    }
                }
                .onMove { indexSet, offset in
                    store.categories.move(fromOffsets: indexSet, toOffset: offset)
                    store.saveArray()
                }
                .onDelete { indexSet in
                    store.categories.remove(atOffsets: indexSet)
                    store.saveArray()
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
                    AddCategoryView()
                }
            }
            .sheet(isPresented: $showSortCategoriesView) {
                NavigationStack {
                    SortCategoriesView()
                }
                .presentationDetents([.medium])
            }
            .task {
                store.loadArray()
            }
        }
    }
    var searchResults: [Category] {
        if searchText.isEmpty {
            return store.categories
        } else {
            return store.categories.filter {$0.name.contains(searchText)}
        }
    }
}
