//
//  LayoutEngine.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/3/19.
//  Copyright © 2018年 nange. All rights reserved.
//

final class LayoutEngine {
    
    static let solverPool = NSMapTable<AnyObject,SimplexSolver>.weakToStrongObjects()
    static func solveFor(_ node: Layoutable) -> SimplexSolver {
        if let solver = solverPool.object(forKey: node) {
            return solver
        } else {
            let solver = SimplexSolver()
            solver.autoSolve = false
            solverPool.setObject(solver, forKey: node)
            return solver
        }
    }
    
}
