//
//  ViewController.swift
//  PageViewController5
//
//  Created by 奥江英隆 on 2024/05/29.
//

import UIKit

class ViewController: UIViewController {
    
    private enum Tag: Int {
        case latest = 0
        case program
        case download
        case playlist
    }
    
    private enum ButtonPosition: Int {
        case after = 1
        case current = 0
        case previous = -1
    }
    
    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var animationViewWidthConstraint: NSLayoutConstraint!
    
    private let viewControllers: [UIViewController] = [
        UIStoryboard.latestStoryboard.instantiateInitialViewController()!,
        UIStoryboard.programStoryboard.instantiateInitialViewController()!,
        UIStoryboard.downloadStoryboard.instantiateInitialViewController()!,
        UIStoryboard.playListStoryboard.instantiateInitialViewController()!
    ]
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    private var screenWidth: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError()
        }
        return windowScene.screen.bounds.width
    }
    
    private var afterButtonCenterX: CGFloat {
        return if viewControllers.count > currentPage + 1 {
            stackView.arrangedSubviews.compactMap {
                $0 as? UIButton
            }[currentPage + 1].center.x - firstButtonCenterX
        } else {
            0
        }
    }
    
    private var currentButtonCenterX: CGFloat {
        return stackView.arrangedSubviews.compactMap {
            $0 as? UIButton
        }[currentPage].center.x - firstButtonCenterX
    }
    
    private var previousButtonCenterX: CGFloat {
        return if 0 < currentPage - 1 {
            stackView.arrangedSubviews.compactMap {
                $0 as? UIButton
            }[currentPage - 1].center.x - firstButtonCenterX
        } else {
            0
        }
    }
    
    private var firstButtonCenterX: CGFloat {
        guard let firstButton = stackView.arrangedSubviews.first as? UIButton else {
            fatalError("")
        }
        return firstButton.center.x
    }
    private var tag: Tag = .latest

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    private func setupPageViewController() {
        pageViewController.view.subviews.forEach {
            if let scrollView = $0 as? UIScrollView {
                scrollView.delegate = self
            }
        }
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageContainerView.addSubview(pageViewController.view)
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor)
        ])
        pageViewController.setViewControllers([viewControllers.first!],
                                              direction: .forward,
                                              animated: false)
    }
    
    private func getButtonWidth(at buttonIndex: ButtonPosition) -> CGFloat {
        if currentPage >= viewControllers.count - 1 {
            return switch buttonIndex {
            case .after:
                0
            default:
                stackView.arrangedSubviews.map {
                    $0.bounds.width
                }[currentPage + buttonIndex.rawValue]
            }
        } else if tag == .latest {
            return 0
        } else {
            return stackView.arrangedSubviews.map {
                $0.bounds.width
            }[currentPage + buttonIndex.rawValue]
        }
    }
    
    private func animateViewSlide(contentOffsetX: CGFloat) {
        let afterButtonWidth = getButtonWidth(at: .after)
        let currentButtonWidth = getButtonWidth(at: .current)
        let previousButtonWidth = getButtonWidth(at: .previous)
        
        if contentOffsetX == 0 {
            return
        }
        if contentOffsetX > 0 {
            // 次のページ
            switch tag {
            case .latest:
                let translationX = (afterButtonCenterX - currentButtonCenterX) * (contentOffsetX / screenWidth)
                animationView.transform = CGAffineTransform(translationX: translationX, y: 0)
            default:
                if currentPage == viewControllers.count - 1,
                   contentOffsetX > 0 {
                    return
                }
                let translationX = (afterButtonCenterX - currentButtonCenterX) * (contentOffsetX / screenWidth)
                animationView.transform = CGAffineTransform(translationX: translationX + currentButtonCenterX,
                                                            y: 0)
                // viewの幅を変更する
                if currentButtonWidth > afterButtonWidth {
                    let animationViewWidth = (currentButtonWidth - previousButtonWidth) - (currentButtonWidth - afterButtonWidth) * (contentOffsetX / screenWidth)
                    animationViewWidthConstraint.constant = animationViewWidth
                } else {
                    let animationViewWidth = (afterButtonWidth - currentButtonWidth) * (contentOffsetX / screenWidth)
                    animationViewWidthConstraint.constant = animationViewWidth
                }
            }
        } else {
            // 前のページ
            let translationX = (currentButtonCenterX - previousButtonCenterX) * (contentOffsetX / screenWidth)
            animationView.transform = CGAffineTransform(translationX: translationX + currentButtonCenterX, y: 0)
            
            // viewの幅を変更する
            if currentButtonWidth < previousButtonWidth {
                let animationViewWidth = (previousButtonWidth - currentButtonWidth) + -(previousButtonWidth - currentButtonWidth) * (contentOffsetX / screenWidth)
                animationViewWidthConstraint.constant = animationViewWidth
            } else {
                let animationViewWidth = currentButtonWidth + (currentButtonWidth - previousButtonWidth) * (contentOffsetX / screenWidth)
                animationViewWidthConstraint.constant = animationViewWidth - previousButtonWidth
            }
        }
    }
}

extension ViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let viewController = pageViewController.viewControllers?.first,
           let index = viewControllers.firstIndex(of: viewController) {
            if completed {
                currentPage = index
                tag = Tag(rawValue: index) ?? .latest
            }
        }
    }
}

extension ViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 次のページを取得する
        if let index = viewControllers.firstIndex(of: viewController),
           viewControllers.count - 1 > index {
            return viewControllers[index + 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 前のページを取得する
        if let index = viewControllers.firstIndex(of: viewController),
           0 < index {
            return viewControllers[index - 1]
        }
        return nil
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animateViewSlide(contentOffsetX: scrollView.contentOffset.x - screenWidth)
    }
}

