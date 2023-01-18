//
//  CategoriesListDependentViews.swift
//  CheckDo
//
//  Created by Jason Koehn on 1/16/23.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var keyboardFocused: Bool
    @Binding var categories: [Categories]
    @State private var name: String = ""
    @State private var color: [CGFloat] = [0.0, 0.372549019607843, 0.96078431372549, 1.0]
    @State private var hasDueDate: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Name:")
                        .font(.system(size: 20))
                    TextField("", text: $name)
                        .focused($keyboardFocused)
                        .font(.system(size: 20))
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            if name != "" {
                                saveNewCategory()
                            }
                        }
                        .submitLabel(.done)
                }
                .padding(10)
                Toggle(isOn: $hasDueDate) {
                    Text("Preload Due Date?")
                }
                .padding(.horizontal, 10)
                ColorPickerView(selection: $color)
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .all)
        }
        .navigationTitle("Add Category")
        .toolbar {
            if name == "" {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                }
            } else {
                Button(action: {
                    saveNewCategory()
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
    func saveNewCategory() {
        categories.append(Categories(id: UUID(), name: name, color: color, hasDueDate: hasDueDate, listItems: []))
        saveDataArray(dataArray: categories)
        dismiss()
    }
}

struct EditCategoriesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categories: [Categories]
    var id: UUID
    @State var name: String
    @State var color: [CGFloat]
    @State var hasDueDate: Bool
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Name:")
                        .font(.system(size: 20))
                    TextField("", text: $name)
                        .font(.system(size: 20))
                        .textFieldStyle(.roundedBorder)
                }
                .padding(10)
                Toggle(isOn: $hasDueDate) {
                    Text("Preload Due Date?")
                }
                .padding(.horizontal, 10)
                ColorPickerView(selection: $color)
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .all)
        }
        .navigationTitle("Edit Category")
        .toolbar {
            Button(action: {
                if let idx = categories.firstIndex(where: {$0.id == id}) {
                    categories[idx].name = name
                    categories[idx].color = color
                    categories[idx].hasDueDate = hasDueDate
                    saveDataArray(dataArray: categories)
                }
                dismiss()
            }) {
                Text("Save")
            }
        }
    }
}

struct SortCategoriesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categories: [Categories]
    var body: some View {
        List {
            Button(action: {
                categories.sort {
                    $0.name < $1.name
                }
                saveDataArray(dataArray: categories)
                dismiss()
            }) {
                Text("Alphabetically Ascending")
            }
            Button(action: {
                categories.sort {
                    $0.name > $1.name
                }
                saveDataArray(dataArray: categories)
                dismiss()
            }) {
                Text("Alphabetically Descending")
            }
        }
        .navigationTitle("Sort Categories")
        .toolbar {
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
            }
        }
    }
}

struct ColorPickerView: View {
    var colorsArray: [[CGFloat]] = [/*Light Purple*/[0.7690381407737732, 0.3715032637119293, 0.964192807674408, 1.0], /*Purple*/[0.5491169095039368, 0.1990393102169037, 0.7117753028869629, 1.0], /*Indigo*/[0.4955701231956482, 0.31992125511169434, 0.9603580832481384, 1.0], /*Blue*/[0.0, 0.372549019607843, 0.96078431372549, 1.0], /*Cyan*/[0.27905404567718506, 0.6217736601829529, 0.8272541165351868, 1.0], /*Light Green*/[0.5243028998374939, 0.7263622879981995, 0.3240967392921448, 1.0], /*Green*/[0.0, 0.56078431372549, 0.0, 1.0], /*Dark Yellow*/[0.9589917063713074, 0.7886649966239929, 0.2673628330230713, 1.0], /*Orange*/[0.9299656748771667, 0.4523574113845825, 0.18105342984199524, 1.0], /*Red*/[0.9219411611557007, 0.31859707832336426, 0.18143770098686218, 1.0], /*Pink*/[0.6679246425628662, 0.2251381278038025, 0.3653307259082794, 1.0], /*Light Pink*/[0.871661365032196, 0.4708508849143982, 0.6162801384925842, 1.0]]
    @Binding var selection: [CGFloat]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
            ForEach(colorsArray, id: \.self) { color in
                Button(action: {
                    selection = color
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(decodeColor(color: color))
                            .frame(width: 70, height: 70)
                            .padding(5)
                        if selection == color {
                            Image(systemName: "checkmark")
                                .foregroundColor(.primary)
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
    }
}
