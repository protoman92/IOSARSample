//
//  SettingViewController.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import UIKit

public final class SettingViewController: UIViewController {
  @IBOutlet private weak var distanceTF: UITextField!
  
  private lazy var settings: Settings = Settings(distanceInM: 0)
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Visualize",
      style: .done,
      target: self,
      action: #selector(self.visualize))
    
    self.distanceTF.addTarget(self, action: #selector(self.distanceChanged),
                              for: .editingChanged)
  }
  
  override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.destination {
    case let arController as ARViewController:
      arController.settings = self.settings
      
    default:
      fatalError("Unexpeced segue to \(segue.identifier ?? "")")
    }
  }
  
  @objc func distanceChanged(_ sender: UITextField) {
    sender.text.flatMap(Double.init).map({settings = settings.with(distanceInM: $0)})
  }
  
  @objc func visualize() {
    self.performSegue(withIdentifier: "visualize", sender: nil)
  }
}
