import SwiftUI
import FileCacheUnit

struct TodoitemDetailView: View {
    @EnvironmentObject var viewModel: ListTodoitemsViewModel
    var item: Todoitem
    var isNew: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var localItem: Todoitem
    @State private var selectedIcon: Int
    @State private var isDeadlineSet: Bool
    @State private var isDatePickerVisible = false
    @State private var isEditingText = false
    @State private var selectedColor: Color = .white
    @State private var brightness: Double = 1.0
    @State private var selectedCategory: TodoCategory
    private let importanceOptions: [Importance] = [.low, .basic, .important]
    
    init(item: Todoitem, isNew: Bool = false) {
        self.item = item
        self.isNew = isNew
        self._localItem = State(initialValue: item)
        self._selectedIcon = State(initialValue: importanceOptions.firstIndex(where: { $0 == item.importance }) ?? 1)
        self._isDeadlineSet = State(initialValue: item.deadline != nil)
        if let colorHex = item.color {
            self._selectedColor = State(initialValue: Color(hex: colorHex) ?? .clear)
        }
        self._selectedCategory = State(initialValue: item.category ?? .other)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                Form {
                    if horizontalSizeClass == .regular {
                        HStack {
                            textEditor
                                .frame(width: geometry.size.width / 2)
                            VStack {
                                importanceRow
                                categoryPicker
                                colorPickerLink
                                DeadlineView
                                deadlinePicker
                                Spacer()
                            }
                            .frame(width: geometry.size.width / 2)
                        }
                    } else {
                        textEditor
                        Section {
                            List {
                                importanceRow
                                categoryPicker
                                colorPickerLink
                                DeadlineView
                                deadlinePicker
                            }
                        }
                    }
                    if !isNew {
                        deleteButton
                    }
                }
                .modifier(FormNavigationModifier(
                    saveAction: itemSave,
                    cancelAction: itemCancel
                ))
                .onAppear {
                    isDeadlineSet = localItem.deadline != nil
                }
            }
        }
    }
    
    private func itemSave() {
        localItem.color = selectedColor.toHex()
        localItem.category = selectedCategory
        if isNew {
            viewModel.addItem(localItem)
        } else {
            viewModel.updateItem(item.id, localItem)
        }
        viewModel.syncWithServer()
        dismiss()
    }
    
    private func itemCancel() {
        dismiss()
    }
    
    var deleteButton: some View {
        Section {
            Button("Удалить") {
                viewModel.removeItem(item.id)
                viewModel.syncWithServer()
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
        Toggle(isOn: $isDeadlineSet) {
            HStack(spacing: 25) {
                VStack {
                    Text("Сделать до")
                    DeadlineDateView
                        .onTapGesture {
                            withAnimation {
                                isDatePickerVisible.toggle()
                            }
                        }
                }
            }
        }
        .onChange(of: isDeadlineSet) { oldValue, newValue in
            withAnimation {
                if newValue {
                    localItem.deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                } else {
                    localItem.deadline = nil
                    isDatePickerVisible = false
                }
            }
        }
    }
    
    var DeadlineDateView: some View {
        Group {
            if isDeadlineSet, let deadlineView = localItem.deadline {
                Text(deadlineView, style: .date)
                    .font(.custom("SF Pro Text", size: 13))
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                    .padding(.leading, -10)
            }
        }
    }
    
    var deadlinePicker: some View {
        Group {
            if isDeadlineSet && isDatePickerVisible {
                DatePicker(
                    "Выберите дату",
                    selection: Binding<Date>(
                        get: { localItem.deadline ?? Date(timeIntervalSinceNow: 86400) },
                        set: { newItem in
                            localItem.deadline = newItem
                            isDatePickerVisible = false
                        }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: isDatePickerVisible)
            }
        }
    }
    
    var arrowdownImage: some View {
        Image(systemName: "arrow.down")
            .fontWeight(.bold)
            .foregroundStyle(Color("ColorGray"))
            .imageScale(.small)
    }
    
    var colorPickerLink: some View {
        NavigationLink(destination: ColorPickerView(selectedColor: $selectedColor, brightness: $brightness)) {
            HStack {
                Text("Цвет")
                Spacer()
                ColorSwatch(color: selectedColor)
            }
        }
    }
    
    var categoryPicker: some View {
        HStack {
            Text("Категория")
            Spacer()
            Picker("Категория", selection: $selectedCategory) {
                ForEach(viewModel.categories) { category in
                    Text(category.name).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}
