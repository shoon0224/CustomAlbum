
import Photos

struct AlbumInfo: Identifiable {
    let id: String?
    let name: String
    let count: Int
    let album: PHFetchResult<PHAsset>
}
