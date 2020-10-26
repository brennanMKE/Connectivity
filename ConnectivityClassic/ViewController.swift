import UIKit
import ConnectivityKit

class ViewController: UIViewController {
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var interfacesLabel: UILabel!

    override func viewDidLoad() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        debugPrint(#function)
        appDelegate.appState.appStateChangedHandler = didChange(appState:)
        apply(appState: appDelegate.appState)
    }

    func didChange(appState: AppState)  {
        debugPrint(#function)
        dispatchPrecondition(condition: .onQueue(.main))
        apply(appState: appState)
    }

    func apply(appState: AppState) {
        emojiLabel.text = appState.networkEmoji
        statusLabel.text = appState.networkStatus
        pathLabel.text = appState.pathStatus
        interfacesLabel.text = appState.interfaces
    }
}
