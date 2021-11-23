//
//  ImageLoadOperation.swift
//  Sparks
//
//  Created by Nika Samadashvili on 9/2/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit

import Foundation

extension AsyncOperation {
  public enum State: String {
    case ready, executing, finished

    fileprivate var keyPath: String {
      "is\(rawValue.capitalized)"
    }
  }
}

open class AsyncOperation: Operation {
  // Create state management
  public var state = State.ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }


  override open var isReady: Bool {
    super.isReady && state == .ready
  }

  override open var isExecuting: Bool {
    state == .executing
  }

  override open var isFinished: Bool {
    state == .finished
  }

  override open func cancel() {
    state = .finished
  }
  override open var isAsynchronous: Bool {
    true
  }


  override open func start() {
    if isCancelled {
      state = .finished
      return
    }
    main()
    state = .executing
  }

}



class ImageLoadOperation: AsyncOperation {
  private let url: URL
  var image: UIImage?

  init(url: URL) {
    self.url = url
    super.init()
  }
  

  override func main() {
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      guard let self = self else { return }
      defer { self.state = .finished }
      guard error == nil, let data = data else { return }
      self.image = UIImage(data: data)
    }.resume()
  }
}
