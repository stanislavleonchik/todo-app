import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel: ListTodoitemsViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Выполнено — \(viewModel.completedCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Menu {
                Section {
                    Button(action: {
                        viewModel.toggleShowCompleted()
                    }) {
                        Label(viewModel.isShown ? "Показать выполненное" : "Скрыть выполненное", systemImage: "eye")
                    }
                }
                Section {
                    Button(action: {
                        viewModel.sortBy(.addition)
                    }) {
                        Label("Сортировка по добавлению", systemImage: "arrow.up.arrow.down")
                    }
                    Button(action: {
                        viewModel.sortBy(.importance)
                    }) {
                        Label("Сортировка по важности", systemImage: "exclamationmark.circle")
                    }
                }
            } label: {
                Image(systemName: "line.horizontal.3.decrease.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 0)
        .padding(.horizontal, 16)
    }
}

#Preview {
    HeaderView()
        .environmentObject(ListTodoitemsViewModel())
}
