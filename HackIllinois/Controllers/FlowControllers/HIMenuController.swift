//
//  HIMenuController.swift
//  HackIllinois
//
//  Created by Rauhul Varma on 11/23/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//

import Foundation
import UIKit

class HIMenuController: UIViewController {
    // MARK: - Types
    enum State {
        case open
        case closed
    }

    // MARK: - Constants
    private let MENU_ITEM_HEIGHT: CGFloat = 58
    // TODO: Introduce MENU_MAX_HEIGHT, add scroll bar if menu height is larger than this value

    // MARK: - Properties
    private(set) var state = State.closed

    private(set) var _tabBarController = UITabBarController()

    var overlayView = UIView()
    var menuItems = UIStackView()

    var menuHeight = NSLayoutConstraint()
    var menuOverlap = NSLayoutConstraint()
    var menuItemsHeight = NSLayoutConstraint()
}

// MARK: - Actions
extension HIMenuController {
    func setupMenuFor(_ viewControllers: [UIViewController]) {
        _tabBarController.viewControllers = viewControllers.map {
            _ = $0.view // forces viewDidLoad to run, allows .title to be accessible
            $0.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuOpen"), style: .plain, target: self, action: #selector(HIMenuController.open))
            let navigationController = UINavigationController(rootViewController: $0)
            navigationController.title = $0.title

            return navigationController
        }

        if view != nil {
            resetMenuItems()
            createMenuItems()
        }
    }

    @objc func open(_ sender: Any) {
        guard state != .open else { return }
        state = .open
        animateMenuFor(state)
    }

    @objc func close(_ sender: Any) {
        guard state != .closed else { return }
        state = .closed
        animateMenuFor(state)
    }

    @objc private func didSelectItem(_ sender: UIButton) {
        _tabBarController.selectedIndex = sender.tag
        close(sender)
    }
}

// MARK: - UIViewController
extension HIMenuController {
    override func loadView() {
        view = UIView()

        _tabBarController.tabBar.isHidden = true
        addChildViewController(_tabBarController)
        _tabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(_tabBarController.view)
        _tabBarController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        _tabBarController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        _tabBarController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        _tabBarController.view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        _tabBarController.didMove(toParentViewController: self)

        overlayView.backgroundColor = HIApplication.Color.darkBlueGrey
        overlayView.alpha = 0.0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        overlayView.topAnchor.constraint(equalTo: _tabBarController.view.topAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: _tabBarController.view.leadingAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: _tabBarController.view.bottomAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: _tabBarController.view.trailingAnchor).isActive = true

        let menu = UIView()
        menu.backgroundColor = HIApplication.Color.paleBlue
        menu.clipsToBounds = true
        menu.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menu)
        menu.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menu.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        menuOverlap = menu.bottomAnchor.constraint(equalTo: _tabBarController.view.topAnchor)
        menuOverlap.isActive = true
        menu.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        menuHeight = menu.heightAnchor.constraint(equalToConstant: 0)
        menuHeight.isActive = true

        let closeMenuButton = UIButton(type: .system)
        closeMenuButton.setImage(#imageLiteral(resourceName: "MenuClose"), for: .normal)
        closeMenuButton.tintColor = HIApplication.Color.hotPink
        closeMenuButton.addTarget(self, action: #selector(HIMenuController.close(_:)), for: .touchUpInside)
        closeMenuButton.translatesAutoresizingMaskIntoConstraints = false
        menu.addSubview(closeMenuButton)
        closeMenuButton.topAnchor.constraint(equalTo: menu.safeAreaLayoutGuide.topAnchor, constant: -9).isActive = true
        closeMenuButton.leadingAnchor.constraint(equalTo: menu.safeAreaLayoutGuide.leadingAnchor, constant: 3).isActive = true
        closeMenuButton.widthAnchor.constraint(equalToConstant: 49).isActive = true
        closeMenuButton.heightAnchor.constraint(equalToConstant: 49).isActive = true

        menuItems.axis = .vertical
        menuItems.distribution = .fillEqually
        menuItems.translatesAutoresizingMaskIntoConstraints = false
        menu.addSubview(menuItems)
        menuItems.topAnchor.constraint(equalTo: menu.safeAreaLayoutGuide.topAnchor, constant: 11).isActive = true
        menuItems.leadingAnchor.constraint(equalTo: menu.safeAreaLayoutGuide.leadingAnchor, constant: 59).isActive = true
        menuItems.trailingAnchor.constraint(equalTo: menu.safeAreaLayoutGuide.trailingAnchor, constant: -59).isActive = true
        menuItemsHeight = menuItems.heightAnchor.constraint(equalToConstant: 0)
        menuItemsHeight.isActive = true

        let overlayViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HIMenuController.close(_:)))
        overlayView.addGestureRecognizer(overlayViewTapGestureRecognizer)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        resetMenuItems()
        createMenuItems()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_) in
            self.animateMenuFor(self.state)
        }, completion: nil)
    }
}

// MARK: - Animation
extension HIMenuController {
    private func updateConstraintsFor(_ state: State) {
        switch state {
        case .open:
            menuHeight.constant = menuItemsHeight.constant + 11 + 28 + view.safeAreaInsets.top
            menuOverlap.constant = view.safeAreaInsets.top

        case .closed:
            menuHeight.constant = 0
            menuOverlap.constant = 0
        }
    }

    private func updateOverlayViewAlphaFor(_ state: State) {
        switch state {
        case .open:
            overlayView.alpha = 0.70

        case .closed:
            overlayView.alpha = 0.0
        }
    }

    private func animateMenuFor(_ state: State) {
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8)
        view.layoutIfNeeded()
        updateConstraintsFor(state)
        animator.addAnimations {
            self.updateOverlayViewAlphaFor(state)
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}

// MARK: - Menu Item Setup
extension HIMenuController {
    private func resetMenuItems() {
        menuItems.arrangedSubviews.forEach { (view) in
            menuItems.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        menuItemsHeight.constant = 0
    }

    private func createMenuItems() {
        let viewControllers = _tabBarController.viewControllers ?? []
        menuItemsHeight.constant = CGFloat(viewControllers.count) * MENU_ITEM_HEIGHT
        for (index, viewController) in viewControllers.enumerated() {
            let button = createMenuItem(title: viewController.title, index: index)
            button.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
            menuItems.addArrangedSubview(button)
        }
    }

    private func createMenuItem(title: String?, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = index
        button.contentHorizontalAlignment = .left
        button.setTitle(title, for: .normal)
        button.setTitleColor(HIApplication.Color.darkIndigo, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }
}
