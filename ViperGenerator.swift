#!/usr/bin/env swift

//
//  ViperGenerator.swift
//
//  Adapted by Danilo Camarotto on 06/10/18.
//  Original template, called "Vipera", was downloaded from theswiftdev.com.
//

/*
 *  To use this code generator, just tipe ./ViperGenerator ModuleName from the terminal.
 *
 *  ModuleName must be replaced by the name of the module you want to generate.
 *
 */

import Foundation

guard CommandLine.arguments.count > 1 else {
    print("You have to to provide a module name as the first argument.")
    exit(-1)
}

func getUserName(_ args: String...) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.launchPath = "/usr/bin/env"
    task.arguments = ["git", "config", "--global", "user.name"]
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "VIPERA"
    task.waitUntilExit()
    return output
}

let userName = getUserName()
let project  = "GitHubAPI"
let company  = "DanCamarotto"
let module      = CommandLine.arguments[1]
let fileManager = FileManager.default

let workPath       = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let modulePath     = workPath.appendingPathComponent(module)
let contractPath   = modulePath.appendingPathComponent("Contract")
let viewPath       = modulePath.appendingPathComponent("View")
let interactorPath = modulePath.appendingPathComponent("Interactor")
let presenterPath  = modulePath.appendingPathComponent("Presenter")
let entityPath     = modulePath.appendingPathComponent("Entity")
let routerPath     = modulePath.appendingPathComponent("Router")

let contractUrl   = contractPath.appendingPathComponent(module + "Contract").appendingPathExtension("swift")
let viewUrl       = viewPath.appendingPathComponent(module + "ViewController").appendingPathExtension("swift")
let interactorUrl = interactorPath.appendingPathComponent(module + "Interactor").appendingPathExtension("swift")
let presenterUrl  = presenterPath.appendingPathComponent(module + "Presenter").appendingPathExtension("swift")
let entityUrl     = entityPath.appendingPathComponent(module + "Entity").appendingPathExtension("swift")
let routerUrl     = routerPath.appendingPathComponent(module + "Router").appendingPathExtension("swift")

func fileComment(for module: String, type: String) -> String {
    let today    = Date()
    let calendar = Calendar(identifier: .gregorian)
    let year     = String(calendar.component(.year, from: today))
    let month    = String(format: "%02d", calendar.component(.month, from: today))
    let day      = String(format: "%02d", calendar.component(.day, from: today))

    return """
        //
        //  \(module)\(type).swift
        //  \(project)
        //
        //  Created by \(userName) on \(day)/\(month)/\(year).
        //  Copyright © \(year) \(company). All rights reserved.
        //
        """
}

let contract = """
\(fileComment(for: module, type: "Contract"))

import UIKit

protocol \(module)View: class{
    var presenter: \(module)Presentation! { get set }
}

protocol \(module)Presentation: class {
    var view: \(module)View? { get set }
    var interactor: \(module)UseCase! { get set }
    var router: \(module)Wireframe! { get set }
}

protocol \(module)UseCase: class {
    var output: \(module)InteractorOutput? { get set }
}

protocol \(module)InteractorOutput: class {
}

protocol \(module)Wireframe: class {
    var viewController: UIViewController? { get set }

    static func assembleModule() -> UIViewController
}

"""

let view = """
\(fileComment(for: module, type: "ViewController"))

import UIKit

class \(module)ViewController: UIViewController, \(module)View {

    var presenter: \(module)Presentation!

}

"""

let interactor = """
\(fileComment(for: module, type: "Interactor"))

import UIKit

class \(module)Interactor: \(module)UseCase {

    weak var output: \(module)InteractorOutput?

}

"""

let presenter = """
\(fileComment(for: module, type: "Presenter"))

import Foundation

class \(module)Presenter: \(module)Presentation, \(module)InteractorOutput {

    weak var view: \(module)View?
    var interactor: \(module)UseCase!
    var router: \(module)Wireframe!

}

"""

let router = """
\(fileComment(for: module, type: "Router"))

import UIKit

class \(module)Router: \(module)Wireframe {

    weak var viewController: UIViewController?

    static func assembleModule() -> UIViewController {
        let view = \(module)ViewController()
        let presenter = \(module)Presenter()
        let interactor = \(module)Interactor()
        let router = \(module)Router()

        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        router.viewController = view

        return view
    }

}

"""

do {
    let paths = [modulePath, contractPath, viewPath, interactorPath, presenterPath, entityPath, routerPath]
    try paths.forEach {
        try fileManager.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }

    try contract.write(to: contractUrl, atomically: true, encoding: .utf8)
    try view.write(to: viewUrl, atomically: true, encoding: .utf8)
    try interactor.write(to: interactorUrl, atomically: true, encoding: .utf8)
    try presenter.write(to: presenterUrl, atomically: true, encoding: .utf8)
    try router.write(to: routerUrl, atomically: true, encoding: .utf8)
}
catch {
    print(error.localizedDescription)
}
