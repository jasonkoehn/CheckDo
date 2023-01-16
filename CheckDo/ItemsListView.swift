//
//  ItemsListView.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct ItemsListView: View {
    @State private var showAddItemView: Bool = false
    @State private var showSortItemsView: Bool = false
    @State private var showEditItemView: Bool = false
    @Binding var categories: [Categories]
    var id: UUID
    var name: String
    var color: [CGFloat]
    var hasDueDate: Bool
    @State var listItems: [ListItems]
    @State private var searchText: String = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.id) { listItem in
                    ItemsListRowView(id: listItem.id, name: listItem.name, date: listItem.date, hasDueDate: listItem.hasDueDate, checked: listItem.checked, listItems: listItems, categories: $categories, catId: id)
                        .listRowSeparator(.hidden)
                        .listRowBackground(decodeColor(color: listItem.color))
                        .swipeActions {
                            Button(role: .destructive, action: {
                                if let idx = listItems.firstIndex(where: {$0.id == listItem.id}) {
                                    listItems.remove(at: idx)
                                    listItems = colorListItems(listItems: listItems, color: color)
                                    categories = saveItems(id: id, categories: categories, listItems: listItems)
                                }
                            }) {
                                Text("Delete")
                            }
                            Button(action: {
                                showEditItemView.toggle()
                            }) {
                                Text("Edit")
                            }
                        }
                        .sheet(isPresented: $showEditItemView) {
                            NavigationStack {
                                EditItemView(categories: $categories, catId: id, listItems: $listItems, id: listItem.id, name: listItem.name, date: listItem.date, hasDueDate: listItem.hasDueDate)
                            }
                            .presentationDetents([.medium, .large])
                        }
                }
                .onMove { indexSet, offset in
                    listItems.move(fromOffsets: indexSet, toOffset: offset)
                    listItems = colorListItems(listItems: listItems, color: color)
                    categories = saveItems(id: id, categories: categories, listItems: listItems)
                }
                .onDelete { indexSet in
                    listItems.remove(atOffsets: indexSet)
                    listItems = colorListItems(listItems: listItems, color: color)
                    categories = saveItems(id: id, categories: categories, listItems: listItems)
                }
            }
            .navigationTitle(name)
            .listStyle(PlainListStyle())
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbarBackground(decodeColor(color: color), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                Button(action: {
                    showSortItemsView.toggle()
                }) {
                    Text("Sort")
                }
                EditButton()
                Button(action: {
                    showAddItemView.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddItemView) {
                NavigationStack {
                    AddItemView(categories: $categories, id: id, color: color, listItems: $listItems, hasDueDate: hasDueDate)
                }
            }
            .sheet(isPresented: $showSortItemsView) {
                NavigationStack {
                    SortItemsView(categories: $categories, id: id, color: color, listItems: $listItems)
                }
                .presentationDetents([.medium])
            }
        }
    }
    var searchResults: [ListItems] {
        if searchText.isEmpty {
            return listItems
        } else {
            return listItems.filter {$0.name.contains(searchText)}
        }
    }
}
