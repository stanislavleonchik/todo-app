//
//  ContentView.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

import SwiftUI


final class EventTodolistHolder: ObservableObject {
    @Published var items: [Todoitem] = [
        Todoitem(text: "Helllo", isDone: true),
        Todoitem(text: "Helllo", isDone: false),
        Todoitem(text: "Helllo", importance: .important, isDone: true),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", importance: .important, isDone: false),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", isDone: false),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", deadline: Date(), isDone: false),
        Todoitem(text: "Helllo\nabacaba\nabacaba\nabacaba", importance: .unimportant, isDone: false),
        Todoitem(text: "Купить", importance: .unimportant, deadline: Date(), isDone: false)
    ]
}

struct TodoitemView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var item: Todoitem
    @State private var selectedIcon: Int = 0
    @State private var isDeadlineSet: Bool = false
    private let importanceOptions: [Todoitem.Importance] = [.unimportant, .ordinary, .important]
    
    var body: some View {
        NavigationStack {
            Form {
                textEditor
                Section {
                    List {
                        importanceRow
                        deadlineRow
                        deadlinePicker
                    }
                }
                deleteButton
            }
            .modifier(FormNavigationModifier())
            
        }
    }
    
    struct FormNavigationModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        
                    }.fontWeight(.bold)
                }
            }
        }
    }
    
    var textEditor: some View {
        TextEditor(text: $item.text)
            .font(.custom("SF Pro Text", size: 17))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .leading)
            .textEditorStyle(.automatic)
            .overlay(
                Text(
                    item.text.isEmpty ? "Что надо сделать?" : "")
                .foregroundColor(Color("ColorLabelTertiary"))
                .padding(.top, 5),
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
        
    var deadlineRow: some View {
        Toggle(isOn: $isDeadlineSet, label: {
            HStack(spacing: 25) {
                VStack {
                    Text("Сделать до")
                    if let deadline = $item.wrappedValue.deadline {
                        Text(deadline, style: .date)
                            .font(.custom("SF Pro Text", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                            .padding(.leading, -12)
                    }
                }
            }
        })
        .onChange(of: isDeadlineSet) { oldValue, newValue in
            if !newValue {
                item.deadline = nil
            }
        }
    }
    
    var deadlinePicker: some View {
        Group {
            if isDeadlineSet {
                DatePicker(
                    "Start Date",
                    selection: Binding<Date>(
                        get: { item.deadline ?? Date() },
                        set: { newItem in item.deadline = newItem }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            }
        }
    }
    
    var importancePicker: some View {
        Picker("Select Icon", selection: $selectedIcon) {
            arrowdownImage.tag(0)
            Text("нет").tag(1)
            exclamationMarkImage.tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.leading, 15)
        .onAppear {
            if let currentIndex = importanceOptions.firstIndex(where: { $0 == item.importance }) {
                selectedIcon = currentIndex
            }
        }
        .onChange(of: selectedIcon) { oldValue, newValue in
            item.importance = importanceOptions[newValue]
        }
    }
    
    var deleteButton: some View {
        Section {
            Button("Удалить") {
                dismiss()
            }
            .foregroundStyle(Color("ColorRed"))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
    }
}

struct ContentView: View {
    @StateObject private var todoList = EventTodolistHolder()
    @State private var showModal = false
    @State private var selectedItemIndex: Int = 0
    
    var body: some View {
        VStack {
            todoitemList()
            Spacer()
            addButton
        }
        .background(Color("ColorBackiOSPrimary"))
        .environmentObject(todoList)
    }
    
    func todoitemList() ->some View {
        NavigationStack {
            List {
                ForEach(todoList.items.indices, id: \.self) { index in
                    todoitemRow(item: $todoList.items[index])
                        .background(
                            Button(action: {
                                selectedItemIndex = index
                                showModal = true
                            }) 
                            {
                                Color.clear
                            }
                        )
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                todoList.items.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                            Button {
                                selectedItemIndex = index
                                showModal = true
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            .tint(Color("ColorGrayLight"))
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                todoList.items[index].isDone.toggle()
                            } label: {
                                Image(systemName: "checkmark.circle")
                            }
                            .tint(.green)
                        }
                }
                bodyText(text: "Новое")
                    .foregroundStyle(Color("ColorLabelTertiary"))
                    .padding(.leading, 35)
                    .background(
                        Button(action: {
                            let newItem = Todoitem(text: "", isDone: false)
                            todoList.items.append(newItem)
                            selectedItemIndex = todoList.items.count - 1
                            showModal = true
                        })
                        {
                            Color.clear
                        }
                    )
            }
            .navigationTitle("Мои дела")
        }
        .listRowBackground(Color("ColorBackSecondary"))
        .navigationTitle("Мои дела")
        .popover(isPresented: $showModal) {
            TodoitemView(item: $todoList.items[selectedItemIndex])
                .environmentObject(todoList)
        }
    }
    
    func todoitemRow(item: Binding<Todoitem>) -> some View {
        HStack {
            checkMarkButton(item: item)
                .onTapGesture {
                    item.isDone.wrappedValue.toggle()
                }
            VStack(spacing: 4) {
                todoitemText(item: item)
                if let deadline = item.wrappedValue.deadline { dateText(date: deadline) }
            }
            chevronRightImage
        }
    }
    
    func todoitemText(item: Binding<Todoitem>) -> some View {
        HStack(spacing: 4) {
            Text("")
            switch item.wrappedValue.importance {
            case .unimportant:
                arrowdownImage
            case .important:
                exclamationMarkImage
            case .ordinary:
                EmptyView()
            }
            bodyText(text: item.wrappedValue.text)
        }
    }
    
    var chevronRightImage: some View {
        Image(systemName: "chevron.right")
            .fontWeight(.bold)
            .foregroundStyle(Color("ColorGray"))
            .imageScale(.small)
    }
        
    var addButton: some View {
        Button(
            action: {
                let newItem = Todoitem(text: "", isDone: false)
                todoList.items.append(newItem)
                selectedItemIndex = todoList.items.count - 1
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
    
    func checkMarkButton(item: Binding<Todoitem>) -> some View {
        Image(
            systemName: item.isDone.wrappedValue ? "checkmark.circle.fill" : "circle"
        )
        .foregroundStyle(
            item.wrappedValue.isDone ? .green : item.wrappedValue.importance == .important ? .red : Color("ColorSupportSeparator")
        )
        .background(
            Circle()
                .foregroundStyle(
                    !item.wrappedValue.isDone && item.wrappedValue.importance == .important ? .red.opacity(0.1) : item.wrappedValue.isDone ? .white : .clear)
                .frame(width: 20, height: 20)
        )
        .imageScale(.large)
        .animation(.easeInOut, value: item.wrappedValue.isDone)
    }
    
    func bodyText(text: String) -> some View {
        Text(text)
            .font(.custom("SF Pro Text", size: 17))
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func dateText(date: Date) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Image(systemName: "calendar")
                .foregroundColor(Color("ColorLabelTertiary"))
            Text(date, style: .date)
                .font(.custom("SF Pro Text", size: 15))
                .fontWeight(.light)
                .foregroundStyle(Color("ColorLabelTertiary"))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
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

#Preview {
    ContentView()
}
