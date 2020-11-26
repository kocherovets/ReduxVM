//
//  Command.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 02.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import Foundation

public class CommandLogger {
    
    public static var logger: ((String) -> ())?
}

open class Command: Codable {

    public init(id: String = "",
         file: StaticString = #file,
         function: StaticString = #function,
         line: Int = #line,
         action: @escaping () -> ())
    {
        self.id = id
        self.action = action
        self.function = function
        self.file = file
        self.line = line
    }

    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let id: String

    private let action: () -> ()

    open func perform() {
        if let debugQuickLookObject = debugQuickLookObject() as? String {
            CommandLogger.logger?(debugQuickLookObject)
        }
        action()
    }

    static let nop = Command { }

    /// Support for Xcode quick look feature.
    @objc
    open func debugQuickLookObject() -> AnyObject? {
        return """
            ---COMMAND---
            file: \(file):\(line)
            function: \(function)
            .
            """ as NSString
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init { }
    }

    open func encode(to encoder: Encoder) throws { }
}

extension Command: Equatable {

    public static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Command: Hashable {

    open func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public final class CommandWith<T> {
    
    public init(id: String = "",
         file: StaticString = #file,
         function: StaticString = #function,
         line: Int = #line,
         action: @escaping (T) -> ()) {

        self.action = action

        self.id = id
        self.function = function
        self.file = file
        self.line = line
    }

    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let id: String

    private let action: (T) -> ()

    public func perform(with value: T) {
        if let debugQuickLookObject = debugQuickLookObject() as? String {
            CommandLogger.logger?("\(debugQuickLookObject)\nparameter: \(value)")
        }
        action(value)
    }

    /// Support for Xcode quick look feature.
    @objc
    public func debugQuickLookObject() -> AnyObject? {
        return """
                ---COMMAND---
                file: \(file):\(line)
                function: \(function)
                .
               """ as NSString
    }

    public func bind(to value: T) -> Command {
        return Command { self.perform(with: value) }
    }

    public static var nop: CommandWith {
        return CommandWith { _ in }
    }

    public func dispatched(on queue: DispatchQueue) -> CommandWith {
        return CommandWith { value in
            queue.async {
                self.perform(with: value)
            }
        }
    }

    public func then(_ another: CommandWith) -> CommandWith {
        return CommandWith { value in
            self.perform(with: value)
            another.perform(with: value)
        }
    }
}

extension CommandWith: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CommandWith: Equatable {

    public static func == (lhs: CommandWith, rhs: CommandWith) -> Bool {
        return lhs.id == rhs.id
    }
}


extension CommandWith: Codable {
    convenience public init(from decoder: Decoder) throws {
        self.init { _ in }
    }

    public func encode(to encoder: Encoder) throws { }
}

extension CommandWith {
    public func map<U>(transform: @escaping (U) -> T) -> CommandWith<U> {
        return CommandWith<U> { u in
            self.perform(with: transform(u))
        }
    }
}

