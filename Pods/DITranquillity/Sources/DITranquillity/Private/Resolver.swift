//
//  DIResolver.swift
//  DITranquillity
//
//  Created by Alexander Ivlev on 21/06/16.
//  Copyright © 2016 Alexander Ivlev. All rights reserved.
//

import Foundation

class Resolver {

  init(container: DIContainer) {
    self.container = container // unowned
  }
  
  func resolve<T>(type: T.Type = T.self, name: String? = nil, from framework: DIFramework.Type? = nil) -> T {
    let pType = ParsedType(type: type)
    log(.verbose, msg: "Begin resolve \(description(type: pType))", brace: .begin)
    defer { log(.verbose, msg: "End resolve \(description(type: pType))", brace: .end) }
    
    return gmake(by: make(by: pType, with: name, from: framework, use: nil))
  }
  
  func injection<T>(obj: T, from framework: DIFramework.Type? = nil) {
    log(.verbose, msg: "Begin injection in obj: \(obj)", brace: .begin)
    defer { log(.verbose, msg: "End injection in obj: \(obj)", brace: .end) }

    _ = make(by: ParsedType(obj: obj), with: nil, from: framework, use: obj)
  }

  
  func resolveSingleton(component: Component) {
    log(.verbose, msg: "Begin resolve singleton by component: \(component.info)", brace: .begin)
    defer { log(.verbose, msg: "End resolve singleton by component: \(component.info)", brace: .end) }
    
    _ = makeObject(by: component, use: nil)
  }
  
  func resolve<T>(type: T.Type = T.self, component: Component) -> T {
    let pType = ParsedType(type: type)
    log(.verbose, msg: "Begin resolve \(description(type: pType)) by component: \(component.info)", brace: .begin)
    defer { log(.verbose, msg: "End resolve \(description(type: pType)) by component: \(component.info)", brace: .end) }
    
    return gmake(by: makeObject(by: component, use: nil))
  }

  /// Finds the most suitable components that satisfy the types.
  ///
  /// - Parameters:
  ///   - type: a type
  ///   - name: a name
  ///   - bundle: bundle from whic the call is made
  /// - Returns: components
  func findComponents(by parsedType: ParsedType, with name: String?, from framework: DIFramework.Type?) -> Components {
    let components = Resolver.findComponents(by: parsedType, with: name, from: framework, in: container)
    if let parent = container.parent {
      if components.isEmpty {
        return parent.resolver.findComponents(by: parsedType, with: name, from: framework)
      }

      if parsedType.hasMany
      {
        let parentComponents = parent.resolver.findComponents(by: parsedType, with: name, from: framework)
        return components + parentComponents
      }
    }
    return components
  }

  private static func findComponents(by parsedType: ParsedType, with name: String?, from framework: DIFramework.Type?, in container: DIContainer) -> Components {
    func defaults(_ components: Components) -> Components {
      let filtering = ContiguousArray(components.filter{ $0.isDefault })
      return filtering.isEmpty ? components : filtering
    }
    
    func filter(by framework: DIFramework.Type?, _ components: Components) -> Components {
      if components.count <= 1 {
        return components
      }
      
      /// check into self bundle
      if let framework = framework {
        /// get all components in bundle
        let filteredByFramework = ContiguousArray(components.filter{ $0.framework.map{ framework == $0 } ?? false })
        
        func componentsIsNeedReturn(_ components: Components) -> Components? {
          let filtered = defaults(components)
          return 1 == filtered.count ? filtered : nil
        }
        
        if let components = componentsIsNeedReturn(filteredByFramework) {
          return components
        }
        
        /// get direct dependencies
        let filteredByChilds = container.frameworksDependencies.filterByChilds(for: framework, components: components)
        
        if let components = componentsIsNeedReturn(filteredByChilds) {
          return components
        }
      }
      
      return defaults(components)
    }

    /// type without optional
    var type = parsedType.firstNotSwiftType
    /// real type without many, tags, optional
    let simpleType = parsedType.base
    var components = Set<Component>()
    var filterByFramework: Bool = true

    var first: Bool = true
    repeat {
      let currentComponents: Set<Component>
      if let sType = type.sType, let parent = type.parent {
        if sType.many {
            currentComponents = container.componentContainer[ShortTypeKey(by: simpleType.type)]
            filterByFramework = filterByFramework && sType.inFramework /// filter
        } else if sType.tag {
            currentComponents = container.componentContainer[TypeKey(by: simpleType.type, tag: sType.tagType)]
        } else if sType.delayed {
          // ignore - delayed type don't change components list
          type = parent.firstNotSwiftType
          continue
        } else {
          currentComponents = container.componentContainer[TypeKey(by: simpleType.type)]
        }

        type = parent.firstNotSwiftType
      } else if let name = name {
        currentComponents = container.componentContainer[TypeKey(by: simpleType.type, name: name)]
      } else {
        currentComponents = container.componentContainer[TypeKey(by: simpleType.type)]
      }

      /// it's not equals components.isEmpty !!!
      components = first ? currentComponents : components.intersection(currentComponents)
      first = false
      
    } while type != simpleType || first /*check on first need only for delayed types*/
    
    if filterByFramework {
      return filter(by: framework, Components(components))
    }
    
    return Components(components)
  }
  
  /// Remove components who doesn't have initialization method
  ///
  /// - Parameter components: Components from which will be removed
  /// - Returns: components Having a initialization method
  func removeWhoDoesNotHaveInitialMethod(components: Components) -> Components {
    return Components(components.filter { nil != $0.initial })
  }
  
  /// Remove all cache objects in container
  func clean() {
    mutex.sync { cache.containerStorage.clean() }
  }
  
  private func make(by parsedType: ParsedType, with name: String?, from framework: DIFramework.Type?, use object: Any?) -> Any? {
    log(.verbose, msg: "Begin make \(description(type: parsedType))", brace: .begin)
    defer { log(.verbose, msg: "End make \(description(type: parsedType))", brace: .end) }

    var components: Components = findComponents(by: parsedType, with: name, from: framework)

    return mutex.sync {
      if parsedType.hasMany {
          //isManyRemove objects contains in stack for exclude cycle initialization
          components = components.filter{ !stack.contains($0.info) }
      }

      if let delayMaker = parsedType.delayMaker {
        let saveGraph = cache.graph

        func makeDelayMaker(by parsedType: ParsedType, components: Components) -> Any? {
          return delayMaker.init(container, { () -> Any? in
            return self.mutex.sync {
              self.cache.graph = saveGraph.toStrongCopy()
              return self.make(by: parsedType, components: components, use: object)
            }
          })
        }

        if parsedType.hasMany, let subPType = parsedType.nextParsedTypeAfterManyOrBreakIfDelayed() {
          // hard logic for support Many<Lazy<Type>> and Many<Provider<Type>> but Many<Many<Lazy<Type>>> not supported
          return components.sorted{ $0.order < $1.order }.compactMap {
            return makeDelayMaker(by: subPType, components: Components([$0]))
          }
        } else {
          return makeDelayMaker(by: parsedType, components: components)
        }
      }

      return make(by: parsedType, components: components, use: object)
    }
  }

  /// isMany for optimization
  private func make(by parsedType: ParsedType, components: Components, use object: Any?) -> Any? {
    GlobalState.lastComponent = components.first?.info

    if parsedType.hasMany {
      assert(nil == object, "Many injection not supported")
      return components.sorted{ $0.order < $1.order }.compactMap{ makeObject(by: $0, use: nil) }
    }

    if let component = components.first, 1 == components.count {
      return makeObject(by: component, use: object)
    }

    if components.isEmpty {
      log(.info, msg: "Not found \(description(type: parsedType))")
    } else {
      let infos = components.map{ $0.info }
      log(.warning, msg: "Ambiguous \(description(type: parsedType)) contains in: \(infos)")
    }

    return nil
  }
  
  /// Super function
  private func makeObject(by component: Component, use usingObject: Any?) -> Any? {
    log(.verbose, msg: "Found component: \(component.info)")

    let uniqueKey = component.info
    
    func makeObject(scope: DIScope) -> Any? {
      var optCacheObject: Any? = scope.storage.fetch(key: uniqueKey)
      if let weakRef = optCacheObject as? WeakAny {
        optCacheObject = weakRef.value
      }
      
      if let cacheObject = getReallyObject(optCacheObject) {
        /// suspending ignore injection for new object
        guard let usingObject = usingObject else {
          log(.verbose, msg: "Resolve object: \(cacheObject) use scope: \(scope.name)")
          return cacheObject
        }
        
        /// suspending double injection
        if cacheObject as AnyObject === usingObject as AnyObject {
          log(.verbose, msg: "Resolve object: \(cacheObject) use scope: \(scope.name)")
          return cacheObject
        }
      }
      
      if let makedObject = makeObject() {
        let objectForSave = (.weak == scope.policy) ? WeakAny(value: makedObject) : makedObject
        scope.storage.save(object: objectForSave, by: uniqueKey)
        log(.verbose, msg: "Save object: \(makedObject) to scope \(scope.name)")
        return makedObject
      }
      
      return nil
    }

    func getArgumentObject() -> Any? {
      guard let extensions = container.extensionsContainer.optionalGet(by: component.info) else {
        log(.error, msg: "Until get argument. Not found extensions for \(component.info)")
        return nil
      }
      return extensions.getNextArg()
    }
    
    func makeObject() -> Any? {
      guard let initializedObject = initialObject() else {
        return nil
      }

      for injection in component.injections {
        if injection.cycle {
          cache.cycleInjectionQueue.append((initializedObject, injection.signature))
        } else {
          _ = use(signature: injection.signature, usingObject: initializedObject)
        }
      }
      
      if let signature = component.postInit {
        if component.injections.contains(where: { $0.cycle }) {
          cache.cycleInjectionQueue.append((initializedObject, signature))
        } else {
          _ = use(signature: signature, usingObject: initializedObject)
        }
      }
      
      return initializedObject
    }
    
    func initialObject() -> Any? {
      if let obj = usingObject {
        log(.verbose, msg: "Use object: \(obj)")
        return obj
      }
      
      if let signature = component.initial {
        let obj = use(signature: signature, usingObject: nil)
        log(.verbose, msg: "Create object: \(String(describing: obj))")
        return obj
      }
      
      log(.warning, msg: "Can't found initial method in \(component.info)")
      return nil
    }
    
    func endResolving() {
      while !cache.cycleInjectionQueue.isEmpty {
        let data = cache.cycleInjectionQueue.removeFirst()
        _ = use(signature: data.signature, usingObject: data.obj)
      }

      cache.graph.toWeak() // Needs for delay maker - because DIScore is retained, but need objects removed if can
      cache.graph = Cache.makeGraphScope()
    }
    
    func use(signature: MethodSignature, usingObject: Any?) -> Any? {
      var objParameters = [Any?]()
      for parameter in signature.parameters {
        let makedObject: Any?
        if parameter.parsedType.useObject {
          makedObject = usingObject
        } else if parameter.parsedType.arg {
          makedObject = getArgumentObject()
        } else {
          makedObject = make(by: parameter.parsedType, with: parameter.name, from: component.framework, use: nil)
        }
        
        if nil != makedObject || parameter.parsedType.hasOptional {
          objParameters.append(makedObject)
          continue
        }
        
        return nil
      }

      return signature.call(objParameters)
    }


    stack.append(component.info)
    defer {
      if 1 == stack.count {
        endResolving()
      }
      stack.removeLast()
    }

    switch component.lifeTime {
    case .single:
      return makeObject(scope: Cache.single)
    case .perRun(let referenceCounting):
      switch referenceCounting {
      case .weak: return makeObject(scope: Cache.weakPerRun)
      case .strong: return makeObject(scope: Cache.strongPerRun)
      }
    case .perContainer(let referenceCounting):
      switch referenceCounting {
      case .weak: return makeObject(scope: cache.weakPerContainer)
      case .strong: return makeObject(scope: cache.strongPerContainer)
      }
    case .objectGraph:
      return makeObject(scope: cache.graph)
    case .prototype:
      return makeObject()
    case .custom(let scope):
      return makeObject(scope: scope)
    }
  }
 
  private unowned let container: DIContainer
  
  private let mutex = PThreadMutex(recursive: ())
  
  private let cache = Cache()
  private var stack: ContiguousArray<Component.UniqueKey> = []

  private class Cache {
    fileprivate static let singleStorage = DICacheStorage()
    fileprivate let containerStorage = DICacheStorage()

    fileprivate static var single = DIScope(name: "single", storage: singleStorage, policy: .strong)
    fileprivate static var weakPerRun = DIScope(name: "per run", storage: singleStorage, policy: .weak)
    fileprivate static var strongPerRun = DIScope(name: "per run", storage: singleStorage, policy: .strong)
    fileprivate lazy var weakPerContainer = DIScope(name: "per container", storage: containerStorage, policy: .weak)
    fileprivate lazy var strongPerContainer = DIScope(name: "per container", storage: containerStorage, policy: .strong)
    fileprivate var graph = makeGraphScope()

    fileprivate static func makeGraphScope() -> DIScope {
      return DIScope(name: "object graph", storage: DICacheStorage(), policy: .strong)
    }

    fileprivate var cycleInjectionQueue: ContiguousArray<(obj: Any?, signature: MethodSignature)> = []
  }
}

