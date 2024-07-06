import SwiftUI

struct AddButton: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showModal = false
    @State private var newItem: Todoitem?

    var body: some View {
        Button(action: {
            let newItem = Todoitem(text: "", isDone: false)
            viewModel.addItem(newItem)
            self.newItem = newItem
            showModal = true
        }) {
            Image(systemName: "plus")
                .font(.title)
                .fontWeight(.bold)
                .padding(10)
                .background(Color("ColorBlue"))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 8)
                .foregroundStyle(.white)
        }
        .sheet(isPresented: $showModal) {
            if let newItem = newItem {
                TodoitemDetailView(item: newItem).environmentObject(viewModel)
            }
        }
    }
}
