#import <PEGKit/PKParser.h>

enum {
    CREATETABLESTMT_TOKEN_KIND_NOT_UPPER = 14,
    CREATETABLESTMT_TOKEN_KIND_CREATE,
    CREATETABLESTMT_TOKEN_KIND_EXISTS,
    CREATETABLESTMT_TOKEN_KIND_TEMPORARY,
    CREATETABLESTMT_TOKEN_KIND_TABLE,
    CREATETABLESTMT_TOKEN_KIND_TEMP,
    CREATETABLESTMT_TOKEN_KIND_IF,
    CREATETABLESTMT_TOKEN_KIND_SEMI_COLON,
};

@interface CreateTableStmtParser : PKParser

@end

