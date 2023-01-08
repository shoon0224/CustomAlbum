
import UIKit
import Photos

class ImageCollectionViewController: UIViewController {
    
    var asset: PHFetchResult<PHAsset>?
    private let imageManager =  PHCachingImageManager()
    @IBOutlet var imageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
    }
}

extension ImageCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.asset?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        
        self.imageManager.requestImage(for: (self.asset?.object(at: indexPath.item))!,
                                       targetSize: CGSize(width: cell.frame.width, height: cell.frame.height),
                                       contentMode: .aspectFill,
                                       options: nil) {
            image, _ in
            DispatchQueue.main.async {
                cell.imageView?.image = image
            }
        }
        return cell
    }
}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout{
    
    //위 아래 간격 4
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 가로 3개 기준 Cell Spacing이 4이면 간격 두개 발생 총 8 개의 간격을 빼고 3을 나눔
        let itemSize = (collectionView.frame.width - 8) / 3
        return CGSize(width: itemSize, height: itemSize)
    }
    
}

extension ImageCollectionViewController: UICollectionViewDelegate {
    //사진 정보 AlertView 표시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = self.asset?.object(at: indexPath.row) else { return }
        var byte = ""
        let resources = PHAssetResource.assetResources(for: asset)
        let filename = resources.first!.originalFilename
        var sizeOnDisk: Int64 = 0
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
            byte = String(format: "%.2f", Double(sizeOnDisk) / (1024.0*1024.0))+" MB"
        }
        let alert = UIAlertController(title: "사진정보", message: "파일명 : \(filename)\n파일크기 : \(byte)", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
