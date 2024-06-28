//
//  ContentView.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

import SwiftUI


final class ViewModel: ObservableObject {
    @Published var todoitems: [String: Todoitem] = [:]

    var data = [Todoitem(text: "Helllo", isDone: true),
    Todoitem(text: "Helllo", isDone: false),
    Todoitem(text: "Helllo", importance: .important, isDone: true),
    Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", importance: .important, isDone: false),
    Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", isDone: false),
    Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", deadline: Date(), isDone: false),
    Todoitem(text: "Helllo\nabacaba\nabacaba\nabacaba", importance: .unimportant, isDone: false),
    Todoitem(text: "Купить", importance: .unimportant, deadline: Date(), isDone: false)]
    
    init() {
        for i in data {
            todoitems[i.id] = i
        }
    }
    
    var items: [Todoitem] {
        return Array(todoitems.values)
    }
    
    func addItem(_ item: Todoitem) {
        todoitems[item.id] = item
    }
    
    func removeItem(_ id: String) {
        todoitems[id] = nil
    }
    
    func updateItem(_ id: String, _ item: Todoitem) {
        todoitems[id] = item
    }
    
    var isShown: Bool = false
    
    func filtredItems() -> [Todoitem] {
        isShown ? items.filter{ $0.isDone == false } : items
    }
}

struct TodoitemDetailView: View {
    var item: Todoitem
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ViewModel
    @State private var localItem: Todoitem
    @State private var selectedIcon: Int
    @State private var isDeadlineSet: Bool
    private let importanceOptions: [Todoitem.Importance] = [.unimportant, .ordinary, .important]
    
    init(item: Todoitem, index: Int) {
        self.item = item
        self._localItem = State(initialValue: item)
        self._selectedIcon = State(initialValue: importanceOptions.firstIndex(where: { $0 == item.importance }) ?? 1)
        self._isDeadlineSet = State(initialValue: item.deadline != nil)
    }
    
    var body: some View {
        Form {
            textEditor
            Section {
                List {
                    importanceRow
                    DeadlineView
                    deadlinePicker
                }
            }
            deleteButton
        }
        .modifier(FormNavigationModifier(
            saveAction: itemSave,
            cancelAction: itemCancel
        ))
        .onAppear {
            
            isDeadlineSet = localItem.deadline != nil
        }
    }
    
    private func itemSave() {
        viewModel.updateItem(item.id, localItem)
        dismiss()
    }
    
    private func itemCancel() {
        dismiss()
    }
    
    var deleteButton: some View {
        Section {
            Button("Удалить") {
                viewModel.removeItem(item.id)
                dismiss()
            }
            .foregroundStyle(Color("ColorRed"))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
    }
    
    struct FormNavigationModifier: ViewModifier {
        let saveAction: () -> Void
        let cancelAction: () -> Void
        
        func body(content: Content) -> some View {
            content
                .navigationTitle("Дело")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отменить") {
                            cancelAction()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Сохранить") {
                            saveAction()
                        }
                        .fontWeight(.bold)
                    }
                }
        }
    }
    
    var textEditor: some View {
        TextEditor(text: $localItem.text)
            .font(.custom("SF Pro Text", size: 17))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .leading)
            .textEditorStyle(.automatic)
            .overlay(
                Text(localItem.text.isEmpty ? "Что надо сделать?" : "")
                    .foregroundColor(Color("ColorLabelTertiary"))
                    .padding(.leading, 6)
                    .padding(.top, 8),
                alignment: .topLeading
            )
    }
    
    var importanceRow: some View {
        HStack(spacing: 25) {
            Text("Важность")
            Spacer()
            importancePicker
        }
    }
    
    var importancePicker: some View {
        Picker("Select Icon", selection: $selectedIcon) {
            arrowdownImage.tag(0)
            Text("нет").tag(1)
            Image("Exclamationmark.2").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.leading, 15)
        .onChange(of: selectedIcon) { oldValue, newValue in
            localItem.importance = importanceOptions[newValue]
        }
    }
    
    var DeadlineView: some View {
        Toggle(isOn: $isDeadlineSet, label: {
            HStack(spacing: 25) {
                VStack {
                    Text("Сделать до")
                    DeadlineDateView
                }
            }
        })
        .onChange(of: isDeadlineSet) { oldValue, newValue in
            if !newValue {
                localItem.deadline = nil
            }
            
        }
    }
    
    var DeadlineDateView: some View {
        Group {
            if isDeadlineSet {
                if let deadlineView = localItem.deadline {
                    Text(deadlineView, style: .date)
                        .font(.custom("SF Pro Text", size: 13))
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                        .padding(.leading, -12)
                }
            }
        }
    }
    
    var deadlinePicker: some View {
        Group {
            if isDeadlineSet {
                DatePicker(
                    "Start Date",
                    selection: Binding<Date>(
                        get: { localItem.deadline ?? Date(timeIntervalSinceNow: 86400) },
                        set: { newItem in localItem.deadline = newItem }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .onAppear {
                    localItem.deadline = Date(timeIntervalSinceNow: 86400)
                }
            }
        }
    }
    
    var arrowdownImage: some View {
        Image(systemName: "arrow.down")
            .fontWeight(.bold)
            .foregroundStyle(Color("ColorGray"))
            .imageScale(.small)
    }
}


struct TodoitemRowView: View {
    let item: Todoitem
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            CheckMarkImage
                .onTapGesture {
                    onTap()
                }
            VStack(spacing: 4) {
                todoitemText
                if let deadline = item.deadline {
                    DeadlineView(deadline: deadline)
                }
            }
            chevronRightImage
        }
        .contentShape(Rectangle())
    }
    
    var CheckMarkImage: some View {
        Image(
            systemName: item.isDone ? "checkmark.circle.fill" : "circle"
        )
        .foregroundStyle(
            item.isDone ? .green : item.importance == .important ? .red : Color("ColorSupportSeparator")
        )
        .background(
            Circle()
                .foregroundStyle(
                    !item.isDone && item.importance == .important ? .red.opacity(0.1) : item.isDone ? .white : .clear)
                .frame(width: 20, height: 20)
        )
        .imageScale(.large)
        .animation(.easeInOut, value: item.isDone)
    }
    
    var todoitemText: some View {
        HStack(spacing: 4) {
            Text("")
            switch item.importance {
            case .unimportant:
                arrowdownImage
            case .important:
                exclamationMarkImage
            case .ordinary:
                EmptyView()
            }
            bodyText
        }
    }
    
    var chevronRightImage: some View {
        Image(systemName: "chevron.right")
            .fontWeight(.bold)
            .foregroundStyle(Color("ColorGray"))
            .imageScale(.small)
    }
    
    var arrowdownImage: some View {
        Image(systemName: "arrow.down")
            .fontWeight(.bold)
            .foregroundStyle(Color("ColorGray"))
            .imageScale(.small)
    }
    
    var exclamationMarkImage: some View {
        Image(systemName: "exclamationmark.2")
            .fontWeight(.bold)
            .foregroundStyle(.red)
            .imageScale(.medium)
    }
    
    struct DeadlineView: View {
        let deadline: Date
        
        var body: some View {
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "calendar")
                    .foregroundColor(Color("ColorLabelTertiary"))
                Text(deadline, style: .date)
                    .font(.custom("SF Pro Text", size: 15))
                    .fontWeight(.light)
                    .foregroundStyle(Color("ColorLabelTertiary"))
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    var bodyText: some View {
        Text(item.text)
            .font(.custom("SF Pro Text", size: 17))
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(item.isDone ? .gray : .primary)
            .strikethrough(item.isDone)
    }
}

struct TodoView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var showModal = false
    @State private var selectedItem: Todoitem?
    @State private var selectedIndex: Int?
    var selectedItemIndex: Int?
    // TODO: rename ConentView, separate logic to files
    // TODO: вычисляемое свойство отфильтрованных
    var body: some View {
        VStack {
            todoitemNavigationStack
            Spacer()
            addButton
        }
        .background(Color("ColorBackiOSPrimary"))
        .environmentObject(viewModel)
    }
    
    var todoitemNavigationStack: some View {
        NavigationStack {
            List {
                ForEach(Array(viewModel.filtredItems().enumerated()), id: \.offset) { index, item in
                    TodoitemRowView(item: item) {
                        viewModel.updateItem(item.id, Todoitem(id: item.id, text: item.text, isDone: !item.isDone))
                        selectedIndex = index
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
                            showModal = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .tint(Color("ColorGrayLight"))
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.updateItem(item.id, Todoitem(id: item.id, text: item.text, isDone: !item.isDone))
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
                            TodoitemDetailView(item: item, index: selectedIndex ?? 0)
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
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
            }
        )
        .padding(10)
        .background(Color("ColorBlue"))
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.3), radius: 8)
        .font(.system(size: 14))
        .foregroundStyle(.white)
    }
}

#Preview {
    TodoView()
}
