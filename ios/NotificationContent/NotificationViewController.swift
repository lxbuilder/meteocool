import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content

        if let aps = content.userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? NSString {
                    UserDefaults.init(suiteName: "group.org.frcy.app.meteocool")?.setValue(message, forKey: "message")
                }
            } else if let alert = aps["alert"] as? NSString {
                UserDefaults.init(suiteName: "group.org.frcy.app.meteocool")?.setValue(alert, forKey: "alert")
            }
        }

        if let urlString = content.userInfo["preview"] as? String,
            let url = URL(string: urlString) {
            URLSession.downloadImage(atURL: url) { [weak self] (data, error) in
                if let _ = error {
                    return
                }
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: data)
                }
            }
        }
    }
}

extension URLSession {
    class func downloadImage(atURL url: URL, withCompletionHandler completionHandler: @escaping (Data?, NSError?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            completionHandler(data, nil)
        }
        dataTask.resume()
    }
}
