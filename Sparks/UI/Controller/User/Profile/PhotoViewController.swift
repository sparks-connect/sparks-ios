//
//  PhotoViewController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 09.08.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

import UIKit

enum TransitionType {
    case Presenting, Dismissing
}

protocol PhotoViewControllerDelegate: AnyObject {
    func willDeletePhoto(photo: UserPhoto)
}

class AnimateTransition: NSObject, UIViewControllerAnimatedTransitioning {
   var duration: TimeInterval
   var isPresenting: Bool
   var originFrame: CGRect
   var collectionView: UICollectionView
   init(withDuration duration: TimeInterval, forTransitionType type: TransitionType, originFrame: CGRect, collectionView: UICollectionView) {
    self.duration = duration
    self.isPresenting = type == .Presenting
    self.originFrame = originFrame
    self.collectionView = collectionView
    super.init()
}

func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return self.duration
}

func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    var selected: IndexPath?
    if collectionView.indexPathsForSelectedItems?.count == 0 {
        selected = IndexPath(row: 0, section: 0)
    }
    else {
        selected = collectionView.indexPathsForSelectedItems?[0]
    }
    
    let cell = collectionView.cellForItem(at: selected!)
    let container: UIView? = transitionContext.containerView
    let fromVC: UIViewController? = transitionContext.viewController(forKey: .from)
    let toVC: UIViewController? = transitionContext.viewController(forKey: .to)
    let fromView: UIView? = fromVC?.view
    let toView: UIView? = toVC?.view
    let beginFrame: CGRect? = container?.convert((cell?.contentView.bounds)!, from: cell?.contentView)
    var endFrame: CGRect = transitionContext.initialFrame(for: fromVC!)
    endFrame = toView?.frame ?? CGRect.zero
    var move: UIView? = nil
    var transitionDuration: CGFloat
    if isPresenting {
        transitionDuration = CGFloat(self.duration)
        toView?.frame = endFrame
        move = toView?.snapshotView(afterScreenUpdates: true)
        move?.frame = beginFrame!
        cell?.isHidden = true
    }
    else {
        transitionDuration =  CGFloat(self.duration)
        move = cell?.contentView.snapshotView(afterScreenUpdates: true)
        move?.frame = (fromView?.frame)!
        fromView?.removeFromSuperview()
    }
    container?.addSubview(move!)
    if isPresenting {
        UIView.animate(withDuration: TimeInterval(transitionDuration) , animations: {() -> Void in
            move?.frame = endFrame
        }, completion: {(_ finished: Bool) -> Void in
            move?.removeFromSuperview()
            toView?.frame = endFrame
            container?.addSubview(toView!)
            transitionContext.completeTransition(true)
        })
    }
    else {
        UIView.animate(withDuration: TimeInterval(transitionDuration) , delay: 0, usingSpringWithDamping: 20, initialSpringVelocity: 15, options: [], animations: {() -> Void in
            move?.frame = beginFrame!
        }, completion: {(_ finished: Bool) -> Void in
            cell?.isHidden = false
            transitionContext.completeTransition(true)
        })
    }
}
 }

class PhotoViewController: BaseController {
    
    weak var delegate: PhotoViewControllerDelegate?
    
    lazy var imageView: ImageView = {
        let imageView = ImageView()
        return imageView
    }()
    
    lazy var closeButton: Button = {
        let button = Button()
        button.setImage(#imageLiteral(resourceName: "ic_x"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(close(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var menuButton: Button = {
        let button = Button()
        button.setImage(#imageLiteral(resourceName: "ic_dots"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(menuClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    private var photo: UserPhoto?
    
    init(image: UserPhoto) {
        super.init(nibName: nil, bundle: nil)
        self.photo = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        super.configure()
        self.view.backgroundColor = .black
        
        self.view.addSubview(closeButton)
        self.view.addSubview(menuButton)
        self.view.addSubview(imageView)
        
        closeButton.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(36)
        }
        
        menuButton.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(50)
            make.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        
        imageView.setImageFromUrl(photo?.url)
    }
    
    @objc private func close(sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func menuClicked(sender: Any) {
        let actionDelete = UIAlertAction(title: "Yes", style: .destructive) { _ in
            if let photo = self.photo {
                self.delegate?.willDeletePhoto(photo: photo)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        showActionSheetWith(actions: [actionDelete, actionCancel], title: "Do you want to delete the photo ?")
    }
}
