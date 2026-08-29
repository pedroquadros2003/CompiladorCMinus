#ifndef VARIABLEPRINTER_H
#define VARIABLEPRINTER_H


/// bitmask to select output files
typedef enum fileDestination {
    /// NOT STDERR!!! JUST A FILE TO STORE YOUR ERR MSGS!!
    ER_ = 0x1, 
    /// lexical 
    LEX = 0x2, 
    /// LEX AND ERR
    LER = 0x3, 
    /// syntatic analisis
    SYN = 0x4, 
    /// syntatic analisis AND error
    SER = 0x5,
    /// symbol table
    TAB = 0x8,  
    /// symbol table AND error
    TER = 0x9,
    /// code generation
    GEN = 0x10, 
    /// code generation AND error
    GER = 0x11,
    /// ER + LEX + SYN - all up to synthatic analisis AND ERROR
    UP2SYN = 0x7, 
    /// ER + LEX + SYN + TAB - all up to symbol table AND ERROR
    UP2TAB = 0xF, 
    /// ER + LEX + SYN + TAB + GEN - everything, including code generation AND ERROR
    LOGALL = 0x1F, 
} FileDestination; 

void initializePrinter(const char *path, const char* baseName, FileDestination files2open) ;
void pp(FileDestination destination, const char* format, ...);
void doneLEXstartSYN() ;
void doneSYNstartTAB() ;
void doneTABstartGEN() ;
void pc(const char* format, ...) ;
void pce(const char* format, ...) ;
void fflushc();

void closePrinter();

#endif  // VARIABLEPRINTER_H
