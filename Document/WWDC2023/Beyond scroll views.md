# Beyond scroll views

## ScrollView

``` swift
// コンテンツをスクロールできるView
ScrollView(.vertical) {
    // 常に計算
    VStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }

    // 遅延計算
    LazyVStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}
```

## Margins and safe area

``` swift
// セーフエリアに対する余白設定
ScrollView(.horizontal) {
    LazyHStack(spacing: hSpacing) {
        ForEach(palettes) { palette in
            HeroView(palette: palette)
        }
    }
    // 余白追加(全ての要素に対して余白が追加される)
    .padding(.horizontal, hMargin)
    // 余白追加(セーフエリアに対してのみ余白が追加される)
    .safeAreaPadding(.horizontal, hMargin)
}

// 異なるインセットの適用
ScrollView {
    // content
}
// スクロールインジケータには適用されない
.contentMargins(
    .vertical,
    50.0,
    for: .scrollContent
)
```

## Targets and positions

``` swift
// スクロール速度の調整(ページング)
ScrollView(.horizontal) {
    LazyHStack(spacing: hSpacing) {
        ForEach(palettes) { palette in
            HeroView(palette: palette)
        }
    }
    .contentMargins(.horizontal, hMargin)
    .scrollTargetBehavior(.paging)
}

// スクロール速度の調整(個々のViewに対象を合わせる)
ScrollView(.horizontal) {
    LazyHStack(spacing: hSpacing) {
        ForEach(palettes) { palette in
            HeroView(palette: palette)
        }
        // スクロールされるターゲットの指定
        .scrollTargetLayout()
    }
    .contentMargins(.horizontal, hMargin)
    // ターゲット指定したビューを整列させる
    .scrollTargetBehavior(.viewAligned)
}

// 独自のスクロール方法の作成
struct GalleryScrollTargetBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < (context.containerSize.height / 3.0),
           context.velocity.dy > 0.0 {
            target.rect.origin.y = 0.0
        }
    }
}

// GeometeryReaderの置き換え(containerRelativeFrame)
HeroColorStack(palette: palette)
    .frame(height: 250.0)
    // 端末幅によってサイズが自動で置き換わる
    .containerRelativeFrame(.horizontal)
    // グリッドのような指定
    .containerRalativeFrame(
        .horizontal,
        count: 2,
        spacing: 10.0
    )

// iPadで2列、iOSで1列の表示
@Environment(\.horizontalSizeClass) private var sizeClass

HeroColorStack(palette: palette)
    .aspectRatio(16.0 / 9.0, contentMode: .fit)
    .containerRelativeFrame(
        .horizontal,
        count: sizeClass == .regular ? 2 : 1,
        spacing: 10.0
    )

// インジケーターの削除
ScrollView(.horizontal) {
    LazyHStack(spacing: hSpacing) {
        ForEach(palettes) { palette in
            HeroView(palette: palette)
        }
        .scrollTargetLayout()
    }
    .contentMargins(.horizontal, hMargin)
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden) // 「.never」にするとデバイスに関係なく非表示になる
}
```

## Scroll transitions

``` swift
// クリック(タップ)でのスクロール移動

@State private var mainID: Palette.ID? = nil

VStack {
    GallerySectionHeader(mainID: $mainID)

    ScrollView(.horizontal) {
        ...
    }
    .scrollPosition(id: $mainID)
}

// GallerySectionHeader
VStack {
    GalleryHeaderText()
}
.overlay {
    GalleryPaddle(edge: .leading) {
        mainID = previousID()
    }
}

@Binding var mainID: Palette.ID?

VStack {
    GalleryHeaderText()
    GallerySubheaderText(id: mainID)
}

// GalleryPaddle

GalleryPaddle(edge: .leading) {
    mainID = previousID()
}
```

``` swift
// ScrollTransition
HeroColorStack(palette: palette)
    .aspectRatio(16.0 / 9.0, contentMode: .fit)
    .containerRelativeFrame(
        .horizontal,
        count: count,
        spacing: 10.0
    )
    .scrollTransition(.axis: .horizontal) { content, phase in
        content
            // 中央配置時に大きさを等倍、それ以外の際は0.8倍で表示
            .scaleEffect(
                // isIdentityでコンテンツが中央かどうかを判定
                x: phase.isIdentify ? 1.0 : 0.80,
                y: phase.isIdentify ? 1.0 : 0.80
            )
            .rotationEffect(
                .degrees(phase.isIdentity ? 0.0 : 90.0)
            )
            .offset(
                x: phase.isIdentify ? 0.0 : 20.0,
                y: phase.isIdentify ? 0.0 : 20.0,
            )
            // フォントなどのScrollViewのコンテンツ全体のサイズを変更するmodifierは使用できない
            .font(phase.isIdentity ? .body : .title2) // ❌
    }
```