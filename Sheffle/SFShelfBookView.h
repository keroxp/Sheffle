//
//  SFShelfBookView.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookView.h"

@interface SFShelfBookView : UIButton
<GSBookView>

@property (strong,nonatomic) NSString *reuseIdentifier;
@property (assign) BOOL selected;
@property (assign) NSInteger index;

@end
