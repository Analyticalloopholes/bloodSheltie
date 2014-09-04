#import <XCTest/XCTest.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "DefaultDecoder.h"
#import "EncodingUtils.h"
#import "PageRange.h"
#import "RecordData.h"
#import "ReadDatabasePageRangeRequest.h"
#import "ReadDatabasePagesRequest.h"
#import "GlucoseUnitSetting.h"
#import "TimeOffset.h"
#import "GlucoseReadRecord.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface DefaultCommandDecoderTests_m : XCTestCase
@end

@implementation DefaultCommandDecoderTests_m

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDatabasePageRangeResponseDecoding
{
    NSString *input = @"01 0E 00 01 01 00 00 00 02 00 00 00 97 11";
    NSData *data = [EncodingUtils dataFromHexString:input];
    
    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReadDatabasePageRangeRequest alloc] initWithRecordType:UserEventData] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    PageRange *pageRange = (PageRange *) response.payload;
    XCTAssertEqual(pageRange.firstPage, 1u);
    XCTAssertEqual(pageRange.lastPage, 2u);
}

- (void)testEmptyDatabasePageRangeResponseDecoding
{
    NSString *input = @"01 0E 00 01 FF FF FF FF FF FF FF FF CD 1D";
    NSData *data = [EncodingUtils dataFromHexString:input];

    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReadDatabasePageRangeRequest alloc] initWithRecordType:UserEventData] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    PageRange *pageRange = (PageRange *) response.payload;
    XCTAssertEqual(pageRange.firstPage, NOT_AVAILABLE);
    XCTAssertEqual(pageRange.lastPage, NOT_AVAILABLE);
}

-(void)testDatabasePageOfGlucoseDataDecoding
{
    NSString *input = @"01 46 08 01 76 D9 00 00 26 00 00 00 04 02 B9 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 9F 39 C3 71 D6 08 79 0F D6 08 2F 00 14 CE 1F EF 72 D6 08 A5 10 D6 08 33 00 14 32 0D 1B 74 D6 08 D1 11 D6 08 38 00 14 04 ED 47 75 D6 08 FD 12 D6 08 3C 00 14 DD 4E 73 76 D6 08 29 14 D6 08 45 00 13 25 6A 9F 77 D6 08 55 15 D6 08 4D 00 13 A7 AB CB 78 D6 08 81 16 D6 08 54 00 13 03 2E F6 79 D6 08 AC 17 D6 08 57 00 13 8D 0D 22 7B D6 08 D8 18 D6 08 59 00 14 40 F1 4E 7C D6 08 04 1A D6 08 5A 00 14 C9 31 7A 7D D6 08 30 1B D6 08 5A 00 14 67 2D A6 7E D6 08 5C 1C D6 08 5A 00 14 13 DE D2 7F D6 08 88 1D D6 08 5B 00 14 BB A9 FE 80 D6 08 B4 1E D6 08 5C 00 14 9A DD 2A 82 D6 08 E0 1F D6 08 5C 00 14 E4 A4 56 83 D6 08 0C 21 D6 08 5A 00 94 75 45 82 84 D6 08 38 22 D6 08 5A 00 94 21 C6 83 84 D6 08 39 22 D6 08 5B 80 14 29 1B AE 85 D6 08 64 23 D6 08 59 00 14 53 C5 DA 86 D6 08 90 24 D6 08 58 00 14 66 8F 06 88 D6 08 BC 25 D6 08 55 00 14 75 E6 32 89 D6 08 E8 26 D6 08 55 00 24 D2 F4 5E 8A D6 08 14 28 D6 08 4E 00 24 B9 16 8A 8B D6 08 40 29 D6 08 47 00 25 B8 50 B6 8C D6 08 6C 2A D6 08 41 00 25 11 00 E2 8D D6 08 98 2B D6 08 3E 00 25 3C 70 0E 8F D6 08 C4 2C D6 08 3E 00 24 E6 5A 3A 90 D6 08 F0 2D D6 08 3E 00 24 2A EB 66 91 D6 08 1C 2F D6 08 3E 00 24 86 A7 92 92 D6 08 48 30 D6 08 3F 00 24 D0 B6 BE 93 D6 08 74 31 D6 08 51 00 A4 82 DF EA 94 D6 08 A0 32 D6 08 50 00 B8 12 29 EA 94 D6 08 A0 32 D6 08 5D 80 38 53 E1 16 96 D6 08 CC 33 D6 08 5C 00 38 51 76 42 97 D6 08 F8 34 D6 08 61 00 38 45 8E 6E 98 D6 08 24 36 D6 08 6B 00 38 C3 DE 9A 99 D6 08 50 37 D6 08 79 00 23 A7 5C C6 9A D6 08 7C 38 D6 08 85 00 38 BE C3 FF FF FF FF FF FF 9C D9 00 00 26 00 00 00 04 02 BA 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 D2 E3 F2 9B D6 08 A8 39 D6 08 8A 00 38 C2 EB 1E 9D D6 08 D4 3A D6 08 76 00 B8 E0 13 4A 9E D6 08 00 3C D6 08 74 00 B8 A9 81 4A 9E D6 08 00 3C D6 08 75 80 38 89 3C 76 9F D6 08 2C 3D D6 08 77 00 38 87 53 A2 A0 D6 08 58 3E D6 08 7D 00 38 2E 2D CE A1 D6 08 84 3F D6 08 81 00 38 9B 9F FA A2 D6 08 B0 40 D6 08 81 00 38 80 98 26 A4 D6 08 DC 41 D6 08 7E 00 38 06 EB 52 A5 D6 08 08 43 D6 08 79 00 38 EE E0 7E A6 D6 08 34 44 D6 08 75 00 24 E9 6D AA A7 D6 08 60 45 D6 08 72 00 24 C8 20 D6 A8 D6 08 8C 46 D6 08 70 00 24 2A D4 02 AA D6 08 B8 47 D6 08 6B 00 14 8F 9B 2E AB D6 08 E4 48 D6 08 69 00 14 E6 BE 5A AC D6 08 10 4A D6 08 66 00 14 E6 01 86 AD D6 08 3C 4B D6 08 63 00 14 E5 97 B2 AE D6 08 68 4C D6 08 61 00 14 5A 05 DE AF D6 08 94 4D D6 08 5F 00 14 8E 91 0A B1 D6 08 C0 4E D6 08 5D 00 14 38 7E 36 B2 D6 08 EC 4F D6 08 5C 00 14 74 8D 62 B3 D6 08 18 51 D6 08 59 00 14 17 3D 8E B4 D6 08 44 52 D6 08 58 00 14 0D F4 BA B5 D6 08 70 53 D6 08 56 00 14 A2 F3 E6 B6 D6 08 9C 54 D6 08 54 00 14 E5 4C 12 B8 D6 08 C8 55 D6 08 51 00 14 6F 93 3E B9 D6 08 F4 56 D6 08 4E 00 14 CD 0F 6A BA D6 08 20 58 D6 08 4D 00 14 F6 A7 96 BB D6 08 4C 59 D6 08 4C 00 14 A3 9A C2 BC D6 08 78 5A D6 08 4A 00 14 FD 22 EE BD D6 08 A4 5B D6 08 49 00 14 FE 1B 1A BF D6 08 D0 5C D6 08 47 00 14 EC 30 46 C0 D6 08 FC 5D D6 08 47 00 14 C0 22 72 C1 D6 08 28 5F D6 08 46 00 14 5D DF 9E C2 D6 08 54 60 D6 08 45 00 14 8B 9F CA C3 D6 08 80 61 D6 08 44 00 14 59 42 F6 C4 D6 08 AC 62 D6 08 43 00 14 C0 25 22 C6 D6 08 D8 63 D6 08 43 00 14 48 32 FF FF FF FF FF FF C2 D9 00 00 26 00 00 00 04 02 BB 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 6D 4B 4E C7 D6 08 04 65 D6 08 42 00 14 BF E9 7A C8 D6 08 30 66 D6 08 40 00 14 C5 29 A6 C9 D6 08 5C 67 D6 08 40 00 14 DA 89 D2 CA D6 08 88 68 D6 08 3F 00 14 52 63 FE CB D6 08 B4 69 D6 08 3E 00 14 D2 2C 2A CD D6 08 E0 6A D6 08 3C 00 14 B9 1D 56 CE D6 08 0C 6C D6 08 3C 00 14 44 23 82 CF D6 08 38 6D D6 08 3C 00 14 EF 58 AE D0 D6 08 64 6E D6 08 3C 00 14 67 B5 DA D1 D6 08 90 6F D6 08 3C 00 14 09 9B 06 D3 D6 08 BC 70 D6 08 37 00 14 E3 3D 32 D4 D6 08 E8 71 D6 08 37 00 14 E8 E1 5E D5 D6 08 14 73 D6 08 35 00 14 18 0B 8A D6 D6 08 40 74 D6 08 39 00 14 A3 E5 B6 D7 D6 08 6C 75 D6 08 3B 00 14 35 91 E2 D8 D6 08 98 76 D6 08 3B 00 14 95 A7 0E DA D6 08 C4 77 D6 08 39 00 24 BC 48 3A DB D6 08 F0 78 D6 08 39 00 24 B1 D4 66 DC D6 08 1C 7A D6 08 3A 00 24 F2 B2 92 DD D6 08 48 7B D6 08 3B 00 24 09 E7 BE DE D6 08 74 7C D6 08 3E 00 24 22 27 EA DF D6 08 A0 7D D6 08 3E 00 24 C0 CD 16 E1 D6 08 CC 7E D6 08 3D 00 24 9F EE 42 E2 D6 08 F8 7F D6 08 3C 00 14 77 C3 6E E3 D6 08 24 81 D6 08 40 00 14 F2 5A 9A E4 D6 08 50 82 D6 08 43 00 14 60 F7 C6 E5 D6 08 7C 83 D6 08 43 00 14 39 03 F2 E6 D6 08 A8 84 D6 08 42 00 14 2F 63 1E E8 D6 08 D4 85 D6 08 40 00 14 DD 33 4A E9 D6 08 00 87 D6 08 3F 00 14 E6 E3 76 EA D6 08 2C 88 D6 08 3E 00 14 09 90 A2 EB D6 08 58 89 D6 08 3D 00 14 1E 6F CD EC D6 08 84 8A D6 08 3C 00 14 AD FC FA ED D6 08 B0 8B D6 08 3B 00 14 69 1D 25 EF D6 08 DB 8C D6 08 3A 00 14 D6 D7 51 F0 D6 08 07 8E D6 08 3B 00 14 51 50 7D F1 D6 08 33 8F D6 08 3D 00 14 EC 09 A9 F2 D6 08 5F 90 D6 08 41 00 14 B9 E2 FF FF FF FF FF FF E8 D9 00 00 26 00 00 00 04 02 BC 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 96 D5 F3 D6 08 8B 91 D6 08 42 00 14 FF 59 01 F5 D6 08 B7 92 D6 08 42 00 14 43 26 2D F6 D6 08 E3 93 D6 08 42 00 14 CE A0 59 F7 D6 08 0F 95 D6 08 44 00 14 97 50 85 F8 D6 08 3B 96 D6 08 46 00 14 66 55 B1 F9 D6 08 67 97 D6 08 47 00 14 4F 5E DE FA D6 08 94 98 D6 08 48 00 14 34 94 09 FC D6 08 BF 99 D6 08 48 00 14 0D 36 35 FD D6 08 EB 9A D6 08 47 00 14 46 9C 61 FE D6 08 17 9C D6 08 47 00 14 34 9D 8D FF D6 08 43 9D D6 08 48 00 14 7D 24 B9 00 D7 08 6F 9E D6 08 47 00 14 16 D2 E5 01 D7 08 9B 9F D6 08 47 00 14 8C F4 12 03 D7 08 C8 A0 D6 08 47 00 14 19 E9 3D 04 D7 08 F3 A1 D6 08 48 00 14 99 AF 69 05 D7 08 1F A3 D6 08 48 00 14 BB 41 95 06 D7 08 4B A4 D6 08 47 00 14 A4 FE C1 07 D7 08 77 A5 D6 08 46 00 14 38 A8 ED 08 D7 08 A3 A6 D6 08 46 00 14 72 E9 19 0A D7 08 CF A7 D6 08 45 00 14 06 A9 45 0B D7 08 FB A8 D6 08 44 00 14 1A 4E 71 0C D7 08 27 AA D6 08 44 00 14 A5 64 9D 0D D7 08 53 AB D6 08 45 00 14 1B A8 C9 0E D7 08 7F AC D6 08 45 00 14 A7 AD F5 0F D7 08 AB AD D6 08 44 00 14 54 3C 21 11 D7 08 D7 AE D6 08 43 00 14 49 C5 4D 12 D7 08 03 B0 D6 08 43 00 14 6F 73 79 13 D7 08 2F B1 D6 08 3F 00 94 F6 F7 79 13 D7 08 2F B1 D6 08 40 80 14 DF 89 A5 14 D7 08 5B B2 D6 08 3E 00 14 78 AD D1 15 D7 08 87 B3 D6 08 3C 00 14 2D 10 FD 16 D7 08 B3 B4 D6 08 3B 00 14 CB 2D 2B 18 D7 08 E1 B5 D6 08 05 00 58 B1 E5 55 19 D7 08 0B B7 D6 08 05 00 58 F1 02 81 1A D7 08 37 B8 D6 08 05 00 58 DE B4 AD 1B D7 08 63 B9 D6 08 05 00 58 D9 EC D9 1C D7 08 8F BA D6 08 05 00 58 9E 9E 05 1E D7 08 BB BB D6 08 05 00 58 74 F6 FF FF FF FF FF FF 16 8F";
    NSData *data = [EncodingUtils dataFromHexString:input];
    
    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReadDatabasePagesRequest alloc] initWithRecordType:EGVData pageNumber:1 numberOfPages:2] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    RecordData *recordData = (RecordData *) response.payload;
    XCTAssertEqual(recordData.recordType, EGVData);
    XCTAssertEqual([recordData.records count], 142ul);
}

-(void)testTimezoneDecoding
{
    NSString *input = @"01:36:06:01:42:AA:00:00:26:00:00:00:04:02:7B:04:00:00:00:00:00:00:00:00:00:00:00:00:00:00:FB:E6:2C:5F:A0:0A:C4:ED:9F:0A:0A:00:48:C1:37:58:60:A0:0A:F0:EE:9F:0A:0A:00:48:95:70:84:61:A0:0A:1C:F0:9F:0A:0A:00:48:F4:A4:B0:62:A0:0A:48:F1:9F:0A:0A:00:48:CA:D5:DC:63:A0:0A:74:F2:9F:0A:0A:00:48:EF:62:08:65:A0:0A:A0:F3:9F:0A:06:01:38:9A:25:34:66:A0:0A:CC:F4:9F:0A:01:01:38:7B:34:60:67:A0:0A:F8:F5:9F:0A:0A:00:48:2D:7B:8D:68:A0:0A:25:F7:9F:0A:0A:00:48:3D:41:B8:69:A0:0A:50:F8:9F:0A:0A:00:48:F4:60:E4:6A:A0:0A:7C:F9:9F:0A:0A:00:48:27:4A:10:6C:A0:0A:A8:FA:9F:0A:09:00:48:FF:4D:3C:6D:A0:0A:D4:FB:9F:0A:0A:00:48:F3:B1:68:6E:A0:0A:00:FD:9F:0A:0A:00:48:DA:4D:94:6F:A0:0A:2C:FE:9F:0A:0A:00:48:13:11:C0:70:A0:0A:58:FF:9F:0A:0A:00:48:9C:93:EC:71:A0:0A:84:00:A0:0A:0A:00:48:C7:8B:18:73:A0:0A:B0:01:A0:0A:0A:00:48:D9:EB:44:74:A0:0A:DC:02:A0:0A:0A:00:48:93:3A:70:75:A0:0A:08:04:A0:0A:68:00:38:03:7D:9C:76:A0:0A:34:05:A0:0A:66:00:38:47:0D:F4:78:A0:0A:8C:07:A0:0A:5D:00:38:5F:A7:20:7A:A0:0A:B8:08:A0:0A:5C:00:38:A8:DA:78:7C:A0:0A:10:0B:A0:0A:78:00:38:35:D8:D0:7E:A0:0A:68:0D:A0:0A:93:00:38:0C:4D:FC:7F:A0:0A:94:0E:A0:0A:9C:00:38:D8:E4:28:81:A0:0A:C0:0F:A0:0A:AE:00:38:A8:EA:54:82:A0:0A:EC:10:A0:0A:C3:00:38:1C:29:80:83:A0:0A:18:12:A0:0A:CE:00:38:13:A8:AC:84:A0:0A:44:13:A0:0A:CD:00:38:56:49:D8:85:A0:0A:70:14:A0:0A:C6:00:38:3D:6C:04:87:A0:0A:9C:15:A0:0A:C1:00:38:84:53:B4:8B:A0:0A:4C:1A:A0:0A:71:00:38:85:B8:64:90:A0:0A:FC:1E:A0:0A:AE:00:38:A5:F2:90:91:A0:0A:28:20:A0:0A:A1:00:38:29:FD:6B:97:A0:0A:03:26:A0:0A:0A:00:48:18:FD:98:98:A0:0A:30:27:A0:0A:0A:00:48:C4:25:EF:9A:A0:0A:87:29:A0:0A:66:00:38:6F:92:FF:FF:FF:FF:FF:FF:68:AA:00:00:26:00:00:00:04:02:7C:04:00:00:00:00:00:00:00:00:00:00:00:00:00:00:9E:3B:1B:9C:A0:0A:B3:2A:A0:0A:63:00:38:F4:3F:23:A3:A0:0A:BB:31:A0:0A:91:00:38:AE:5E:4F:A4:A0:0A:E7:32:A0:0A:0A:00:48:71:DF:7C:A5:A0:0A:14:34:A0:0A:0A:00:48:72:4D:A7:A6:A0:0A:3F:35:A0:0A:0A:00:48:F2:DE:D3:A7:A0:0A:6B:36:A0:0A:0A:00:48:D3:BE:FF:A8:A0:0A:97:37:A0:0A:0A:00:48:82:89:2B:AA:A0:0A:C3:38:A0:0A:0A:00:48:5F:70:83:AC:A0:0A:1B:3B:A0:0A:0A:00:48:9D:9E:B0:AD:A0:0A:48:3C:A0:0A:0A:00:48:31:8C:DB:AE:A0:0A:73:3D:A0:0A:0A:00:48:27:5E:45:33:A1:0A:DD:C1:A0:0A:0A:00:48:A8:AF:70:34:A1:0A:08:C3:A0:0A:0A:00:48:92:76:9C:35:A1:0A:34:C4:A0:0A:0A:00:48:BC:4E:C8:36:A1:0A:60:C5:A0:0A:0A:00:48:2D:D1:F4:37:A1:0A:8C:C6:A0:0A:0A:00:48:8E:36:21:39:A1:0A:B9:C7:A0:0A:0A:00:48:BC:7B:4C:3A:A1:0A:E4:C8:A0:0A:15:01:38:36:E8:A4:3C:A1:0A:3C:CB:A0:0A:0A:00:48:D5:60:D0:3D:A1:0A:68:CC:A0:0A:0A:00:48:55:06:FC:3E:A1:0A:94:CD:A0:0A:0A:00:48:7A:D6:29:40:A1:0A:C1:CE:A0:0A:0A:00:48:93:7C:88:49:A1:0A:20:D8:A0:0A:0A:00:48:E3:95:B4:4A:A1:0A:4C:D9:A0:0A:0A:00:48:73:8C:E0:4B:A1:0A:78:DA:A0:0A:0A:00:48:32:F5:0C:4D:A1:0A:A4:DB:A0:0A:0A:00:48:E4:44:38:4E:A1:0A:D0:DC:A0:0A:D2:00:38:6F:64:64:4F:A1:0A:FC:DD:A0:0A:DD:00:38:07:BC:91:50:A1:0A:29:DF:A0:0A:E3:00:38:3B:A8:BC:51:A1:0A:54:E0:A0:0A:E5:00:38:C0:70:E8:52:A1:0A:80:E1:A0:0A:E7:00:28:F9:38:14:54:A1:0A:AC:E2:A0:0A:E8:00:28:FB:54:40:55:A1:0A:D8:E3:A0:0A:E9:00:24:AA:8D:6C:56:A1:0A:04:E5:A0:0A:E5:00:14:00:B8:98:57:A1:0A:30:E6:A0:0A:DD:00:14:95:8E:C4:58:A1:0A:5C:E7:A0:0A:E1:00:14:10:2E:F0:59:A1:0A:88:E8:A0:0A:DF:00:14:5A:74:1C:5B:A1:0A:B4:E9:A0:0A:D6:00:14:CB:EE:FF:FF:FF:FF:FF:FF:8E:AA:00:00:13:00:00:00:04:02:7D:04:00:00:00:00:00:00:00:00:00:00:00:00:00:00:A3:1E:48:5C:A1:0A:E0:EA:A0:0A:D9:00:24:4D:4D:74:5D:A1:0A:0C:EC:A0:0A:D3:00:24:2E:2E:A0:5E:A1:0A:38:ED:A0:0A:CF:00:24:0D:BD:CC:5F:A1:0A:64:EE:A0:0A:D3:00:24:30:8F:F8:60:A1:0A:90:EF:A0:0A:DD:00:24:E5:6A:24:62:A1:0A:BC:F0:A0:0A:E5:00:23:1D:20:50:63:A1:0A:E8:F1:A0:0A:E5:00:23:7C:CB:7C:64:A1:0A:14:F3:A0:0A:E1:00:24:A1:D4:A8:65:A1:0A:40:F4:A0:0A:DC:00:24:05:16:D4:66:A1:0A:6C:F5:A0:0A:DC:00:24:AC:96:01:68:A1:0A:99:F6:A0:0A:E0:00:24:0F:96:2C:69:A1:0A:C4:F7:A0:0A:F6:00:13:FA:8A:58:6A:A1:0A:F0:F8:A0:0A:EB:00:38:93:18:84:6B:A1:0A:1C:FA:A0:0A:06:00:48:62:41:B0:6C:A1:0A:48:FB:A0:0A:06:00:48:69:9D:DC:6D:A1:0A:74:FC:A0:0A:06:00:48:ED:2C:07:6F:A1:0A:9F:FD:A0:0A:06:00:48:3D:A6:33:70:A1:0A:CB:FE:A0:0A:06:00:48:AB:2F:5F:71:A1:0A:F7:FF:A0:0A:06:00:48:CE:13:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:83:6E";
    NSData *data = [EncodingUtils dataFromHexString:input];
    
    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReadDatabasePagesRequest alloc] initWithRecordType:EGVData pageNumber:304 numberOfPages:2] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    RecordData *recordData = (RecordData *) response.payload;
    XCTAssertEqual(recordData.recordType, EGVData);
    GlucoseReadRecord *object = [recordData.records lastObject];

    DDLogDebug(@"[%@]", [object internalTime]);
}

-(void)testDatabasePageOfUserEventDecoding
{
    NSString *input = @"01 26 04 01 6D 0B 00 00 19 00 00 00 0B 01 75 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 CB 20 DB B8 D4 08 91 56 D4 08 02 00 54 56 D4 08 5E 01 00 00 E9 9D 0D BA D4 08 C3 57 D4 08 01 00 BC 57 D4 08 0A 00 00 00 E8 E3 FA 06 D5 08 B0 A4 D4 08 02 00 9C A4 D4 08 5E 01 00 00 40 E5 AF 13 D5 08 65 B1 D4 08 01 00 44 B1 D4 08 0D 00 00 00 AE C5 67 3B D5 08 1D D9 D4 08 01 00 E0 D8 D4 08 04 00 00 00 78 96 BD 50 D5 08 73 EE D4 08 02 00 70 EE D4 08 F4 01 00 00 9C 0D 2D BE D5 08 E3 5B D5 08 02 00 A8 5B D5 08 58 02 00 00 38 0F 37 BE D5 08 ED 5B D5 08 02 00 E4 5B D5 08 2C 01 00 00 54 2A 41 CA D5 08 F7 67 D5 08 01 00 CC 64 D5 08 01 00 00 00 14 1F D9 DD D5 08 8F 7B D5 08 02 00 88 7B D5 08 FA 00 00 00 29 60 5C 05 D6 08 12 A3 D5 08 02 00 E8 A2 D5 08 2C 01 00 00 F8 2F D9 05 D6 08 8F A3 D5 08 01 00 60 A3 D5 08 02 00 00 00 86 7C 52 08 D6 08 08 A6 D5 08 01 00 F4 A5 D5 08 0A 00 00 00 F6 32 CB 22 D6 08 81 C0 D5 08 01 00 70 C0 D5 08 02 00 00 00 AB 3E AA 2C D6 08 60 CA D5 08 01 00 48 CA D5 08 02 00 00 00 3D 95 EA 2E D6 08 A0 CC D5 08 01 00 64 CC D5 08 02 00 00 00 36 77 BE 35 D6 08 74 D3 D5 08 01 00 6C D3 D5 08 02 00 00 00 FB 15 1B 53 D6 08 D1 F0 D5 08 02 00 B8 F0 D5 08 2C 01 00 00 48 13 90 59 D6 08 46 F7 D5 08 01 00 0C F7 D5 08 0A 00 00 00 45 B3 E1 6C D6 08 97 0A D6 08 01 00 80 0A D6 08 04 00 00 00 4C D0 A1 93 D6 08 57 31 D6 08 02 00 2C 31 D6 08 64 00 00 00 61 9A DE 93 D6 08 94 31 D6 08 02 00 68 31 D6 08 F4 01 00 00 14 9E DE 9C D6 08 94 3A D6 08 02 00 8C 3A D6 08 64 00 00 00 81 6A BB 12 D7 08 71 B0 D6 08 02 00 70 B0 D6 08 2C 01 00 00 33 52 10 13 D7 08 C6 B0 D6 08 02 00 AC B0 D6 08 58 02 00 00 CA 2B 86 0B 00 00 0A 00 00 00 0B 01 76 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 C9 5D E3 1B D7 08 99 B9 D6 08 01 00 94 B9 D6 08 01 00 00 00 3D A5 3A 2A D7 08 F0 C7 D6 08 01 00 E0 C7 D6 08 02 00 00 00 EE 29 2C 2B D7 08 E2 C8 D6 08 01 00 D0 C8 D6 08 02 00 00 00 45 F6 A6 5F D7 08 5C FD D6 08 02 00 50 FD D6 08 5E 01 00 00 FC FF AC 62 D7 08 62 00 D7 08 01 00 5C 00 D7 08 0A 00 00 00 60 87 1C 8E D7 08 D2 2B D7 08 01 00 B8 2B D7 08 02 00 00 00 56 2D 0F 8F D7 08 C5 2C D7 08 01 00 A8 2C D7 08 01 00 00 00 EC 0C 6A B8 D7 08 20 56 D7 08 02 00 E8 55 D7 08 5E 01 00 00 9A AB A6 BB D7 08 5C 59 D7 08 01 00 30 59 D7 08 0D 00 00 00 A3 32 35 C2 D7 08 EB 5F D7 08 02 00 C0 5F D7 08 96 00 00 00 08 9C FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 24 5F";
    NSData *data = [EncodingUtils dataFromHexString:input];
    
    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReadDatabasePagesRequest alloc] initWithRecordType:UserEventData pageNumber:1 numberOfPages:2] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    RecordData *recordData = (RecordData *) response.payload;
    XCTAssertEqual(recordData.recordType, UserEventData);
    XCTAssertEqual([recordData.records count], 35ul);
}

-(void)testDatabasePageOfMeterDataDecoding
{
    NSString *input = @"01:46:08:01:06:07:00:00:1F:00:00:00:0A:01:3A:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:F8:C6:4B:CF:83:09:C8:5E:83:09:45:00:2D:CF:83:09:5C:F9:47:2D:84:09:C4:BC:83:09:4F:00:29:2D:84:09:BC:D2:CF:B9:84:09:4C:49:84:09:41:00:B1:B9:84:09:D4:A5:94:27:85:09:11:B7:84:09:44:00:76:27:85:09:2C:F2:68:73:85:09:E5:02:85:09:39:00:4A:73:85:09:F7:8D:F5:C3:85:09:72:53:85:09:35:00:D7:C3:85:09:F4:7E:37:05:86:09:B4:94:85:09:49:00:19:05:86:09:A7:BB:25:77:86:09:A2:06:86:09:4B:00:07:77:86:09:FA:E1:82:BE:86:09:FF:4D:86:09:5A:00:64:BE:86:09:9D:EA:9A:C1:86:09:17:51:86:09:5D:00:7C:C1:86:09:C5:C6:FF:C1:86:09:7C:51:86:09:5D:00:E1:C1:86:09:FB:B9:80:CD:86:09:FD:5C:86:09:66:00:62:CD:86:09:0F:56:92:2E:87:09:0F:BE:86:09:42:00:74:2E:87:09:FA:C9:7C:37:87:09:F9:C6:86:09:40:00:5E:37:87:09:0C:53:C2:4A:87:09:3F:DA:86:09:2B:00:A4:4A:87:09:A4:67:D0:4A:87:09:4D:DA:86:09:2B:00:B2:4A:87:09:A4:6A:6A:52:87:09:E7:E1:86:09:2B:00:4C:52:87:09:31:08:0B:57:87:09:88:E6:86:09:3A:00:ED:56:87:09:C5:36:D2:5A:87:09:4F:EA:86:09:44:00:B4:5A:87:09:BB:5E:59:5C:87:09:D6:EB:86:09:45:00:3B:5C:87:09:3F:A0:34:8C:87:09:B1:1B:87:09:49:00:16:8C:87:09:CC:E6:5C:AC:87:09:D9:3B:87:09:50:00:3E:AC:87:09:32:56:E7:D3:87:09:64:63:87:09:33:00:C9:D3:87:09:0F:D3:9D:FB:87:09:1A:8B:87:09:47:00:7F:FB:87:09:1C:AA:B3:11:88:09:30:A1:87:09:61:00:95:11:88:09:76:41:4A:24:88:09:C7:B3:87:09:61:00:2C:24:88:09:B2:13:0E:36:88:09:8B:C5:87:09:5A:00:F0:35:88:09:A1:42:F5:48:88:09:72:D8:87:09:5B:00:D7:48:88:09:41:4C:E0:59:88:09:5D:E9:87:09:5A:00:C2:59:88:09:29:B9:BB:76:88:09:38:06:88:09:53:00:9D:76:88:09:35:12:76:A4:88:09:F3:33:88:09:39:00:58:A4:88:09:32:43:FF:FF:FF:FF:25:07:00:00:1F:00:00:00:0A:01:3B:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:EA:44:19:57:89:09:96:E6:88:09:4B:00:FB:56:89:09:18:3A:83:64:89:09:00:F4:88:09:4B:00:65:64:89:09:C5:1B:82:71:89:09:FF:00:89:09:71:00:64:71:89:09:26:E3:61:A7:89:09:DE:36:89:09:3D:00:43:A7:89:09:42:D1:6D:F8:89:09:EA:87:89:09:35:00:4F:F8:89:09:08:DA:58:6A:8A:09:D5:F9:89:09:52:00:3A:6A:8A:09:5C:22:48:44:8B:09:C5:D3:8A:09:35:00:2A:44:8B:09:08:78:89:B1:8B:09:06:41:8B:09:48:00:6B:B1:8B:09:86:BA:9E:EC:8B:09:1B:7C:8B:09:69:00:80:EC:8B:09:D9:4B:33:ED:8B:09:B0:7C:8B:09:69:00:15:ED:8B:09:F3:C2:1F:06:8C:09:9C:95:8B:09:5A:00:01:06:8C:09:0B:E5:A3:5D:8C:09:20:ED:8B:09:46:00:85:5D:8C:09:7C:F3:94:83:8C:09:11:13:8C:09:5B:00:76:83:8C:09:AC:E9:45:9C:8C:09:C2:2B:8C:09:56:00:27:9C:8C:09:09:B3:3E:06:8D:09:BB:95:8C:09:33:00:20:06:8D:09:0E:87:4E:57:8D:09:CB:E6:8C:09:4E:00:30:57:8D:09:16:DE:2B:AE:8D:09:A8:3D:8D:09:34:00:0D:AE:8D:09:20:D5:21:E4:8D:09:9E:73:8D:09:59:00:03:E4:8D:09:22:88:DE:EE:8D:09:5B:7E:8D:09:4D:00:C0:EE:8D:09:DB:4C:29:79:8E:09:A6:08:8E:09:5B:00:0B:79:8E:09:2B:6F:4A:79:8E:09:C7:08:8E:09:5B:00:2C:79:8E:09:C9:16:8D:7E:8E:09:0A:0E:8E:09:59:00:6F:7E:8E:09:0B:6F:8C:04:8F:09:09:94:8E:09:79:00:6E:04:8F:09:D0:2A:6A:11:8F:09:E7:A0:8E:09:7C:00:4C:11:8F:09:4D:59:37:3E:8F:09:B4:CD:8E:09:46:00:19:3E:8F:09:C2:0E:65:AA:8F:09:E2:39:8F:09:59:00:47:AA:8F:09:88:45:38:F7:8F:09:B5:86:8F:09:51:00:1A:F7:8F:09:6D:B6:B3:14:90:09:30:A4:8F:09:61:00:95:14:90:09:7C:25:47:51:90:09:C4:E0:8F:09:5A:00:29:51:90:09:18:14:BD:87:90:09:3A:17:90:09:41:00:9F:87:90:09:48:C3:FD:87:90:09:7A:17:90:09:45:00:DF:87:90:09:D0:F2:FF:FF:FF:FF:44:07:00:00:1F:00:00:00:0A:01:3C:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:E9:C3:89:92:90:09:06:22:90:09:3D:00:6B:92:90:09:D4:49:96:F8:90:09:13:88:90:09:5B:00:78:F8:90:09:72:4D:25:0F:91:09:A2:9E:90:09:3F:00:07:0F:91:09:0B:64:42:25:91:09:BF:B4:90:09:4E:00:24:25:91:09:E9:B7:49:2C:91:09:C6:BB:90:09:56:00:2B:2C:91:09:7A:A0:16:43:91:09:93:D2:90:09:68:00:F8:42:91:09:2A:62:8E:4D:91:09:0B:DD:90:09:82:00:70:4D:91:09:B4:47:34:57:91:09:B1:E6:90:09:71:00:16:57:91:09:11:49:13:73:91:09:90:02:91:09:65:00:F5:72:91:09:DB:28:E2:77:91:09:5F:07:91:09:5F:00:C4:77:91:09:9E:DE:6D:83:91:09:EA:12:91:09:5F:00:4F:83:91:09:D4:90:6D:CB:91:09:EA:5A:91:09:3D:00:4F:CB:91:09:2C:D7:ED:D8:91:09:6A:68:91:09:42:00:CF:D8:91:09:86:C8:63:E7:91:09:E0:76:91:09:4A:00:45:E7:91:09:43:84:36:18:92:09:B3:A7:91:09:6D:00:18:18:92:09:9F:DB:28:93:92:09:A5:22:92:09:41:00:0A:93:92:09:96:68:51:BA:92:09:CE:49:92:09:52:00:33:BA:92:09:EA:B4:C1:EA:92:09:3E:7A:92:09:46:00:A3:EA:92:09:80:0F:10:F8:92:09:8D:87:92:09:59:00:F2:F7:92:09:A5:3D:E0:FD:92:09:5D:8D:92:09:77:00:C2:FD:92:09:31:E9:C5:2B:93:09:42:BB:92:09:42:00:A7:2B:93:09:52:86:9C:2F:93:09:19:BF:92:09:3A:00:7E:2F:93:09:30:B0:4C:9D:93:09:C9:2C:93:09:33:00:2E:9D:93:09:99:27:D5:E0:93:09:52:70:93:09:56:00:B7:E0:93:09:3B:8D:D9:46:94:09:56:D6:93:09:3C:00:BB:46:94:09:6D:6B:FA:7E:94:09:77:0E:94:09:4D:00:DC:7E:94:09:7A:24:BF:EE:94:09:3C:7E:94:09:61:00:A1:EE:94:09:71:35:FC:46:95:09:79:D6:94:09:3E:00:DE:46:95:09:51:86:65:52:95:09:E2:E1:94:09:4B:00:47:52:95:09:92:F6:12:9E:95:09:8F:2D:95:09:35:00:F4:9D:95:09:E4:63:77:AD:95:09:F4:3C:95:09:2E:00:59:AD:95:09:82:F4:FF:FF:FF:FF:63:07:00:00:12:00:00:00:0A:01:3D:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:07:44:E7:41:96:09:64:D1:95:09:4C:00:C9:41:96:09:B9:57:AC:4C:96:09:29:DC:95:09:44:00:8E:4C:96:09:EA:85:BC:94:96:09:39:24:96:09:57:00:9E:94:96:09:00:D3:D7:27:97:09:54:B7:96:09:34:00:B9:27:97:09:35:20:C3:E8:97:09:40:78:97:09:46:00:A5:E8:97:09:85:A3:06:3C:98:09:83:CB:97:09:52:00:E8:3B:98:09:DA:90:62:75:98:09:DF:04:98:09:4E:00:44:75:98:09:66:DD:08:3B:99:09:85:CA:98:09:39:00:EA:3A:99:09:26:8D:5C:A4:99:09:D9:33:99:09:4C:00:3E:A4:99:09:4E:68:8B:B1:99:09:08:41:99:09:43:00:6D:B1:99:09:32:77:B1:B9:99:09:2E:49:99:09:40:00:93:B9:99:09:E2:03:D6:B9:99:09:53:49:99:09:40:00:B8:B9:99:09:7F:BB:0F:CA:99:09:8C:59:99:09:4C:00:F1:C9:99:09:1D:76:9F:CC:99:09:1C:5C:99:09:50:00:81:CC:99:09:73:D7:35:15:9A:09:B2:A4:99:09:5F:00:17:15:9A:09:01:E1:3D:84:9A:09:BA:13:9A:09:48:00:1F:84:9A:09:37:8C:93:B8:9A:09:10:48:9A:09:52:00:75:B8:9A:09:FE:CF:EE:CB:9A:09:6B:5B:9A:09:51:00:D0:CB:9A:09:4B:3F:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:B4:FF";
    NSData *data = [EncodingUtils dataFromHexString:input];
    
    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReadDatabasePagesRequest alloc] initWithRecordType:MeterData pageNumber:57 numberOfPages:4] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    RecordData *recordData = (RecordData *) response.payload;
    XCTAssertEqual(recordData.recordType, MeterData);
    XCTAssertEqual([recordData.records count], 111ul);
}

-(void)testGlucoseUnitDecoding
{
    NSString *input = @"01:07:00:01:01:6C:D8";
    NSData *data = [EncodingUtils dataFromHexString:input];
    
    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReceiverRequest alloc] initWithCommand:ReadGlucoseUnit] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    GlucoseUnitSetting *glucoseUnitSetting = (GlucoseUnitSetting *) response.payload;
    XCTAssertEqual([glucoseUnitSetting glucoseUnit], mgPerDL);
}

-(void)testDisplayTimeOffset
{
    NSString *input = @"01:0A:00:01:06:9E:FF:FF:62:47";
    NSData *data = [EncodingUtils dataFromHexString:input];

    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[[ReceiverRequest alloc] initWithCommand:ReadDisplayTimeOffset] dexcomOffsetWithStandardEpoch:0 timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"]];
    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
    TimeOffset *timeOffset = (TimeOffset *) response.payload;
    XCTAssertEqual([timeOffset timeoffsetInSeconds], -25082);
}

// TODO add parsing of Invalid Param responses
//-(void)testInvalidParamResponse
//{
//    NSString *input = @"01:07:00:04:01:99:27";
//    NSData *data = [EncodingUtils dataFromHexString:input];
//
//    ReceiverResponse *response = [DefaultDecoder decodeResponse:data toRequest:[ReadDatabasePagesRequest requestWithRecordType:MeterData pageNumber:0 numberOfPages:4]];
//    XCTAssertNotNil(response, @"response should not be nil for input [%s]", [input UTF8String]);
//    XCTAssertNotNil(response.payload, @"response.payload should not be nil for input [%s]", [input UTF8String]);
//
//}

@end