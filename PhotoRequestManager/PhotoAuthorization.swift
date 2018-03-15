import Foundation
import UIKit
import AVFoundation
import Photos

enum PhotoAuthorizedErrorType {
    // 利用制限
    case restricted
    // 明示的拒否
    case denied
}

enum PhotoAuthorizedResult {
    case success
    case error(PhotoAuthorizedErrorType)
}

typealias PhotoAuthorizedCompletion = ((PhotoAuthorizedResult) -> Void)

final class PhotoAuthorization {
    private init() {}

    static func media(mediaType: String, completion: PhotoAuthorizedCompletion?) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: mediaType))
        switch status {
        case .authorized:
            // 許可済み
            completion?(PhotoAuthorizedResult.success)
        case .restricted:
            // 利用制限（設定 -> 一般 -> 機能制限 で利用が制限されている）
            completion?(PhotoAuthorizedResult.error(.restricted))
        case .denied:
            // 明示的拒否（設定 -> プライバシー で利用が制限されている）
            completion?(PhotoAuthorizedResult.error(.denied))
        case .notDetermined:
            // 許可も拒否もしていない状態
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: mediaType)) { granted in
                DispatchQueue.main.async() {
                    if granted {
                        // 許可
                        completion?(PhotoAuthorizedResult.success)
                    } else {
                        // 拒否
                        completion?(PhotoAuthorizedResult.error(.denied))
                    }
                }
            }
        }
    }

    static func camera(completion: PhotoAuthorizedCompletion?) {
        self.media(mediaType: AVMediaType.video.rawValue, completion: completion)
    }

    static func photo(completion: PhotoAuthorizedCompletion?) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
             // 許可済み
            completion?(PhotoAuthorizedResult.success)
        case .restricted:
            // 利用制限（設定 -> 一般 -> 機能制限 で利用が制限されている）
            completion?(PhotoAuthorizedResult.error(.restricted))
        case .denied:
            // 明示的拒否（設定 -> プライバシー で利用が制限されている）
            completion?(PhotoAuthorizedResult.error(.denied))
        case .notDetermined:
            // 許可も拒否もしていない状態
            PHPhotoLibrary.requestAuthorization() { status in
                DispatchQueue.main.async() {
                    if status == PHAuthorizationStatus.authorized {
                        // 許可
                        completion?(PhotoAuthorizedResult.success)
                    } else {
                        // 拒否
                        completion?(PhotoAuthorizedResult.error(.denied))
                    }
                }
            }
        }
    }
}
