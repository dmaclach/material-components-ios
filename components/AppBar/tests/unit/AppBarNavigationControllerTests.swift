// Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
import MaterialComponents.MaterialAppBar

private class MockAppBarNavigationControllerDelegate:
    NSObject, MDCAppBarNavigationControllerDelegate {
  var trackingScrollView: UIScrollView?
  func appBarNavigationController(_ navigationController: MDCAppBarNavigationController,
                                  trackingScrollViewFor trackingScrollViewForViewController: UIViewController,
                                  suggestedTrackingScrollView: UIScrollView?) -> UIScrollView? {
    return trackingScrollView
  }
}

class AppBarNavigationControllerTests: XCTestCase {

  var navigationController: MDCAppBarNavigationController!
  override func setUp() {
    super.setUp()

    navigationController = MDCAppBarNavigationController()
  }

  override func tearDown() {
    navigationController = nil

    super.tearDown()
  }

  func testInitializingWithRootViewControllerInjectsAnAppBar() {
    // Given
    let viewController = UIViewController()

    // When
    let navigationController = MDCAppBarNavigationController(rootViewController: viewController)

    // Then
    XCTAssertEqual(viewController.childViewControllers.count, 1,
                   "Expected there to be exactly one child view controller added to the view"
                    + " controller.")

    XCTAssertEqual(navigationController.topViewController, viewController,
                   "The navigation controller's top view controller is supposed to be the pushed"
                    + " view controller, but it is \(viewController).")

    XCTAssertTrue(viewController.childViewControllers.first is MDCFlexibleHeaderViewController,
                  "The injected view controller is not a flexible header view controller, it is"
                    + "\(String(describing: viewController.childViewControllers.first)) instead.")

    if let headerViewController
      = viewController.childViewControllers.first as? MDCFlexibleHeaderViewController {
      XCTAssertEqual(headerViewController.headerView.frame.height,
                     headerViewController.headerView.maximumHeight)
    }
  }

  func testPushingAViewControllerInjectsAnAppBar() {
    // Given
    let viewController = UIViewController()

    // When
    navigationController.pushViewController(viewController, animated: false)

    // Then
    XCTAssertEqual(viewController.childViewControllers.count, 1,
                   "Expected there to be exactly one child view controller added to the view"
                    + " controller.")

    XCTAssertEqual(navigationController.topViewController, viewController,
                   "The navigation controller's top view controller is supposed to be the pushed"
                    + " view controller, but it is \(viewController).")

    XCTAssertTrue(viewController.childViewControllers.first is MDCFlexibleHeaderViewController,
                  "The injected view controller is not a flexible header view controller, it is"
                    + "\(String(describing: viewController.childViewControllers.first)) instead.")

    if let headerViewController
        = viewController.childViewControllers.first as? MDCFlexibleHeaderViewController {
      XCTAssertEqual(headerViewController.headerView.frame.height,
                     headerViewController.headerView.maximumHeight)
    }
  }

  func testSettingAViewControllerInjectsAnAppBar() {
    // Given
    let viewController = UIViewController()

    // When
    navigationController.viewControllers = [viewController]

    // Then
    XCTAssertEqual(viewController.childViewControllers.count, 1,
                   "Expected there to be exactly one child view controller added to the view"
                    + " controller.")

    XCTAssertEqual(navigationController.topViewController, viewController,
                   "The navigation controller's top view controller is supposed to be the pushed"
                    + " view controller, but it is \(viewController).")

    XCTAssertTrue(viewController.childViewControllers.first is MDCFlexibleHeaderViewController,
                  "The injected view controller is not a flexible header view controller, it is"
                    + "\(String(describing: viewController.childViewControllers.first)) instead.")

    if let headerViewController
      = viewController.childViewControllers.first as? MDCFlexibleHeaderViewController {
      XCTAssertEqual(headerViewController.headerView.frame.height,
                     headerViewController.headerView.maximumHeight)
    }
  }

  func testSettingAViewControllerAnimatedInjectsAnAppBar() {
    // Given
    let viewController = UIViewController()

    // When
    navigationController.setViewControllers([viewController], animated: false)

    // Then
    XCTAssertEqual(viewController.childViewControllers.count, 1,
                   "Expected there to be exactly one child view controller added to the view"
                    + " controller.")

    XCTAssertEqual(navigationController.topViewController, viewController,
                   "The navigation controller's top view controller is supposed to be the pushed"
                    + " view controller, but it is \(viewController).")

    XCTAssertTrue(viewController.childViewControllers.first is MDCFlexibleHeaderViewController,
                  "The injected view controller is not a flexible header view controller, it is"
                    + "\(String(describing: viewController.childViewControllers.first)) instead.")

    if let headerViewController
      = viewController.childViewControllers.first as? MDCFlexibleHeaderViewController {
      XCTAssertEqual(headerViewController.headerView.frame.height,
                     headerViewController.headerView.maximumHeight)
    }
  }

  func testPushingAnAppBarContainerViewControllerDoesNotInjectAnAppBar() {
    // Given
    let viewController = UIViewController()
    let container = MDCAppBarContainerViewController(contentViewController: viewController)

    // When
    navigationController.pushViewController(container, animated: false)

    // Then
    XCTAssertEqual(container.childViewControllers.count, 2,
                   "An App Bar container view controller should have exactly two child view"
                    + " controllers. A failure of this assertion implies that the navigation"
                    + " controller may have injected another App Bar.")
  }

  func testPushingAContainedAppBarContainerViewControllerDoesNotInjectAnAppBar() {
    // Given
    let viewController = UIViewController()
    let container = MDCAppBarContainerViewController(contentViewController: viewController)
    let nestedContainer = UIViewController()
    nestedContainer.addChildViewController(container)
    nestedContainer.view.addSubview(container.view)
    #if swift(>=4.2)
    container.didMove(toParent: nestedContainer)
    #else
    container.didMove(toParentViewController: nestedContainer)
    #endif

    // When
    navigationController.pushViewController(nestedContainer, animated: false)

    // Then
    XCTAssertEqual(nestedContainer.childViewControllers.count, 1,
                   "The view controller hierarchy already has one app bar view controller, but it"
                    + " appears to have possibly added another.")
  }

  func testPushingAViewControllerWithAFlexibleHeaderDoesNotInjectAnAppBar() {
    // Given
    let viewController = UIViewController()
    let fhvc = MDCFlexibleHeaderViewController()
    viewController.addChildViewController(fhvc)
    viewController.view.addSubview(fhvc.view)
    #if swift(>=4.2)
    fhvc.didMove(toParent: viewController)
    #else
    fhvc.didMove(toParentViewController: viewController)
    #endif

    // When
    navigationController.pushViewController(viewController, animated: false)

    // Then
    XCTAssertEqual(viewController.childViewControllers.count, 1,
                   "The navigation controller may have injected another App Bar when it shouldn't"
                    + " have.")
  }

  func testStatusBarStyleIsFetchedFromFlexibleHeaderViewController() {
    // Given
    let viewController = UIViewController()

    // When
    navigationController.pushViewController(viewController, animated: false)

    // Then
    let appBar = navigationController.appBar(for: viewController)

    XCTAssertNotNil(appBar, "Could not retrieve the injected App Bar.")

    if let appBar = appBar {
      XCTAssertEqual(navigationController.childViewControllerForStatusBarStyle,
                     appBar.headerViewController,
                     "The navigation controller should be using the injected app bar's flexible"
                      + "header view controller for status bar style updates.")
    }
  }

  func testInfersFirstTrackingScrollViewByDefault() {
    // Given
    let viewController = UIViewController()
    let scrollView1 = UIScrollView()
    viewController.view.addSubview(scrollView1)
    let scrollView2 = UIScrollView()
    viewController.view.addSubview(scrollView2)

    // When
    navigationController.pushViewController(viewController, animated: false)

    // Then
    guard let appBarViewController = navigationController.appBarViewController(for: viewController) else {
      XCTFail("No app bar view controller found.")
      return
    }
    XCTAssertEqual(appBarViewController.headerView.trackingScrollView, scrollView1)
  }

  func testDelegateCanReturnNilTrackingScrollView() {
    // Given
    let viewController = UIViewController()
    let scrollView1 = UIScrollView()
    viewController.view.addSubview(scrollView1)
    let scrollView2 = UIScrollView()
    viewController.view.addSubview(scrollView2)
    let delegate = MockAppBarNavigationControllerDelegate()
    navigationController.delegate = delegate

    // When
    delegate.trackingScrollView = nil
    navigationController.pushViewController(viewController, animated: false)

    // Then
    guard let appBarViewController = navigationController.appBarViewController(for: viewController) else {
      XCTFail("No app bar view controller found.")
      return
    }
    XCTAssertNil(appBarViewController.headerView.trackingScrollView)
  }

  func testDelegateCanPickDifferentTrackingScrollView() {
    // Given
    let viewController = UIViewController()
    let scrollView1 = UIScrollView()
    viewController.view.addSubview(scrollView1)
    let scrollView2 = UIScrollView()
    viewController.view.addSubview(scrollView2)
    let delegate = MockAppBarNavigationControllerDelegate()
    navigationController.delegate = delegate

    // When
    delegate.trackingScrollView = scrollView2
    navigationController.pushViewController(viewController, animated: false)

    // Then
    guard let appBarViewController = navigationController.appBarViewController(for: viewController) else {
      XCTFail("No app bar view controller found.")
      return
    }
    XCTAssertEqual(appBarViewController.headerView.trackingScrollView, scrollView2)
  }
}
