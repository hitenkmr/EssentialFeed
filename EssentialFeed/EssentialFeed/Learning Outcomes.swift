//
//  Learning Outcomes.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 16/03/21.
//

import Foundation

//Persistence Module

//1. lecture covered - 'Separating Queries & Side-effects for Simplicity and Reusability, Choosing Between Enum Switching Strategies, and Differentiating App-Specific from App-Agnostic Logic' https://academy.essentialdeveloper.com/courses/447455/lectures/9677292

/*Command–Query Separation (CQS) principle - is a programming principle that can help identify function/method that do too much
 
 - A query should only return a result and should not have side-effects(does not change the observable state of the system)
 
 - A command changes the state of the system(side effedts) but does not return a value.
 */

/* - By following the principle, we identified that the action of loading the feed from cache is a Query, and ideally should have no side-effects. However, deleting the cache as part of the `load` alters the state of the system (which is a side-effect!).
 
 - Thus, in this lecture, we separate loading and validation into two use cases, implemented in distinct methods: load() and validateCache().
 
 - A great benefit of separating the functionality is that now we can [re]use both actions in distinct contexts.
 
 - For example, we can schedule cache validation every 10 minutes or every time the app goes to (or gets back from) the background (instead of only performing it when the user requests to see the feed).
 */

//2. Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles
//https://academy.essentialdeveloper.com/courses/447455/lectures/9763057

/* - Application-specific vs. Application-agnostic vs. Framework (Infrastructure) Logic
 - Entities vs. Value objects
 
 - Designing side-effect free (deterministic) core business rules
 
 - Establishing Functional Core, Imperative Shell
 
 - Promoting reusability and reducing cost, duplication, and defects with single sources of truth*/


//3. https://academy.essentialdeveloper.com/courses/447455/lectures/9763057/comments/10738454

/*
 - The anatomy of Dependency Inversion (High-level, Low-level, and Boundary components)
 Specs as Contracts
 
 - Proactively avoiding bugs caused by side-effects in multithreaded environments
 
 - Documenting infrastructure requirements with an Inbox checklist
 */

