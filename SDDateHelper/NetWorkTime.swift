//
//  NetWorkTime.swift
//  Pods
//
//  Created by Ngoc Duong Phan on 9/22/17.
//
//

import Foundation
import NTPKit


enum HostName: String {
  case Pool1 = "time1.google.com"
  case Pool2 = "time2.google.com"
  case Pool3 = "time3.google.com"
  case Pool4 = "time4.google.com"
}

enum Port: UInt {
  case defaultPort = 123
}

class NetworkTime {
  fileprivate static let shareInstance = NetworkTime()
  var activeTime =  Date()
  var stopwatch = Stopwatch()
}

public class SDTime {

  public var now : Date {
    let activeTime = NetworkTime.shareInstance.activeTime
    let elapseTime = NetworkTime.shareInstance.stopwatch.elapsedTime
    return activeTime + elapseTime.second
  }

  public init() {
    //init
  }
  fileprivate var HostsName: [String] {
    return [HostName.Pool1.rawValue,HostName.Pool2.rawValue,HostName.Pool3.rawValue,HostName.Pool4.rawValue]
  }

  fileprivate var hostIndex = 0

  func getTime(with hostsName: [String],completion: @escaping (Date) -> Void) {
    guard hostIndex < hostsName.count else {
      completion(Date())
      return
    }
    let hostName = hostsName[hostIndex]
    let ntpServer = NTPServer(hostname: hostName, port: Port.defaultPort.rawValue)
    do {
      let date = try ntpServer.date()
      completion(date)
    } catch {
      hostIndex += 1
      getTime(completion: completion)
    }
  }

  public func getNetworkTime(with hostsName: [String],completion: @escaping (Date) -> Void) {
    self.getTime(with: hostsName) { (date) in
      self.hostIndex = 0
      NetworkTime.shareInstance.activeTime = date
      NetworkTime.shareInstance.stopwatch = Stopwatch()
      completion(date)
    }
  }

  public func getNetworkTime(completion: @escaping (Date) -> Void) {
    self.getTime { (date) in
      self.hostIndex = 0
      NetworkTime.shareInstance.activeTime = date
      NetworkTime.shareInstance.stopwatch = Stopwatch()
      completion(date)
    }
  }

  func getTime(completion: @escaping (Date) -> Void) {
    guard hostIndex < HostsName.count else {
      completion(Date())
      return
    }
    let hostName = HostsName[hostIndex]
    let ntpServer = NTPServer(hostname: hostName, port: Port.defaultPort.rawValue)
    do {
      let date = try ntpServer.date()
      completion(date)
    } catch {
      hostIndex += 1
      getTime(completion: completion)
    }
  }
}
