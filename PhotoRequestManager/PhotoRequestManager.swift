import Foundation
import UIKit

enum PhotoRequestResult {
    case success(UIImage)
    case faild(PhotoAuthorizedErrorType)
    case cancel
}

typealias PhotoResquestCompletion = ((PhotoRequestResult) -> Void)

final class PhotoRequestManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate static let shared: PhotoRequestManager = PhotoRequestManager()
    fileprivate var completionHandler: (PhotoResquestCompletion)?

    // フォトライブラリ（PhotoLibrary）へアクセス
    static func requestPhotoLibrary(_ parentViewController: UIViewController, completion: PhotoResquestCompletion?) {
        shared.requestPhoto(parentViewController, sourceType: .photoLibrary, completion: completion)
    }

    // カメラ（Camera）へアクセス
    static func requestPhotoFromCamera(_ parentViewController: UIViewController, completion: PhotoResquestCompletion?) {
        shared.requestPhoto(parentViewController, sourceType: .camera, completion: completion)
    }

    // フォトアルバム（SavedPhotosAlbum）へアクセス
    static func requestPhotoFromSavedPhotosAlbum(_ parentViewController: UIViewController, completion: PhotoResquestCompletion?) {
        shared.requestPhoto(parentViewController, sourceType: .savedPhotosAlbum, completion: completion)
    }

    private func requestPhoto(_ parentViewController: UIViewController, sourceType: UIImagePickerControllerSourceType , completion: PhotoResquestCompletion?) {
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            completion?(PhotoRequestResult.faild(.denied))
            return
        }

        let resultBlock: PhotoAuthorizedCompletion = { [unowned self] result in
            switch result {
            case .success:
                let imagePickerController : UIImagePickerController = UIImagePickerController()
                imagePickerController.sourceType = sourceType
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self

                self.completionHandler = completion

                parentViewController.present(imagePickerController, animated: true, completion: nil)
            case .error(let error):
                completion?(PhotoRequestResult.faild(error))
            }
        }

        switch sourceType {
        case .camera:
            PhotoAuthorization.camera(completion: resultBlock)
        case .photoLibrary, .savedPhotosAlbum:
            PhotoAuthorization.photo(completion: resultBlock)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PhotoRequestManager {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true) { [unowned self] in
            self.completionHandler?(PhotoRequestResult.success(image))
            self.completionHandler = nil
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [unowned self] in
            self.completionHandler?(PhotoRequestResult.cancel)
            self.completionHandler = nil
        }
    }
}
