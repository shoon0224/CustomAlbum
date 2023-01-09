
import UIKit
import Photos

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var albumTableView: UITableView!
    
    
    private let imageManager =  PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initForAlbumViewController()
        self.photoAuthorization()
    }
    
    //AlbumViewController 초기화
    func initForAlbumViewController() {
        self.albumTableView.dataSource = self
        self.albumTableView.delegate = self
    }
    
    
    
    //MARK: - 권한 설정
    func photoAuthorization(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: //허용
            PhotosService.requestPHAssetCollection()
            DispatchQueue.main.async {
                self.albumTableView.reloadData()
            }
        case .notDetermined: //처음 응답 받지 못한 상태
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized: //허용
                    PhotosService.requestPHAssetCollection()
                    DispatchQueue.main.async {
                        self.albumTableView.reloadData()
                    }
                case .restricted, .denied: //거부
                    DispatchQueue.main.async {
                        self.moveToSetting()
                    }
                default:
                    break
                }
            })
        case .restricted, .denied: //거부
            DispatchQueue.main.async {
                self.moveToSetting()
            }
        default:
            break
        }
    }
    
    /**
     * @brief 권한 거부되었을 때
     */
    func moveToSetting() {
        let alertController = UIAlertController(title: "권한 거부됨", message: "앨범 접근이 거부 되었습니다\n접근 허용을 선택해 주세요", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "권한 설정으로 이동하기", style: .default) { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        let cancelAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.photoAuthorization()
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
}

//MARK: - UITableViewDataSource
extension AlbumViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PhotosService.allAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlbumTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as! AlbumTableViewCell
        let asset = PhotosService.allAlbums[indexPath.item].album
        
        //asset.firstObject 반드시 옵셔널타입이여야 한다해서 조건문으로 예외처리
        if asset.firstObject != nil {
            self.imageManager.requestImage(for: asset.firstObject!,
                                           targetSize: CGSize(width: cell.frame.width, height: cell.frame.height),
                                           contentMode: .aspectFit,
                                           options: nil,
                                           resultHandler: { album, _ in
                DispatchQueue.main.async {
                    cell.thumbnailImageView.image = album
                }
            })
        }
        cell.albumNameLabel.text = PhotosService.allAlbums[indexPath.row].name
        cell.assetCountLabel.text = String(PhotosService.allAlbums[indexPath.row].count)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension AlbumViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageCollectionViewController = storyboard.instantiateViewController(identifier: "ImageCollectionViewController") as! ImageCollectionViewController
        
        //뒤로가기 버튼 옆 글자 제거
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        //뒤로가기 버튼색 변경
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
        imageCollectionViewController.title = PhotosService.allAlbums[indexPath.row].name
        imageCollectionViewController.asset = PhotosService.allAlbums[indexPath.row].album
        self.navigationController?.pushViewController(imageCollectionViewController, animated: true)
    }
}

