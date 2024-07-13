import SwiftUI
import FileCacheUnit

struct TodoView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var showModal = false
    @State private var showCalendar = false
    @State private var showSettings = false
    @State private var selectedItem: Todoitem?
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                    .environmentObject(viewModel)
                TodoItemListView(selectedItem: $selectedItem, showModal: $showModal)
                    .environmentObject(viewModel)
                Spacer()
                AddButton(viewModel: viewModel)
            }
            .background(.colorBackiOSPrimary)
            .listRowBackground(Color("ColorBackSecondary"))
            .navigationTitle("Мои дела")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showCalendar = true
                        }) {
                            Image(systemName: "calendar")
                        }
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCalendar) {
                CalendarViewControllerWrapper(selectedItem: $selectedItem, showModal: $showModal).environmentObject(viewModel)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(viewModel)
            }
        }
    }
}
