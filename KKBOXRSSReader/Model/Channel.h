//
//  Channel.h
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/23.
//

#import <Foundation/Foundation.h>
#import "Episode.h"

NS_ASSUME_NONNULL_BEGIN

@interface Channel : NSObject
@property (nonatomic, strong) NSURL *rssURL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *imgURL;
@property (nonatomic, strong) NSMutableArray<Episode *> *eps;

- (id)initWithName:(NSString *)name rssURL:(NSURL *)rssURL imgURL: (NSURL *)imgURL;

@end

NS_ASSUME_NONNULL_END
