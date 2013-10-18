#import "Kiwi.h"
#import "Word.h"
#import "Post.h"
#import "Word+Util.h"
#import "Check.h"
#import "GoogleNewsSource.h"
#import "PostDownloader.h"
#import "PostManager.h"
#import "WordList.h"
#import "WordListManager.h"

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
            word.lastCheckTime = check.date;

            [[NSManagedObjectContext MR_defaultContext] save:nil];
            [[theValue(word.lastCheckExpired) should] beNo];
        });

        it(@"should able to select out word from PostManager", ^{
            Word *word1 = [Word MR_createEntity];
            word1.word = @"word1";
            word1.added = [NSDate date];
            word1.postNumber = @(14);

            Word *word2 = [Word MR_createEntity];
            word2.word = @"word2";
            word2.added = [NSDate date];
            word2.nextCheckTime = [[NSDate date] dateByAddingTimeInterval:20];
            word2.postNumber = @(14);

            Word *word3 = [Word MR_createEntity];
            word3.word = @"word1";
            word3.added = [NSDate date];
            word3.checkNumber = @(7);
            word3.postNumber = @(14);

            [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

            NSFetchRequest *fetchRequest = [PostManager fetchRequest];
            NSArray *array = [Word MR_executeFetchRequest:fetchRequest];
            [[theValue(array.count) should] equal:theValue(1)];
        });


        it(@"should able to select out word from PostDownloader", ^{
            Word *word1 = [Word MR_createEntity];
            word1.word = @"word1";
            word1.added = [NSDate date];

            word1.postNumber = @(0);

            Word *word2 = [Word MR_createEntity];
            word2.word = @"word2";
            word2.added = [NSDate date];
            word2.nextCheckTime = [[NSDate date] dateByAddingTimeInterval:20];
            word2.postNumber = @(14);

            Word *word3 = [Word MR_createEntity];
            word3.word = @"word1";
            word3.added = [NSDate date];
            word3.checkNumber = @(7);
            word3.postNumber = @(0);

            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:nil];

            NSFetchRequest *fetchRequest = [PostDownloader fetchRequest];
            NSArray *array = [Word MR_executeFetchRequest:fetchRequest];
            [[theValue(array.count) should] equal:theValue(1)];
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
            post1.word = word2;

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

SPEC_BEGIN(WordListSpec)

    describe(@"parse from string", ^{
        it(@"able to parse string", ^{
            WordList *wordList = [[WordList alloc] initWithString:@"word1\nword2 \n \n word3"];
            [[theValue(wordList.words.count) shouldNot] equal:theValue(0)];

            wordList = [[WordList alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tofle" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
            [[theValue(wordList.words.count) shouldNot] equal:theValue(0)];
        });

        it(@"WordlistManager", ^{
            WordListManager *manager = [[WordListManager alloc]init];
            [[theValue(manager.allWordLists.count) shouldNot] equal:theValue(0)];
        });

    });

SPEC_END

