
import Photos

//MARK: - 앨범 정보 가져오기
class PhotosService {
    
    static var allAlbums = [AlbumInfo]() //앨범 리스트
    
    static func requestPHAssetCollection() {
        let normalAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: PHFetchOptions())
        let format = "mediaType == %d"
        
        //스마트 앨범 데이터 추가
        guard 0 < smartAlbums.count else { return }
        smartAlbums.enumerateObjects { smartAlbum, index, pointer in
            guard index <= smartAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            if smartAlbum.estimatedAssetCount == NSNotFound {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = .init(format: format + " || " + format,
                                               PHAssetMediaType.image.rawValue)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let smartAlbums = PHAsset.fetchAssets(in: smartAlbum, options: fetchOptions)
                self.allAlbums.append(
                    .init(
                        name: smartAlbum.localizedTitle ?? "",
                        count: smartAlbums.count,
                        album: smartAlbums
                    )
                )
            }
        }
        
        //일반 앨범 데이터 추가
        guard 0 < normalAlbums.count else { return }
        normalAlbums.enumerateObjects { normalAlbum, index, pointer in
            guard index <= normalAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            if normalAlbum.estimatedAssetCount != NSNotFound {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = .init(format: format + " || " + format,
                                               PHAssetMediaType.image.rawValue)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let normalAlbums = PHAsset.fetchAssets(in: normalAlbum, options: fetchOptions)
                self.allAlbums.append(
                    .init(
                        name: normalAlbum.localizedTitle ?? "",
                        count: normalAlbums.count,
                        album: normalAlbums
                    )
                )
            }
        }
    }

}
