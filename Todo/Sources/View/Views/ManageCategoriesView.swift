import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject var viewModel: ListTodoitemsViewModel
    @State private var newCategoryName: String = ""
    @State private var selectedColor: Color = .white
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Добавить новую категорию")) {
                    TextField("Название категории", text: $newCategoryName)
                    ColorPicker("Цвет категории", selection: $selectedColor)
                    Button("Добавить") {
                        let newCategory = TodoCategory(name: newCategoryName, color: selectedColor)
                        if !viewModel.addCategory(newCategory) {
                            errorMessage = "Категория не может быть с пустым названием или с дублирующимся названием"
                            showError = true
                        } else {
                            newCategoryName = ""
                            selectedColor = .white
                        }
                    }
                }
                
                Section(header: Text("Существующие категории")) {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            Circle()
                                .fill(category.color)
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
            .alert(isPresented: $showError) {
                Alert(title: Text("Ошибка"), message: Text(errorMessage), dismissButton: .default(Text("Ок")))
            }
        }
    }
}
