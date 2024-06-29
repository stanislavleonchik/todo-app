//
//  ContentView.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

import SwiftUI


struct TodoView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var showModal = false
    @State private var selectedItem: Todoitem?
    var selectedItemIndex: Int?
    
    var body: some View {
        VStack {
            NavigationStack {
                todoitemNavigationStack
            }
            Spacer()
            addButton
        }
        .background(Color("ColorBackiOSPrimary"))
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    private func headerView() -> some View {
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
        .padding(.vertical, 8)
    }
    
    var todoitemNavigationStack: some View {
        List {
            Section(header: headerView()) {
                ForEach(viewModel.filteredSortedItems) { item in
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
                }
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
                    .navigationTitle("Мои дела")
                    .listRowBackground(Color("ColorBackSecondary"))
                    .navigationTitle("Мои дела")
                    .popover(item: $selectedItem) { item in
                        NavigationStack {
                            TodoitemDetailView(item: item)
                        }
                    }
            }
        }
    }
    
    var addButton: some View {
        Button(
            action: {
                let newItem = Todoitem(text: "", isDone: false)
                viewModel.addItem(newItem)
                selectedItem = newItem
                showModal = true
            },
            label: {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.bold)
            }
        )
        .padding(10)
        .background(Color("ColorBlue"))
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.3), radius: 8)
        .foregroundStyle(.white)
    }
}

#Preview {
    TodoView()
}
