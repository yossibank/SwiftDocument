# WWDC2023

## Build accessible apps with SwiftUI and UIKit

### アクセシビリティの強化

* **ボタンのON/OFF切り替えによるアクセシビリティの提供**

``` swift
// SwiftUI用
import SwiftUI

struct FilterButton: View {
    @State var filter: Bool = false

    var body: some View {
        Button(action: { filter.toggle() }) {
            Text("Filter")
        }
        .background(filter ? darkGreen : lightGreen)
        .accessibilityAddTraits(.isToggle)
    }
}
```

``` swift
// UIKit用
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let filterButton = UIButton(type: .custom)

        setupButtonView()

        filterButton.accessibilityTraits = [.toggleButton]

        view.addSubview(filterButton)
    }
}
```

* **Accessibility Notification(アクセシビリティの通知)**

``` swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            PhotoFilterView
                .toolbar {
                    Button(action: {
                        AccessibilityNotification.Announcement("Loading Photos View")
                            .post()
                    }) {
                        Text("Photos")
                    }
                }
        }
    }
}
```

* **Announcement Priority(VoiceOver時の発話の優先度)**

``` swift
// SwiftUI用
import SwiftUI

struct ZoomingImageView: View {
    var defaultPriorityAnnouncement = AttributedString("Opening Camera")

    var lowPriorityAnnouncement: AttributedString {
        var lowPriorityString = AttributedAtring("Camera Loading")
        lowPriorityString.accessibilitySpeechAnnouncementPriority = .low
        return lowPriorityString
    }

    var highPriorityAnnouncement: AttributedString {
        var highPriorityString = AttributedAtring("Camera Active")
        highPriorityString.accessibilitySpeechAnnouncementPriority = .high
        return highPriorityString
    }
}

struct CameraButton: View {
    var body: some View {
        Button(action: {
            // Open Camera Code
            AccessibilityNotification.Announcement(defaultPriorityAnnouncement).post()
            // Camera Loading Code
            AccessibilityNotification.Announcement(lowPriorityAnnouncement).post()
            // Camera Loaded Code
            AccessibilityNotification.Announcement(highPriorityAnnouncement).post()
        }) {
            Image("Camera")
        }
    }
}
```

``` swift
// UIKit用
import UIKit

class ViewController: UIViewController {
    let defaultAnnouncement = NSAttributedString(
        string: "Opening Camera",
        attributes: [NSAttributedString.Key.UIAccessibilitySpeechAttributeAnnouncementPriority: UIAccessibilityPriority.default]
    )

    let lowAnnouncement = NSAttributedString(
        string: "Camera Loading",
        attributes: [NSAttributedString.Key.UIAccessibilitySpeechAttributeAnnouncementPriority: UIAccessibilityPriority.low]
    )

    let highAnnouncement = NSAttributedString(
        string: "Camera Active",
        attributes: [NSAttributedString.Key.UIAccessibilitySpeechAttributeAnnouncementPriority: UIAccessibilityPriority.high]
    )
}
```

* **ズームアクションの変更を検知するアクセシビリティの提供**

``` swift
// SwiftUI用
import SwiftUI

struct ZoomingImageView: View {
    @State private var zoomValue = 1.0
    @State var imageName: String?

    var body: some View {
        Image(imageName ?? "")
            .scaleEffect(zoomValue)
            .accessibilityZoomAction { action in
                let zoomQuality = "\(Int(zoomValue)) x zoom"
                switch action.direction {
                case .zoomIn:
                    zoomValue += 1.0
                    AccessibilityNotification.Announcement(zoomQuality).post()

                case .zoomOut:
                    zoomValue -= 1.0
                    AccessibilityNotification.Announcement(zoomQuality).post()
                }
            }
    }
}
```

``` swift
// UIKit用
import UIKit

class ViewController: UIViewController {
    let zoomView = ZoomingImageView(frame: .zero)
    let imageView = UIImageView(image: UIImage(named: "tree"))

    override func viewDidLoad() {
        super.viewDidLoad()
        zoomView.isAccessibilityElement = true
        zoomView.accessibilityLabel = "Zooming Image View"
        zoomView.accessibilityTraits = [.image, .supportsZoom]

        zoomView.addSubview(imageView)
        view.addSubview(zoomView)
    }
}

class ZoomingImageView: UIScrollView {
    override func accessibilityZoomIn(at point: CGPoint) -> Bool {
        zoomScale += 1.0

        let zoomQuality = "\(Int(zoomValue)) x zoom"
        UIAccessibility.post(notification: .announcement, argument: zoomQuality)
        return true
    }

    override func accessibilityZoomOut(at point: CGPoint) -> Bool {
        zoomScale -= 1.0

        let zoomQuality = "\(Int(zoomValue)) x zoom"
        UIAccessibility.post(notification: .announcement, argument: zoomQuality)
        return true
    }
}
```

* **タップ時にVoiceOverを読み上げるかどうかのアクセシビリティの提供**

``` swift
// SwiftUI用
import SwiftUI

struct KeyboardkeyView: View {
    var soundFile: String
    var body: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 35, height: 80)
            .onTapGesture(count: 1) {
                playSound(sound: soundFile, type: "mp3")
            }
            .accessibilityDirectTouch(options: .silentOnTouch)
    }
}
```

``` swift
// UIKit用
import UIKit

class ViewController: UIViewController {
    let waveformButton = UIButton(type: .custom)

    waveformButton.accessibilityTraits = .allowsDirectInteraction
    waveformButton.accessibilityDirectTouchOptions = .silentOnTouch
    waveformButton.addTarget(self, action: #selector(playTone), for: .touchUpInside)

    view.addSubview(waveformButton)
}
```

### アクセシビリティの視認性向上

* **形状まで完全一致の特定**

``` swift
import SwiftUI

struct ImageView: View {
    var body: some View {
        Image("circle-red")
            .resizable()
            .frame(width: 200, height: 200)
            .accessibilityLabel("Red")
            .contentShape(.accessibility, Circle())
    }
}
```

### 最新状態の保持

* **Accessibility block based setters(UIKit)**

``` swift
import UIKit

class ViewController: UIViewController {
    var isFiltered = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up views
        zoomView.accessibilityValueBlock = { [weak self] in
            guard let self else { return nil }
            return isFiltered ? "Filtered" : "Not Filtered"
        }
    }
}
```