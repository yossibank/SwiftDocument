# Create a great spatial playback experience

## Media experience

<img src="../../Image/WWDC2023/Create_a_great_spatial_playback_experience.png" width=100%>

``` swift
import AVFoundation
import AVKit

let controller = AVPlayerViewController()
controller.player = AVPlayer()
controller.player?.replaceCurrentItem(with: AVPlayerItem(url: contentURL))

// SwiftUIで使用する
struct PlayerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer()
        controller.player?.replaceCurrentItem(with: AVPlayerItem(url: contentURL))
        return controller
    }

    func updateUIViewController(_ : AVPlayerViewController, context: Context) {}
}

import SwiftUI

@main
struct MoviePlayingApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            PlayerView()
        }
    }
}
```

<img src="../../Image/WWDC2023/Create_a_great_spatial_playback_experience_1.png" width=100%>

## Advanced features

* サムネイルの表示(145ピクセル推奨)

<img src="../../Image/WWDC2023/Create_a_great_spatial_playback_experience_2.png" width=100%>

* ロゴ、総集編、広告を挿入するためのタイムラインサポート

<img src="../../Image/WWDC2023/Create_a_great_spatial_playback_experience_3.png" width=100%>

* カスタムアクションボタンの追加
  * コンテンツに関するメタデータの表示
  * 関連するコンテンツの提案

<img src="../../Image/WWDC2023/Create_a_great_spatial_playback_experience_4.png" width=100%>

* Immersive Spaceの作成
  * 空間のカスタム定義

``` swift
import SwiftUI

@main struct MoviePlayingApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            PlayerView()
                .onAppear() {
                    Task {
                        await openImmersiveSpace(id: "PlayerImmersiveSpace")
                    }
                }
        }

        ImmersiveSpace(id: "PlayerImmersiveSpace") {
            RealityView { content in
                let entity = // Create entities.
                content.add(entity)
            }
        }
    }
}

// カスタムコントロールの使用
showsPlaybackControls = false
```

## Other use cases

* インライン再生

<img src="../../Image/WWDC2023/Create_a_great_spatial_playback_experience_5.png" width=100%>

## Conclusion

<img src="../../Image/WWDC2023/Create_a_great_spatial_playback_experience_6.png" width=100%>