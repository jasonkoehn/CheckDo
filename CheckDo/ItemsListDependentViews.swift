//
//  ItemsListDependentViews.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct ItemsListRowView: View {
    var id: UUID
    var name: String
    var date: Date
    var hasDueDate: Bool
    @State var checked: Bool
    @State var listItems: [ListItems]
    @Binding var categories: [Categories]
    var catId: UUID
    var body: some View {
        HStack {
            Button(action: {
                checked.toggle()
                if let idx = listItems.firstIndex(where: {$0.id == id}) {
                    listItems[idx].checked = checked
                }
                categories = saveItems(id: catId, categories: categories, listItems: listItems)
            }) {
                if checked {
                    Image(systemName: "checkmark.square")
                        .font(.system(size: 23))
                } else {
                    Image(systemName: "square")
                        .font(.system(size: 23))
                }
            }
            Text(name)
                .strikethrough(checked)
            Spacer()
            if hasDueDate {
                Text(formatDate(date: date))
            }
        }
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var keyboardFocused: Bool
    @Binding var categories: [Categories]
    var id: UUID
    var color: [CGFloat]
    @Binding var listItems: [ListItems]
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State var hasDueDate: Bool
    var body: some View {
        List {
            HStack {
                Text("Name:")
                TextField("", text: $name)
                    .focused($keyboardFocused)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        if name != "" {
                            saveNewItem()
                        }
                    }
                    .submitLabel(.done)
            }
            Toggle(isOn: $hasDueDate) {
                Text("Due Date?")
            }
            if hasDueDate {
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Due Date:")
                }
            }
        }
        .navigationTitle("Add Item")
        .listStyle(.inset)
        .toolbar {
            if name == "" {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                }
            } else {
                Button(action: {
                    saveNewItem()
                }) {
                    Text("Save")
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                keyboardFocused.toggle()
            }
        }
    }
    func saveNewItem() {
        listItems.append(ListItems(id: UUID(), name: name, date: date, hasDueDate: hasDueDate, checked: false, color: []))
        listItems = colorListItems(listItems: listItems, color: color)
        categories = saveItems(id: id, categories: categories, listItems: listItems)
        dismiss()
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var keyboardFocused: Bool
    @Binding var categories: [Categories]
    var catId: UUID
    @Binding var listItems: [ListItems]
    var id: UUID
    @State var name: String
    @State var date: Date
    @State var hasDueDate: Bool
    var body: some View {
        List {
            HStack {
                Text("Name:")
                TextField("", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            Toggle(isOn: $hasDueDate) {
                Text("Due Date?")
            }
            if hasDueDate {
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Due Date:")
                }
            }
        }
        .navigationTitle("Edit Item")
        .listStyle(.inset)
        .toolbar {
            Button(action: {
                if let idx = listItems.firstIndex(where: {$0.id == id}) {
                    listItems[idx].name = name
                    listItems[idx].date = date
                    listItems[idx].hasDueDate = hasDueDate
                }
                categories = saveItems(id: catId, categories: categories, listItems: listItems)
                dismiss()
            }) {
                Text("Save")
            }
        }
    }
}

struct SortItemsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categories: [Categories]
    var id: UUID
    var color: [CGFloat]
    @Binding var listItems: [ListItems]
    var body: some View {
        List {
            Button(action: {
                listItems.sort {
                    $0.name < $1.name
                }
                saveSortedListItems()
            }) {
                Text("Alphabetically Ascending")
            }
            Button(action: {
                listItems.sort {
                    $0.name > $1.name
                }
                saveSortedListItems()
            }) {
                Text("Alphabetically Descending")
            }
            Button(action: {
                listItems.sort {
                    $0.date < $1.date
                }
                saveSortedListItems()
            }) {
                Text("By Due Date Ascending")
            }
            Button(action: {
                listItems.sort {
                    $0.date > $1.date
                }
                saveSortedListItems()
            }) {
                Text("By Due Date Descending")
            }
        }
        .navigationTitle("Sort Items")
        .toolbar {
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
            }
        }
    }
    func saveSortedListItems() {
        listItems = colorListItems(listItems: listItems, color: color)
        categories = saveItems(id: id, categories: categories, listItems: listItems)
        dismiss()
    }
}
