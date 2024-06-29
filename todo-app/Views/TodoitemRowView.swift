//
//  TodoitemRowView.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 29.06.2024.
//

import SwiftUI


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
            if let colorHex = item.color, let color = Color(hex: colorHex) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 5)
            }
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
