#import "DataPaginator.h"
#import "ReadDatabasePagesRequest.h"


Byte MAX_PAGES_PER_COMMAND = 4;

@implementation DataPaginator {

}
+ (NSArray *)getDatabasePagesRequestsForRecordType:(RecordType)recordType andPageRange:(PageRange *)pageRange {
    NSMutableArray *requests = [[NSMutableArray alloc] init];

    for (int chunkStart = pageRange.firstPage; chunkStart <= pageRange.lastPage; chunkStart+= MAX_PAGES_PER_COMMAND) {
        Byte numberOfPagesForRequest = (Byte) MIN((pageRange.lastPage - chunkStart + 1), MAX_PAGES_PER_COMMAND);
        [requests addObject:[[ReadDatabasePagesRequest alloc] initWithRecordType:recordType pageNumber:chunkStart numberOfPages:numberOfPagesForRequest]];
    }

    return requests;
}

@end