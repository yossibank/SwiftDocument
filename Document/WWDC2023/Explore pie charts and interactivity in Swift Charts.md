# Explore pie charts and interactivity in Swift Charts

## Pie charts

* **円グラフの生成**

``` swift
// 棒グラフ
Chart(data, id: \.name) { element in
    BarMark(
        x: .value("Sales", element.sales),
        stacking: .normalized
    )
    .foregroundStyle(by: .value("Name", element.name))
}
.chartXAxis(.hidden)

// 円グラフ
Chart(data, id: \.namea) { element in
    SectorMark(
        angle: .value("Sales", element.sales),
        innerRadius: .ratio(0.618), // 内側に円の作成
        angularInset: 1.5 // セクター間の余白
    )
    .cornerRadius(5)
    .foregroundStyle(by: .value("Name", element.name))
}

// 円グラフ(内側の円にテキスト挿入)
Chart(data, id: \.namea) { element in
    SectorMark(
        angle: .value("Sales", element.sales),
        innerRadius: .ratio(0.618), // 内側に円の作成
        angularInset: 1.5 // セクター間の余白
    )
    .cornerRadius(5)
    .foregroundStyle(by: .value("Name", element.name))
}
.chartBackground { chartProxy in
    GeometryReader { geometry in
        let frame = geometry[chartProxy.plotAreaFrame]

        VStack {
            Text("Most Sold Style")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(mostSold)
                .font(.title2.bold())
                .foregroundColor(.primary)
        }
        .position(x: frame.midX, y: frame.midY)
    }
}
```

<img src="../../Image/WWDC2023/Explore_pie_charts and_interactivity_in_Swift_Charts.png" width=50%>

## Selection

* **チャートのインタラクティブ性**

``` swift
// 線グラフ(選択した情報を表示する)
struct LocationDetailsChart: View {
    @Binding var rawSelectedDate: Date?

    var selectedDate: Date? { ... }

    var body: some View {
        Chart {
            ForEach(data) { series in
                ForEach(series.sales, id: \.day) { element in
                    LineMark(
                        x: .value("Day", element.day, unit: .day),
                        y: .value("Sales", element.sales)
                    )
                }
                .foregroundStyle(by: .value("City", series.city))
                .symbol(by: .value("City", series.city))
                .interpolationMethod(.catmullRom)
            }

            if let selectedDate {
                RuleMark(
                    x: .value("Selected", selectedDate, unit: .day)
                )
                .foregroundStyle(Color.gray.opacity(0.3))
                .offset(yStart: -10)
                .zIndex(-1)
                .annotation(
                    position: .top,
                    spacing: 0,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
                    )
                ) {
                    valueSelectionPopover
                }
            }
        }
        .chartXSelection(value: $rawSelectedDate)
    }
}

// 円グラフでの選択
Chart(data, id: \.name) { element in
    SectorMark(
        angle: .value("Sales", element.sales),
        innerRadius: .ratio(0.618),
        angularInset: 1.5
    )
    .cornerRadius(5)
    .foregroundStyle(by: .value("Name", element.name))
    .opacity(element.name == selectedName ? 1.0 : 0.3)
}
.chartAngleSelection(value: $selectedAngle)
```

## Scrolling

* **グラフのスクロール**

``` swift
Chart {
    ForEach(SalesData.last365Days, id: \.day) {
        BarMark(
            x: .value("Day", $0.day, unit: .day),
            y: .value("Sales", $0.sales)
        )
    }
    .foregroundStyle(.blue)
}
.chartScrollableAxes(.horizontal)
.chartXVisibleDomain(length: 3600 * 24 * 30) // 1ヶ月
.chartScrollPosition(x: $scrollPosition)
.chartScrollTargetBehavior(
    .valueAligned(
        matching: DateComponents(hour: 0),
        majorAlignment: .matching(DateComponent(day: 1))
    )
)
```