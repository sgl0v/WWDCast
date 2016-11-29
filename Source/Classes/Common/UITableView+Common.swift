//
//  UITableViewExtensions.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

protocol NibProvidable {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension NibProvidable {
    static var nibName: String {
        return "\(self)"
    }
    static var nib: UINib {
        return UINib(nibName: self.nibName, bundle: nil)
    }
}

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

protocol BindableView {
    associatedtype ViewModel
    func bind(viewModel: ViewModel)
}

// Cell
extension UITableView {
    func registerClass<T : UITableViewCell>(cellClass `class`: T.Type) where T: ReusableView {
        register(`class`, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    func registerNib<T: UITableViewCell>(cellClass `class`: T.Type) where T: NibProvidable & ReusableView {
        register(`class`.nib, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(withClass `class`: T.Type) -> T? where T: ReusableView {
        return self.dequeueReusableCell(withIdentifier: `class`.reuseIdentifier) as? T
    }

    func dequeueReusableCell<T: UITableViewCell>(withClass `class`: T.Type, forIndexPath indexPath: IndexPath) -> T! where T: ReusableView {
        guard let cell = self.dequeueReusableCell(withIdentifier: `class`.reuseIdentifier, for: indexPath) as? T else {
            assert(false, "Error: cell with identifier: \(`class`.reuseIdentifier) for index path: \(indexPath) is not \(T.self)")
            return nil
        }
        return cell
    }
}

// Header / Footer
extension UITableView {
    func registerHeaderFooterClass<T: UITableViewHeaderFooterView>(headerFooterClass `class`: T.Type) where T: ReusableView {
        register(`class`, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    func registerHeaderFooterNib<T: UITableViewHeaderFooterView>(forHeaderFooterClass `class`: T.Type) where T: NibProvidable &  ReusableView {
        register(`class`.nib, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    func dequeueResuableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass `class`: T.Type) -> T? where T: ReusableView {
        return dequeueReusableHeaderFooterView(withIdentifier: `class`.reuseIdentifier) as? T
    }
}


