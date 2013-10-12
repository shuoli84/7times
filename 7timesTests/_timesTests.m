#import "Kiwi.h"
#import "Word.h"
#import "Post.h"
#import "Word+Util.h"
#import "Check.h"
#import "GoogleNewsSource.h"
#import "PostDownloader.h"
#import "PostManager.h"

SPEC_BEGIN(WordSpec)

    describe(@"Word", ^{
        beforeEach(^{
            [MagicalRecord setupCoreDataStackWithInMemoryStore];
        });

        afterEach(^{
            [MagicalRecord cleanUp];
        });

        it(@"should create word", ^{
            Word* word = [Word MR_createEntity];
            word.word = @"word";
            [[NSManagedObjectContext MR_defaultContext] save:nil];

            [[@"word" should] equal:word.word];
        });

        it(@"get last check", ^{
            Word *word = [Word MR_createEntity];
            [[word.lastCheck should] beNil];

            Post *post = [Post MR_createEntity];
            Check *check = [Check MR_createEntity];

            check.date = [NSDate date];
            check.post = post;
            check.word = word;

            [[NSManagedObjectContext MR_defaultContext] save:nil];

            [[word.lastCheck should] equal:check];

            Check *check2 = [Check MR_createEntity];

            check2.date = [[NSDate date] dateByAddingTimeInterval:1];
            check2.word = word;
            check2.post = post;

            [[NSManagedObjectContext MR_defaultContext] save:nil];
            [[word.lastCheck should] equal:check2];
        });

        it(@"ready for new check", ^{
            Word *word = [Word MR_createEntity];
            [[theValue(word.lastCheckExpired) should] beYes];

            Post *post = [Post MR_createEntity];
            Check *check = [Check MR_createEntity];

            check.date = [NSDate date];
            check.post = post;
            check.word = word;

            [[NSManagedObjectContext MR_defaultContext] save:nil];
            [[theValue(word.lastCheckExpired) should] beNo];
        });
    });

SPEC_END

SPEC_BEGIN(DownloadPostSpec)

    describe(@"able to load posts from google news search", ^{
        beforeEach(^{
            [MagicalRecord setupCoreDataStackWithInMemoryStore];
        });

        afterEach(^{
            [MagicalRecord cleanUp];
        });

        it(@"should able to load posts from google news", ^{
            Word* word = [Word MR_createEntity];
            word.word = @"amazing";
            GoogleNewsSource *googleNewsSource = [[GoogleNewsSource alloc]init];
            [googleNewsSource download:word];
            [[theValue(word.post.count) should] equal:theValue(14)];
        });

        it(@"should get word list", ^{
            Word *word = [Word MR_createEntity];
            word.word  = @"word1";

            Word *word2 = [Word MR_createEntity];
            word2.word = @"word2";

            Word *word3 = [Word MR_createEntity];
            word3.word = @"word3";

            Word *word4 = [Word MR_createEntity];
            word4.word = @"word4";

            Word *word5 = [Word MR_createEntity];
            word5.word = @"word5";

            Post *post1 = [Post MR_createEntity];
            [post1 addWordObject:word2];

            Check *check = [Check MR_createEntity];
            check.word = word3;

            [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

            PostDownloader* downLoader = [[PostDownloader alloc] init];
            NSArray *list = downLoader.wordListNeedPosts;
            [[theValue(list.count) should] equal:theValue(4)];
        });

    });

SPEC_END

SPEC_BEGIN(PostManagerSpec)
    describe(@"basic operations", ^{
        beforeEach(^{
            [MagicalRecord setupCoreDataStackWithInMemoryStore];
        });

        afterEach(^{
            [MagicalRecord cleanUp];
        });

        it(@"able to load posts", ^{
            PostManager* postManager = [[PostManager alloc]init];
            [[theValue(postManager.postCount) should] equal:theValue(0)];
            [postManager loadPost];

            NSLog(@"%d posts loaded", postManager.postCount);
            [[theValue(postManager.postCount) shouldNot] equal:theValue(0)];
        });

    });
SPEC_END

