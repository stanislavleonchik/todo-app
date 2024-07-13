import SwiftUI


struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Binding var brightness: Double
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                ColorSwatch(color: selectedColor)
                Text(selectedColor.toHex() ?? "")
                    .font(.headline)
                    .padding(.leading, 8)
            }
            .padding(.top, 20)
            
            ColorPaletteView(selectedColor: $selectedColor, brightness: $brightness)
                .frame(height: 300)
                .padding()
            
            Slider(value: $brightness, in: 0...1)
                .padding()
            
            Button("Готово") {
                dismiss()
            }
            .padding()
        }
        .navigationTitle("Выберите цвет")
    }
}

struct ColorSwatch: View {
    var color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 50, height: 50)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
    }
}

struct ColorPaletteView: View {
    @Binding var selectedColor: Color
    @Binding var brightness: Double
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Canvas { context, size in
                for x in 0..<Int(width) {
                    for y in 0..<Int(height) {
                        let color = Color(hue: Double(x) / width, saturation: Double(y) / height, brightness: brightness)
                        context.fill(Path(CGRect(x: x, y: y, width: 1, height: 1)), with: .color(color))
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let hue = Double(value.location.x / width)
                        let saturation = Double(value.location.y / height)
                        selectedColor = Color(hue: hue, saturation: saturation, brightness: brightness)
                    }
            )
        }
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return nil
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        return String(format: "#%02lX%02lX%02lX",
                      lround(Double(r * 255)),
                      lround(Double(g * 255)),
                      lround(Double(b * 255)))
    }
}

extension Color {
    init?(hex: String) {
        let r, g, b: CGFloat
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000ff) / 255
            self.init(red: r, green: g, blue: b)
            return
        }
        return nil
    }
}


