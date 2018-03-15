import UIKit

class ViewController: UIViewController {
    private let photoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

    override func viewDidLoad() {
        super.viewDidLoad()

        // カメラ起動ボタン生成
        let cameraButton: RoundedButton = {
            let buttonX = (UIScreen.main.bounds.width / 2) - 100
            let buttonY = UIScreen.main.bounds.height - 150
            let button = RoundedButton(frame: CGRect(x: buttonX, y: buttonY, width: 200, height: 40))

            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("カメラ起動", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.addTarget(self, action: #selector(self.setImageFromCamera(_:)), for: .touchUpInside)

            return button
        }()

        // フォトライブラリー起動ボタン生成
        let galleryButton: RoundedButton = {
            let buttonX = (UIScreen.main.bounds.width / 2) - 100
            let buttonY = UIScreen.main.bounds.height - 100
            let button = RoundedButton(frame: CGRect(x: buttonX, y: buttonY, width: 200, height: 40))

            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("フォトライブラリー起動", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.addTarget(self, action: #selector(self.setImageFromPhotos(_:)), for: .touchUpInside)

            return button
        }()

        // カメラ、フォロライブラリーから取得した画像をセットするためのUIImageView
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.position.x = UIScreen.main.bounds.width / 2
        photoImageView.layer.position.y = (UIScreen.main.bounds.height / 2) - (photoImageView.bounds.size.height / 2)
        photoImageView.layer.borderColor = UIColor.lightGray.cgColor
        photoImageView.layer.borderWidth = 1.0

        view.addSubview(cameraButton)
        view.addSubview(galleryButton)
        view.addSubview(photoImageView)
    }

    // カメラ起動ボタンが押されると呼ばれる
    @objc fileprivate func setImageFromCamera(_ sender: Any) {
        PhotoRequestManager.requestPhotoFromCamera(self){ [weak self] result in
            switch result {
            case .success(let image):
                self?.setImage(image)
            case .faild:
                print("failed")
            case .cancel:
                break
            }
        }
    }

    // フォロライブラリー起動ボタンが押されると呼ばれる
    @objc private func setImageFromPhotos(_ sender: Any) {
        PhotoRequestManager.requestPhotoLibrary(self){ [weak self] result in
            switch result {
            case .success(let image):
                self?.setImage(image)
            case .faild:
                print("failed")
            case .cancel:
                break
            }
        }
    }

    // 取得した画像をセットするメソッド
    private func setImage(_ image: UIImage) {
        photoImageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

final class RoundedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.backgroundColor = UIColor.darkGray.cgColor
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                layer.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8).cgColor
            } else {
                layer.backgroundColor = UIColor.darkGray.cgColor
            }
        }
    }
}
