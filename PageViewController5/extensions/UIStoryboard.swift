//
//  UIStoryboard.swift
//  PageViewController5
//
//  Created by 奥江英隆 on 2024/05/29.
//

import Foundation
import UIKit

extension UIStoryboard {
    static let latestStoryboard = UIStoryboard(name: String(describing: LatestViewController.self), bundle: nil)
    static let programStoryboard = UIStoryboard(name: String(describing: ProgramViewController.self), bundle: nil)
    static let downloadStoryboard = UIStoryboard(name: String(describing: DownloadViewController.self), bundle: nil)
    static let playListStoryboard = UIStoryboard(name: String(describing: PlayListViewController.self), bundle: nil)
}
