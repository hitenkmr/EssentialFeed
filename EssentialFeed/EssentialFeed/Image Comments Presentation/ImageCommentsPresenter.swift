//	
// Copyright © 2021 Hitender Kumar. All rights reserved.
//

import Foundation
 
public final class ImageCommentsPresenter {
 
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the image comments view")
    } 
}
