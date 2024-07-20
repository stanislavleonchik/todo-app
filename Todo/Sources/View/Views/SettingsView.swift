import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ListTodoitemsViewModel
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ManageCategoriesView()) {
                    Text("Управление категориями")
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
