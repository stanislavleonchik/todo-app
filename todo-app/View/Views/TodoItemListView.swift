import SwiftUI

struct TodoItemListView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var selectedItem: Todoitem?
    @Binding var showModal: Bool

    var body: some View {
        List(viewModel.filteredSortedItems + [Todoitem(text: "Новое", isDone: false)]) { item in
            if item.text != "Новое" {
                TodoitemRowView(item: item) {
                    viewModel.toggleItem(item.id)
                }
                .onTapGesture {
                    selectedItem = item
                    showModal = true
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.removeItem(item.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                    Button {
                        selectedItem = item
                        showModal = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .tint(Color("ColorGrayLight"))
                }
                .swipeActions(edge: .leading) {
                    Button {
                        viewModel.toggleItem(item.id)
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .tint(.green)
                }
            } else {
                Text("Новое")
                    .foregroundStyle(Color("ColorLabelTertiary"))
                    .padding(.leading, 35)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let newItem = Todoitem(text: "", isDone: false)
                        viewModel.addItem(newItem)
                        selectedItem = newItem
                        showModal = true
                    }
                    .sheet(item: $selectedItem) { item in
                        TodoitemDetailView(item: item).environmentObject(viewModel)
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    TodoItemListView(selectedItem: .constant(nil), showModal: .constant(false))
        .environmentObject(ViewModel())
}
