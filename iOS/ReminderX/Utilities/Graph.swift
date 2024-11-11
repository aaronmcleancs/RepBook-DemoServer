import SwiftUI

// Sample Graph Data
let exampleGraphData = GraphData(points: [45, 25, 18, 22, 30, 15, 68, 14, 23])

struct GraphData {
    var points: [CGFloat]
    
    var horizontalPadding: CGFloat {
        return (points.max() ?? 0 - (points.min() ?? 0)) * 0.1
    }

    func normalizedPoint(index: Int, frame: CGRect) -> CGPoint {
        let xPosition = (frame.width - horizontalPadding * 2) * CGFloat(index) / CGFloat(points.count - 1) + horizontalPadding
        let yPosition = (1 - (points[index] - minValue) / (maxValue - minValue)) * (frame.height - horizontalPadding * 2) + horizontalPadding
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    private var padding: CGFloat {
        let range = points.max() ?? 0 - (points.min() ?? 0)
        return range * 0.1
    }
    
    var maxValue: CGFloat {
        return (points.max() ?? 0) + padding
    }
    
    var minValue: CGFloat {
        return (points.min() ?? 0) - padding
    }
    
    var peakIndex: Int? { points.indices.max(by: { points[$0] < points[$1] }) }
    var valleyIndex: Int? { points.indices.min(by: { points[$0] < points[$1] }) }
}

struct LabelView: View {
    var text: String
    var position: CGPoint
    var colorScheme: (dark: Color, med: Color, light: Color)
    
    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .fontWeight(.medium)
            .padding(5)
            .background(colorScheme.light)
            .foregroundColor(colorScheme.dark)
            .cornerRadius(5)
            .position(position)
    }
}

struct LineGraph: View {
    var data: GraphData
    var colorScheme: (dark: Color, med: Color, light: Color)
    
    // Separate state variables for line and fill animations
    @State private var graphProgressLine: CGFloat = 0
    @State private var graphProgressFill: CGFloat = 0

    var body: some View {
        ZStack {
            // Gradient fill under the graph line
            GeometryReader { geometry in
                let frame = geometry.frame(in: .local)
                Path { path in
                    let firstPoint = data.normalizedPoint(index: 0, frame: frame)
                    path.move(to: firstPoint)
                    
                    // Draw lines through all data points
                    for index in data.points.indices {
                        let nextPoint = data.normalizedPoint(index: index, frame: frame)
                        path.addLine(to: nextPoint)
                    }
                    
                    // Complete the path to form a closed shape
                    let lastIndex = data.points.count - 1
                    let lastPoint = data.normalizedPoint(index: lastIndex, frame: frame)
                    path.addLine(to: CGPoint(x: lastPoint.x, y: frame.height))
                    path.addLine(to: CGPoint(x: firstPoint.x, y: frame.height))
                    path.closeSubpath()
                }
                .trim(from: 0, to: graphProgressFill)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [colorScheme.light, .white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                // Ensure the fill animation starts after the line animation
                .animation(
                    .easeInOut(duration: 1)
                        .delay(0.5), // Adjust the delay as needed
                    value: graphProgressFill
                )
            }

            // Graph Line
            GeometryReader { geometry in
                Path { path in
                    let firstPoint = data.normalizedPoint(index: 0, frame: geometry.frame(in: .local))
                    path.move(to: firstPoint)
                    
                    // Draw lines through all data points
                    for index in data.points.indices {
                        let nextPoint = data.normalizedPoint(index: index, frame: geometry.frame(in: .local))
                        path.addLine(to: nextPoint)
                    }
                }
                .trim(from: 0, to: graphProgressLine)
                .stroke(
                    colorScheme.light,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
                // Animate the line drawing
                .animation(
                    .easeInOut(duration: 1),
                    value: graphProgressLine
                )
            }

            // Graph Points and Labels
            GraphPoints(data: data, colorScheme: colorScheme, graphProgress: graphProgressLine)
        }
        .clipped()
        .padding(.all, 15)
        .onAppear {
            // Animate the graph line first
            withAnimation(.easeInOut(duration: 0.3)) {
                graphProgressLine = 1
            }
            
            // Animate the gradient fill after a delay
            withAnimation(.easeInOut(duration: 5).delay(5)) {
                graphProgressFill = 1
            }
        }
    }
}

struct CustomGraphCardView: View {
    var currentColorScheme: (dark: Color, med: Color, light: Color)

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Main Title")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(currentColorScheme.med.opacity(0.8))
                
                Text("Subtitle")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.systemGray2))
            }
            .padding(.top)
            
            // Graph
            LineGraph(data: exampleGraphData, colorScheme: currentColorScheme)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.6)
        .padding(.vertical, 0)
    }
}

struct GraphPoints: View {
    var data: GraphData
    var colorScheme: (dark: Color, med: Color, light: Color)
    var graphProgress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ForEach(data.points.indices, id: \.self) { index in
                if CGFloat(index) / CGFloat(data.points.count - 1) <= graphProgress {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(colorScheme.dark)
                        .position(data.normalizedPoint(index: index, frame: geometry.frame(in: .local)))
                }
            }

            // Peak Label
            if let peakIndex = data.peakIndex, CGFloat(peakIndex) / CGFloat(data.points.count - 1) <= graphProgress {
                LabelView(
                    text: "\(Int(data.points[peakIndex]))",
                    position: adjustedLabelPosition(index: peakIndex, frame: geometry.frame(in: .local), geometry: geometry),
                    colorScheme: colorScheme
                )
                .zIndex(1)
            }
            
            // Valley Label
            if let valleyIndex = data.valleyIndex, CGFloat(valleyIndex) / CGFloat(data.points.count - 1) <= graphProgress {
                LabelView(
                    text: "\(Int(data.points[valleyIndex]))",
                    position: adjustedLabelPosition(index: valleyIndex, frame: geometry.frame(in: .local), geometry: geometry),
                    colorScheme: colorScheme
                )
                .zIndex(1)
            }
        }
    }

    private func adjustedLabelPosition(index: Int, frame: CGRect, geometry: GeometryProxy) -> CGPoint {
        var position = data.normalizedPoint(index: index, frame: frame)
        if position.x < 20 { position.x = 30 }
        if position.x > geometry.size.width - 30 { position.x = geometry.size.width - 30 }
        return position
    }
}
