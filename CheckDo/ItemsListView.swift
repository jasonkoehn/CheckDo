//
//  ItemsListView.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct ItemsListView: View {
    @EnvironmentObject var store: Store
    @State private var showAddItemView: Bool = false
    @State private var showSortItemsView: Bool = false
    @State private var showEditItemView: Bool = false
    @State private var selectedRow: SelectedItemRow? = nil
    var catId: UUID
    var name: String
    var color: [CGFloat]
    var hasDueDate: Bool
    @State var listItems: [ListItem]
    @State private var searchText: String = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.id) { listItem in
                    ItemsListRowView(id: listItem.id, name: listItem.name, date: listItem.date, hasDueDate: listItem.hasDueDate, checked: listItem.checked, listItems: $listItems, catId: catId, color: color)
                        .listRowSeparator(.hidden)
                        .listRowBackground(decodeColor(color: listItem.color))
                        .swipeActions {
                            Button(role: .destructive, action: {
                                if let idx = listItems.firstIndex(where: {$0.id == listItem.id}) {
                                    listItems.remove(at: idx)
                                    listItems = colorListItems(listItems: listItems, color: color)
                                    store.saveItems(id: catId, listItems: listItems)
                                }
                            }) {
                                Text("Delete")
                            }
                            Button(action: {
                                selectedRow = SelectedItemRow(id: listItem.id, name: listItem.name, date: listItem.date, hasDueDate: listItem.hasDueDate)
                            }) {
                                Text("Edit")
                            }
                        }
                        .sheet(item: $selectedRow) { row in
                            NavigationStack {
                                EditItemView(catId: catId, listItems: $listItems, id: row.id, name: row.name, date: row.date, hasDueDate: row.hasDueDate)
                            }
                            .presentationDetents([.medium, .large])
                        }
                }
                .onMove { indexSet, offset in
                    listItems.move(fromOffsets: indexSet, toOffset: offset)
                    listItems = colorListItems(listItems: listItems, color: color)
                    store.saveItems(id: catId, listItems: listItems)
                }
                .onDelete { indexSet in
                    listItems.remove(atOffsets: indexSet)
                    listItems = colorListItems(listItems: listItems, color: color)
                    store.saveItems(id: catId, listItems: listItems)
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
                    AddItemView(catId: catId, color: color, listItems: $listItems, hasDueDate: hasDueDate)
                }
            }
            .sheet(isPresented: $showSortItemsView) {
                NavigationStack {
                    SortItemsView(catId: catId, color: color, listItems: $listItems)
                }
                .presentationDetents([.medium])
            }
        }
    }
    var searchResults: [ListItem] {
        if searchText.isEmpty {
            return listItems
        } else {
            return colorListItems(listItems: listItems.filter {$0.name.contains(searchText)}, color: color)
        }
    }
}
