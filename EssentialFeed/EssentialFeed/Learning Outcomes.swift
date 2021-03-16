//
//  Learning Outcomes.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 16/03/21.
//

import Foundation

//Persistence Module

//lecture covered - 'Separating Queries & Side-effects for Simplicity and Reusability, Choosing Between Enum Switching Strategies, and Differentiating App-Specific from App-Agnostic Logic' https://academy.essentialdeveloper.com/courses/447455/lectures/9677292

/*Command–Query Separation (CQS) principle - is a programming principle that can help identify function/method that do too much
 
 - A query should only return a result and should not have side-effects(does not change the observable state of the system)
 
 - A command changes the state of the system(side effedts) but does not return a value.
 */

/* - By following the principle, we identified that the action of loading the feed from cache is a Query, and ideally should have no side-effects. However, deleting the cache as part of the `load` alters the state of the system (which is a side-effect!).
 
 - Thus, in this lecture, we separate loading and validation into two use cases, implemented in distinct methods: load() and validateCache().
 
 - A great benefit of separating the functionality is that now we can [re]use both actions in distinct contexts.
 
 - For example, we can schedule cache validation every 10 minutes or every time the app goes to (or gets back from) the background (instead of only performing it when the user requests to see the feed).
 */




