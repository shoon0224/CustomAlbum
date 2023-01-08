
import UIKit
import Photos

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var albumTableView: UITableView!
    
    private var allAlbums = [AlbumInfo]() //앨범 리스트
    private var albumCount : Int = 0
    private var albumName : String = ""
    private let imageManager =  PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoAuthorization()
        self.initForAlbumViewController()
    }
    
    func initForAlbumViewController() {
        self.setForTableView()
    }
    
    func setForTableView(){
        self.albumTableView.dataSource = self
        self.albumTableView.delegate = self
    }
    
    private func requestPHAssetCollection() {
        let normalAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: PHFetchOptions())
        let smartAlbumFavorites = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: PHFetchOptions())
        let format = "mediaType == %d"
        
        guard 0 < smartAlbums.count else { return }
        smartAlbums.enumerateObjects { smartAlbum, index, pointer in
            guard index <= smartAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            if smartAlbum.estimatedAssetCount == NSNotFound {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = .init(format: format + " || " + format,
                                               PHAssetMediaType.image.rawValue,
                                               PHAssetMediaType.video.rawValue)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let smartAlbums = PHAsset.fetchAssets(in: smartAlbum, options: fetchOptions)
                self.allAlbums.append(
                    .init(
                        id: smartAlbum.localIdentifier ,
                        name: smartAlbum.localizedTitle ?? "",
                        count: smartAlbums.count,
                        album: smartAlbums
                    )
                )
            }
        }
        
        guard 0 < normalAlbums.count else { return }
        normalAlbums.enumerateObjects { normalAlbum, index, pointer in
            guard index <= normalAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            if normalAlbum.estimatedAssetCount != NSNotFound {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = .init(format: format + " || " + format,
                                               PHAssetMediaType.image.rawValue,
                                               PHAssetMediaType.video.rawValue)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let normalAlbums = PHAsset.fetchAssets(in: normalAlbum, options: fetchOptions)
                self.allAlbums.append(
                    .init(
                        id: normalAlbum.localIdentifier ,
                        name: normalAlbum.localizedTitle ?? "",
                        count: normalAlbums.count,
                        album: normalAlbums
                    )
                )
            }
        }
        
        guard 0 < smartAlbumFavorites.count else { return }
        smartAlbumFavorites.enumerateObjects { smartAlbumFavorite, index, pointer in
            guard index <= smartAlbumFavorites.count - 1 else {
                pointer.pointee = true
                return
            }
            if smartAlbumFavorite.estimatedAssetCount == NSNotFound {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = .init(format: format + " || " + format,
                                               PHAssetMediaType.image.rawValue,
                                               PHAssetMediaType.video.rawValue)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let smartAlbumFavorites = PHAsset.fetchAssets(in: smartAlbumFavorite, options: fetchOptions)
                self.allAlbums.append(
                    .init(
                        id: smartAlbumFavorite.localIdentifier ,
                        name: smartAlbumFavorite.localizedTitle ?? "",
                        count: smartAlbumFavorites.count,
                        album: smartAlbumFavorites
                    )
                )
            }
        }
        
        self.albumTableView.reloadData()
    }
    
    func photoAuthorization(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: //허용
            self.requestPHAssetCollection()
            self.albumTableView.reloadData()
        case .notDetermined: //응답 받지 못한 상태
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    print("허용")
                    self.requestPHAssetCollection()
                    DispatchQueue.main.async {
                        self.albumTableView.reloadData()
                    }
                case .denied:
                    print("불허가")
                default:
                    break
                }
            })
        case .restricted:
            print("restricetd")
        case .denied:
            print("denied")
        default:
            break
        }
    }
    
}

//MARK: - UITableViewDataSource
extension AlbumViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlbumTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as! AlbumTableViewCell
        let asset = self.allAlbums[indexPath.item].album
        
        if asset.firstObject != nil{
            self.imageManager.requestImage(for: asset.firstObject!,
                                           targetSize: CGSize(width: cell.frame.width, height: cell.frame.height),
                                           contentMode: .aspectFit,
                                           options: nil,
                                           resultHandler: { album, _ in
                cell.thumbnailImageView.image = album
            })
        }
        cell.albumNameLabel.text = self.allAlbums[indexPath.row].name
        cell.assetCountLabel.text = String(self.allAlbums[indexPath.row].count)
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension AlbumViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageCollectionViewController = storyboard.instantiateViewController(identifier: "ImageCollectionViewController") as! ImageCollectionViewController
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
        imageCollectionViewController.title = self.allAlbums[indexPath.row].name
        imageCollectionViewController.asset = self.allAlbums[indexPath.row].album
        self.navigationController?.pushViewController(imageCollectionViewController, animated: true)
        
        
    }
}

