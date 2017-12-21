//
//  StoreEmotionManager.swift
//  FileDemo
//
//  Created by yakang wang on 2017/12/20.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

/// 一个大包情数据对象
class ATEmotionBig: ATEmotionType {
    var image: UIImage?
    
    /// 表情图片的MD5值
    var identifier: String = ""
    
    /// 大表情的名字，自定义收藏的是没有名字的
    var displayName: String = ""
    
    /// 大表情包的Id, 代表一套表情
    var packageId: String = ""
    
    /// 大表情图片的名字,带有.png或者是.gif
    var imageName: String = ""
    
    /// 缩略图路径
    var thumImagePath: URL? = nil
    
    /// 表情缩略图图片
    var thumImage: UIImage?
    
    /// 原图图路径
    var imageFileURL: URL? = nil

    /// 大表情的图片数据
    var imageData: Data?
    
    init(packageId: String, imageName: String) {
        self.packageId = packageId
        self.imageName = imageName
    }
}

extension ATEmotionBig: CustomStringConvertible {
    var description: String {
        return "ATEmotionBig: packageId:\(packageId)\nimageName:\(imageName)\nidentifier:\(identifier)\ndisplayName:\(displayName)"
    }
}

enum EmotionSizeType {
    case thum
    case origin
}

extension EmotionSizeType {
    var info: (String) {
        switch self {
        case .thum:
            return ("StoreEmotionThum")
        case .origin:
            return ("StoreEmotion")
        }
    }
    
}

/// 大表情管理类
/// 大表情下载 加载 缓存 删除等
class StoreEmotionManager {
    
    /// 下载的表情储存的文件夹名字
    let kStoreEmotionFileName: String = EmotionSizeType.origin.info
    
    /// 下载的表情储存的文件夹名字
    let kStoreEmotionThumFileName: String = EmotionSizeType.thum.info
    
    /// 下载的表情储存的路径
    let kStoreEmotionURL: URL
    
    /// 下载的表情处理成缩略图后储存的路径
    let kStoreEmotionThumURL: URL
    
    let fileManager = FileManager.default
    
    public static let shared: StoreEmotionManager = StoreEmotionManager()
    private init() {
        let urlsForDocument = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let userDomainURL = urlsForDocument.first!
        self.kStoreEmotionURL = userDomainURL.appendingPathComponent(self.kStoreEmotionFileName, isDirectory: true)
        self.kStoreEmotionThumURL = userDomainURL.appendingPathComponent(self.kStoreEmotionThumFileName, isDirectory: true)
    }
    
    /// 创建大表情原图文件夹
    func createFielderOrigin(packageId: String) -> Bool {
        let packageURL = getPackageURL(packageId)
        do {
            try fileManager.createDirectory(at: packageURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            return true
        } catch {
            print("createFielderOrigin error \(error)")
            return false
        }
    }
    
    /// 创建大表缩略图文件夹
    func createFielderThum(packageId: String) -> Bool {
        let packageURL = getThumPackageURL(packageId)
        do {
            try fileManager.createDirectory(at: packageURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            return true
        } catch {
            print("createFielderThum error \(error)")
            return false
        }
    }
    
    /// 获取某一个具体大表情缩略图的路径
    func getThumPackageURL(_ packageId: String) -> URL {
        return kStoreEmotionThumURL.appendingPathComponent(packageId, isDirectory: true)
    }
    
    /// 获取某一个具体大表情的路径
    func getPackageURL(_ packageId: String) -> URL {
        return kStoreEmotionURL.appendingPathComponent(packageId, isDirectory: true)
    }
    
    /// 拷贝Bundle 到 沙盒中去
    ///
    /// - Parameters:
    ///   - name: bound文件名字必须以.bundle结尾
    ///   - paht:目标路径
    func copyToStoreEmotionFilderBundle(name: String) -> Bool {
        let bundlePath = Bundle.main.path(forResource: name, ofType: "bundle")
        
        do {
            if let bundlePath = bundlePath {
                try fileManager.copyItem(atPath: bundlePath, toPath: kStoreEmotionURL.path)
                return true
            }
        } catch {
            print("copyBundleToUserDomain \(error)")
            return false
        }
        return false
    }
    
    
    /// 创建一个大表情的所有缩略图
    func createEmotionThum(packageId: String) -> Bool {
        
        if let fileURLs = emotionsURL(packageId: packageId, type: .origin)
        {
            for fileURL in fileURLs
            {
                if let originImage = UIImage(contentsOfFile: fileURL.path)
                {
                    if let scaleImage = originImage.ke.scaleTo(size: CGSize(width: 65.5, height: 65.5))
                    {
                        let isSusses = storeThum(name: fileURL.lastPathComponent, package: packageId, image: scaleImage)
                        print("\(fileURL.lastPathComponent) -> \(isSusses.description)")
                    } else {
                        print("\(fileURL.lastPathComponent) -> scaleImage nil")
                    }
                }
            }
            return true
        } else {
            print("createEmotionThum(packageId:) -> fileURLs nil")
        }
        return false
    }
    
    /// 根据packageId创建这个包下所有的大表情模型
    ///
    /// - Parameter packageId: 大表情包 Id
    /// - Returns: 这套大表情的所有模型
    func loadModel(packageId: String) -> [ATEmotionBig]? {
        if let fileURLs = emotionsURL(packageId: packageId) {
            var bigEmotionArray = [ATEmotionBig]()
            for fileURL in fileURLs {
                let fileName = fileURL.lastPathComponent
                let emotionModel = ATEmotionBig(packageId: packageId, imageName: fileName)
                emotionModel.thumImagePath = fileURL
                bigEmotionArray.append(emotionModel)
            }
            asyncLoadImages(emotions: bigEmotionArray)
            return bigEmotionArray
        }
        return nil
    }
    
    func asyncLoadImages(emotions: [ATEmotionBig]) {
        DispatchQueue.global().async {
            for e in emotions {
                do {
                    e.imageFileURL = self.kStoreEmotionURL.appendingPathComponent(e.packageId, isDirectory: true).appendingPathComponent(e.imageName, isDirectory: false)
                    if let url = e.imageFileURL {
                        e.imageData = try Data(contentsOf: url)
                    }
                    if let thumURL = e.thumImagePath {
                        e.thumImage = UIImage(contentsOfFile: thumURL.path)
                    }
                } catch {
                    print("asyncLoadImages error \(error)")
                }
            }
        }
    }
    
    /// 储存大表情缩略图
    func storeThum(name: String, package: String, image: UIImage) -> Bool {
        var data: Data? = nil
        if let dataPNG = UIImagePNGRepresentation(image) {
            data = dataPNG
        } else if let dataJPG = UIImageJPEGRepresentation(image, 1.0) {
            data = dataJPG
        }
        if let data = data {
            let filePath = getThumPackageURL(package).appendingPathComponent(name, isDirectory: false)
            let isSusses = fileManager.createFile(atPath: filePath.path, contents: data, attributes: nil)
            return isSusses
        }
        return false
    }
    
    /// 查看表情包下的所有表情名
    /// - Returns: 所有表情图片的全路径
    func emotionsURL(packageId: String, type: EmotionSizeType = .thum) -> [URL]? {
        var nameURLs = [URL]()
        do {
            var packageURL: URL!
            switch type {
            case .origin:
                packageURL = getPackageURL(packageId)
            case .thum:
                packageURL = getThumPackageURL(packageId)
            }
            let fileNames = try fileManager.contentsOfDirectory(atPath: packageURL.path)
            for name in fileNames {
                let nameURL = packageURL.appendingPathComponent(name, isDirectory: false)
                nameURLs.append(nameURL)
            }
        } catch {
            print("error \(error)")
            return nil
        }
        return nameURLs
    }
    
    
    
    
    /// 查看表情包下的所有表情名
    /// - Returns: 所有表情的名字
    func searchEmotion(packageId: String) -> [String]? {
        do {
            let packagePath = getPackageURL(packageId).path
            let fileNames = try fileManager.contentsOfDirectory(atPath: packagePath)
            return fileNames
        } catch {
            print("error \(error)")
            return nil
        }
    }
    
    /// 查看表情包下的所有表情名
    /// - Returns: 所有表情图片
    func loadImages(packageId: String) -> [UIImage]? {
        if let fileNames = searchEmotion(packageId: packageId) {
            var images = [UIImage]()
            for name in fileNames {
                let packageURL = getPackageURL(packageId)
                let filePath = packageURL.appendingPathComponent(name, isDirectory: false).path
                if let image = UIImage(contentsOfFile: filePath) {
                    images.append(image)
                }
            }
            return images
        } else {
            return nil
        }
    }
    
    
}
