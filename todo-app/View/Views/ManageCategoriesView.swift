import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var newCategoryName: String = ""
    @State private var selectedColor: Color = .white
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Добавить новую категорию")) {
                    TextField("Название категории", text: $newCategoryName)
                    ColorPicker("Цвет категории", selection: $selectedColor)
                    Button("Добавить") {
                        let newCategory = TodoCategory(name: newCategoryName, color: UIColor(selectedColor))
                        viewModel.addCategory(newCategory)
                        newCategoryName = ""
                        selectedColor = .white
                    }
                }
                
                Section(header: Text("Существующие категории")) {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            Circle()
                                .fill(Color(category.color))
                                .frame(width: 20, height: 20)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.removeCategory(viewModel.categories[index])
                        }
                    }
                }
            }
            .navigationTitle("Управление категориями")
        }
    }
}

