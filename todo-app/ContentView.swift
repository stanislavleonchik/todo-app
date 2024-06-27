//
//  ContentView.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

import SwiftUI

struct TodoItemView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Учиха Мадара-сан") {
            dismiss()
        }
    }
}


struct ContentView: View {
    @State private var items: [TodoItem] = [
        TodoItem(text: "Helllo", isDone: true),
        TodoItem(text: "Helllo", isDone: false),
        TodoItem(text: "Helllo", importance: .important, isDone: true),
        TodoItem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", importance: .important, isDone: false),
        TodoItem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", isDone: false),
        TodoItem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", deadline: Date(), isDone: false),
        TodoItem(text: "Helllo\nabacaba\nabacaba\nabacaba", importance: .unimportant, isDone: false),
        TodoItem(text: "Купить", importance: .unimportant, deadline: Date(), isDone: false),
    ]
    
    @State private var showModal = false
    
    var body: some View {
        VStack {
            todoitemList()
            Spacer()
            addButton
        }
        .background(Color("ColorBackiOSPrimary"))
    }
    
    func todoitemList() ->some View {
        NavigationStack {
            List {
                ForEach($items) { item in
                    todoitemRow(item: item)
                        .onTapGesture {
                            showModal = true
                        }
                }
                bodyText(text: "Новое")
                    .foregroundStyle(Color("ColorLabelTertiary"))
                    .padding(.leading, 35)
                    .onTapGesture {
                        showModal = true
                    }
            }
            .navigationTitle("Мои дела")
        }
        .listRowBackground(Color("ColorBackSecondary"))
        .navigationTitle("Мои дела")
        .popover(isPresented: $showModal) {
            TodoItemView()
        }
    }
    
    func todoitemRow(item: Binding<TodoItem>) -> some View {
        HStack {
            checkMarkButton(item: item) // передавать по ссылке? передавать отдельно параметры?
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
    
    func todoitemText(item: Binding<TodoItem>) -> some View {
        HStack(/*alignment: .top, */spacing: 4) {
            Text("") // костыль чтобы полосочка оставалась под воскл. знаками
            switch item.wrappedValue.importance {
            case .unimportant:
                arrowdownRightImage
            case .important:
                exclamationMarkImage
            case .ordinary:
                EmptyView()
            }
            bodyText(text: item.wrappedValue.text)
        }
    }
    
    var exclamationMarkImage: some View {
        Image(systemName: "exclamationmark.2")
            .fontWeight(.bold)
            .foregroundColor(.red)
            .imageScale(/*@START_MENU_TOKEN@*/.medium/*@END_MENU_TOKEN@*/)
    }
    
    var arrowdownRightImage: some View {
        Image(systemName: "arrow.down")
            .fontWeight(.bold)
            .foregroundStyle(Color("ColorGray"))
            .imageScale(.small)
    }
    
    var chevronRightImage: some View {
        Image(systemName: "chevron.right")
            .fontWeight(.bold)
            .foregroundStyle(Color("ColorGray"))
            .imageScale(.small)
    }
    
    func checkMarkButton(item: Binding<TodoItem>) -> some View {
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
    
    var addButton: some View {
        Button(
            action: {
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

#Preview {
    ContentView()
}
