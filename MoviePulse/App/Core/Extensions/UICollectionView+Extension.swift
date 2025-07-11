import UIKit

extension UICollectionView {
    func configure(
        withCells cells: [UICollectionViewCell.Type],
        headers: [UICollectionReusableView.Type] = [],
        headerKind: String = "Header",
        delegate: UICollectionViewDelegate? = nil,
        dataSource: UICollectionViewDataSource? = nil,
        contentInset: UIEdgeInsets = .zero
    ) {
        // Register cells
        cells.forEach { cell in
            self.register(cell.nib(), forCellWithReuseIdentifier: cell.className)
        }
        
        // Register headers
        headers.forEach { header in
            self.register(
                header.nib(),
                forSupplementaryViewOfKind: headerKind,
                withReuseIdentifier: header.className
            )
        }
        
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.dataSource = dataSource
        self.delegate = delegate
        self.contentInset = contentInset
    }
}

extension UIView {
    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
}
