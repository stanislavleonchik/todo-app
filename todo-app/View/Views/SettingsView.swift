import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ViewModel
    
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
