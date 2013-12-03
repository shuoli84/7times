//
// Created by Li Shuo on 13-12-3.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <SVProgressHUD/SVProgressHUD.h>
#import "WordListFromSrt.h"
#import "Wordlist.h"
#import "Word.h"
#import "Post.h"


@interface WordListFromSrt()

@property (nonatomic, strong) NSString* filename;
@property (nonatomic, strong) NSString* sourceId;

@end

@implementation WordListFromSrt {

}

-(id)initWithName:(NSString*)name filename:(NSString*)filename sourceId:(NSString*)sourceId{
    if(self = [super init]){
        self.filename = filename;
        self.name = name;
        self.sourceId = sourceId;
    }
    return self;
}

-(void)load{
    if([Wordlist MR_findFirstByAttribute:@"sourceId" withValue:self.sourceId] != nil){
        [SVProgressHUD showSuccessWithStatus:@"Already loaded"];
        return;
    }

    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_filename ofType:nil]];
        NSLog(@"Load data from %@ %d bytes", self.filename, data.length);

        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

        Wordlist *wordlist = [Wordlist MR_createEntity];
        wordlist.sourceId = self.sourceId;
        wordlist.name = self.name;

        int sortOrder = 0;
        int count = [json[@"words"] count];
        for(NSDictionary *wordEntry in json[@"words"]){
            Word *word = [Word MR_createEntity];
            word.word = wordEntry[@"word"];
            word.added = [NSDate date];
            word.sortOrder = @(sortOrder);
            [wordlist addWordsObject:word];
            sortOrder += 1;

            for (NSDictionary *line in wordEntry[@"lines"]){
                Post *post = [Post MR_createEntity];
                post.title = line[@"text"];
                post.date = [NSDate date];
                post.source = self.filename;
                post.word = word;
            }

            word.postNumber = @([wordEntry[@"lines"] count]);

            if (sortOrder % 30 == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showProgress:(float) sortOrder / (float) count status:NSLocalizedString(@"LoadingMessage", @"loading") maskType:SVProgressHUDMaskTypeBlack];
                });
            }
        }

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

@end