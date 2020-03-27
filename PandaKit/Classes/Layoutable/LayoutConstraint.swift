//
//  LayoutConstraint.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/3/20.
//  Copyright © 2018年 nange. All rights reserved.
//

public enum LayoutRelation {
    case equal
    case lessThanOrEqual
    case greatThanOrEqual
}

extension LayoutRelation: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .equal: return "=="
        case .lessThanOrEqual: return "<="
        case .greatThanOrEqual: return ">="
        }
    }
}

public struct LayoutPriority: RawRepresentable,ExpressibleByFloatLiteral {
    public init(rawValue: Double) {
        self.rawValue = rawValue
    }
    
    public var rawValue: Double
    
    public init(floatLiteral value: Double) {
        rawValue = value
    }
    
    public typealias RawValue = Double
    
    public typealias FloatLiteralType = Double
    
    public static let required: LayoutPriority = 1000.0
    public static let strong: LayoutPriority = 750.0
    public static let medium: LayoutPriority = 250.0
    public static let weak: LayoutPriority = 10.0
}

public enum LayoutAttribute {
    
    case left
    
    case right
    
    case top
    
    case bottom
    
    case width
    
    case height
    
    case centerX
    
    case centerY
}

extension LayoutAttribute: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .left: return "left"
        case .right: return "right"
        case .top: return "top"
        case .bottom: return "bottom"
        case .width: return "width"
        case .height: return "height"
        case .centerX: return "centerX"
        case .centerY: return "centerY"
        }
    }
}

open class LayoutConstraint {
    
    public init(firstAnchor: AnchorType,secondAnchor: AnchorType? = nil, relation: LayoutRelation = .equal, multiplier: Value = 1,constant: Value = 0) {
        self.firstAnchor = firstAnchor
        self.secondAnchor = secondAnchor
        self.relation = relation
        self.constant = constant
        self.multiplier = multiplier
        
        // maybe this code should not be here, need to be fix
        firstAnchor.item.layoutManager.translateRectIntoConstraints = false
        firstAnchor.item.addConstraint(self)
        secondAnchor?.item.layoutManager.pinedConstraints.insert(self)
    }
    
    public let firstAnchor: AnchorType
    
    public let secondAnchor: AnchorType?
    
    public let relation: LayoutRelation
    
    public let multiplier: Value
    
    open var constant: Value = 0 {
        didSet {
            if let solver = solver, constant != oldValue {
                solver.updateConstant(for: constraint, to: Double(constant))
            }
        }
    }
    
    open var priority: LayoutPriority = .required {
        didSet {
            if let solver = solver {
                try? solver.updateStrength(for: constraint, to: Strength(rawValue: priority.rawValue))
            }
        }
    }
    
    open var isActive: Bool = false {
        didSet {
            if oldValue != isActive {
                if isActive {
                    firstAnchor.item.addConstraint(self)
                    secondAnchor?.item.layoutManager.pinedConstraints.insert(self)
                } else {
                    firstAnchor.item.removeConstraint(self)
                    secondAnchor?.item.layoutManager.pinedConstraints.remove(self)
                    try? solver?.remove(constraint: constraint)
                }
            }
        }
    }
    
    fileprivate weak var solver: SimplexSolver? = nil
    
    // translate LayoutConstraint to Constraint
    lazy var constraint: Constraint = {
        
        let superItem = firstAnchor.item.commonSuperItem(with: secondAnchor?.item)
        
        var lhsExpr = firstAnchor.expression(in: superItem)
        let rhsExpr = Expression(constant: Double(constant))
        
        if let secondAnchor = secondAnchor {
            rhsExpr += secondAnchor.expression(in: superItem)*Double(multiplier)
        } else {
            lhsExpr = firstAnchor.expression()
        }
        
        let constraint: Constraint
        switch relation {
        case .equal:
            constraint = lhsExpr == rhsExpr
        case .greatThanOrEqual:
            constraint =  lhsExpr >= rhsExpr
        case .lessThanOrEqual:
            constraint = lhsExpr <= rhsExpr
        }
        
        constraint.strength = Strength(rawValue: priority.rawValue)
        constraint.owner = self
        return constraint
    }()
    
}

extension LayoutConstraint {
    
    func addToSolver(_ solver: SimplexSolver) {
        if self.solver === solver {
            return
        }
        self.solver = solver
        do {
            try solver.add(constraint: constraint)
        } catch ConstraintError.requiredFailureWithExplanation(let constraint) {
            let tips = """
                 Unable to simultaneously satisfy constraints.
                 Probably at least one of the constraints in the following list is one you don't want.
                 Try this:
                 (1) look at each constraint and try to figure out which you don't expect;
                 (2) find the code that added the unwanted constraint or constraints and fix it.
                 """
            print(tips)
            
            for (index,constraint) in constraint.enumerated() {
                if let owner = constraint.owner {
                    print("    \(index + 1). \(String(describing: owner)) ")
                }
            }
            
            print("""
                Will attempt to recover by breaking constraint
                \(self)
                \n
                """)
        }catch {
            print(error)
        }
    }
    
    public func remove() {
        _ = try? solver?.remove(constraint: constraint)
        secondAnchor?.item.layoutManager.pinedConstraints.remove(self)
        solver = nil
    }
    
    class func active(_ constraints: [LayoutConstraint]) {
        constraints.forEach{ $0.isActive = true}
    }
    
    @discardableResult
    func priority(_ priority: LayoutPriority) -> LayoutConstraint {
        self.priority = priority
        return self
    }
}

extension LayoutConstraint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func ==(lhs: LayoutConstraint, rhs: LayoutConstraint) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

infix operator ~:TernaryPrecedence

// syntax surge for setPriority
// item1.left = item2.right + 10 ~ .strong
@discardableResult
public func ~(lhs: LayoutConstraint, rhs: LayoutPriority) -> LayoutConstraint {
    lhs.priority = rhs
    return lhs
}

extension LayoutConstraint: CustomStringConvertible {
    public var description: String {
        let lhsdesc = firstAnchor.debugDescription
        var desc = lhsdesc
        if let rhsAnchor = self.secondAnchor {
            let rhsdesc = rhsAnchor.debugDescription
            desc = "\(lhsdesc) \(relation) \(rhsdesc)*\(multiplier) + \(constant)"
        } else {
            desc = "\(lhsdesc) \(relation) \(constant)"
        }
        return desc
    }
}
