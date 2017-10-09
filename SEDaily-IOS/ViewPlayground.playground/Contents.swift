//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import ViewPlayground_Sources

    class PodcastCell: UICollectionViewCell {
        var imageView: UIImageView!
        var titleLabel: UILabel!
        var timeDayLabel: UILabel!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .white
            let newContentView = UIView(width: 158, height: 250)
            self.contentView.frame = newContentView.frame
            
            imageView = UIImageView(leftInset: 0, topInset: 4, width: 158)
            self.contentView.addSubview(imageView)
            self.addSubview(imageView)
            
            titleLabel = UILabel(origin: imageView.bottomLeftPoint(), topInset: 15, width: 158, height: 50)
            self.addSubview(titleLabel)
            
            timeDayLabel = UILabel(origin: titleLabel.bottomLeftPoint(), topInset: 8, width: 158, height: 10)
            self.addSubview(timeDayLabel)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:)")
        }

        func setupCell(image: UIImage, title: String, timeLength: Int, date: Date) {
            imageView.image = image
            titleLabel.text = title
            timeDayLabel.text
        }
    }

    extension PodcastCell {
        func setupSkeletonCell() {
            
        }
    }

// Present the view controller in the Live View window
let frame = CGRect(x: 0, y: 0, width: UIView.getValueScaledByScreenWidthFor(baseValue: 158), height: UIView.getValueScaledByScreenHeightFor(baseValue: 400))
let cell = PodcastCell(frame: frame)
cell.titleLabel.text = "An American Success Story"
PlaygroundPage.current.liveView = cell
