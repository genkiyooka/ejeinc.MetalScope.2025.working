//
//  XibViewController.swift
//  MetalSkybox
//
//  Created by dg on 6/9/25.
//

import UIKit

@objc
public class XibViewController: UIViewController {

    static func imported() -> Void {
        }

    private static var xibNameFromClassName: String {
        return String(describing: self)
    }

    private static var xibClassBundle: Bundle {
        return Bundle(for: self)
    }

    public required init?(coder: NSCoder) {
        print("EulerViewController.init?(coder: NSCoder)")
        super.init(nibName: Self.xibNameFromClassName, bundle: Self.xibClassBundle)
    }

	public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: Self.xibNameFromClassName, bundle: Self.xibClassBundle)
    }
      
	public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
	@IBOutlet weak var outletTitle: UILabel!

	var viewTitle: NSString = "" {
		didSet {
			outletTitle.text = viewTitle as String
			}
		}

	// Assume you're in a UIViewController subclass
	func embed(title:String, containerVC:UIViewController, containerView:UIView) {
	let childVC = self
		// 1. Instantiate the view controller (from storyboard or directly)
		// 2. Add as child
		containerVC.addChild(childVC)
		// 3. Configure its view's frame and autoresizing
		childVC.view.frame = containerView.bounds
		childVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		childVC.view.translatesAutoresizingMaskIntoConstraints = true
		// 4. Add the view
		containerView.addSubview(childVC.view)
		// 5. Notify the child view controller
		childVC.didMove(toParent:containerVC)
		
		childVC.viewTitle = title as NSString
		}
}
