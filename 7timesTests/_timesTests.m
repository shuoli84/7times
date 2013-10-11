#import "Kiwi.h"
#import "Word.h"

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
    });

SPEC_END

