#include "log.h"
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

/// IF SET, ALL PRINTOUTS WILL CALL FLUSH. INNEFICIENT, DEBUG ONLY! 
#define DEBUG_LOG_ALWAYS_FLUSH 0 

/// error output 
FILE* fileER_;
/// lexical analysis output
FILE* fileLEX;
/// syntatic analysis output
FILE* fileSYN;
/// symbol table output
FILE* fileTAB;
/// generated code output
FILE* fileGEN;
/// sets which files will be opened. e.g. if you will only implement up to symbol table generation, do not open the file to output the generated code.
FileDestination filesOpened; 
/// marks the current stage of the compilation, used for pc and pce functions
FileDestination currentState; 

void splitFileName(const char *fullFileName, char *path, char *fileName, char *extension);

/**
 * \brief open the files specified by files2open in the directory specified by path, with the basename specified
 * 
 * * sets currentState to LEX - the first stage of compilation is always lexical analysis
 * * the supplied main code already calls this function adequately. Probably, students will not need to change it.
 * 
 * \param path directory for detailed output files
 * \param basename the radical part of the file name
 * \param files2open choose which files to open. If not all compilation stages will be run, you may choose to not open all files
 * 
 * example usage:
 * 
 * `initializePrinter(detailpath, pgm, LOGALL); // open detailed output files into the path given by detailpath, with the basename given by pgm, and LOGALL means all files will be opened`
 * 
 */
void initializePrinter(const char *path, const char* baseName, FileDestination files2open) {
    char basepath[512];
    char basefileName[256];
    char baseextension[256];
    splitFileName(baseName, basepath, basefileName, baseextension);
    currentState = LEX;
    
    if (!path) { fprintf(stderr, "called initializePrinter with path == NULL"); abort(); }
    if (!baseName) { fprintf(stderr, "called initializePrinter with baseName == NULL"); abort(); }
    
    char filename[512];

    if (files2open & ER_) { 
        int ret = snprintf(filename, sizeof(filename), "%s/%s_err.txt",path, basefileName);
        if (ret < 0) { fprintf(stderr,"FAILED WRITING FILENAME _err FOR %s",baseName); abort(); }
        fileER_ = fopen(filename, "w");
    }

    if (files2open & LEX) { 
        snprintf(filename, sizeof(filename), "%s/%s_lex.txt",path, basefileName);
        fileLEX = fopen(filename, "w");
    }

    if (files2open & SYN) { 
        snprintf(filename, sizeof(filename), "%s/%s_syn.txt",path, basefileName);
        fileSYN = fopen(filename, "w");
    }

    if (files2open & TAB) { 
        snprintf(filename, sizeof(filename), "%s/%s_tab.txt",path, basefileName);
        fileTAB = fopen(filename, "w");
    }
    
    if (files2open & GEN) { 
        snprintf(filename, sizeof(filename), "%s/%s_gen.tm",path, basefileName);
        fileGEN = fopen(filename, "w");
    }
    filesOpened = files2open;
}//initializePrinter

/// closes all opened files
void closePrinter() {
    if (fileER_ != NULL) fclose(fileER_);
    if (fileLEX != NULL) fclose(fileLEX);
    if (fileSYN != NULL) fclose(fileSYN);
    if (fileTAB != NULL) fclose(fileTAB);
    if (fileGEN != NULL) fclose(fileGEN);
    
}//closePrinter

/// sets the curent compilation stage to SYN (syntatic analysis)
void doneLEXstartSYN() {
    currentState = SYN;
}
/// sets the curent compilation stage to TAB (symbol table)
void doneSYNstartTAB() {
    currentState = TAB;
}
/// sets the curent compilation stage to GEN (code generation)
void doneTABstartGEN() {
    currentState = GEN;
}

/// flushes all opened files.
void fflushc() {
    if (currentState & ER_ & filesOpened) fflush(fileER_);
    if (currentState & LEX & filesOpened) fflush(fileLEX);
    if (currentState & SYN & filesOpened) fflush(fileSYN);
    if (currentState & TAB & filesOpened) fflush(fileTAB);
    if (currentState & GEN & filesOpened) fflush(fileGEN);
}

/**
 * \brief prints in CURRENT output file AND stdout
 * 
 * * use this to **print usual output messages into the current compilation stage output**.
 * * this function will be used most of the time.
 * 
 * \param format variadic parameters, to be used as fprintf
 * 
 * \par flushes if DEBUG_LOG_ALWAYS_FLUSH is set
 * 
 * example usage:
 * 
 * `pc("my message n. %i is %s",var_int,var_pointerchar); // prints on stdout AND the output corresponding to the current compilation stage.`
 * 
 */
void pc(const char* format, ...) {
    
     if (NULL == format) {
         fprintf(stderr,"called pc( with NULL format!"); abort(); }
    
     char buffer[1000];
     va_list args;
     va_start(args, format);
     vsprintf(buffer, format, args);
     
     if (currentState & ER_ & filesOpened) fprintf(fileER_, "%s", buffer);
     if (currentState & LEX & filesOpened) fprintf(fileLEX, "%s", buffer);
     if (currentState & SYN & filesOpened) fprintf(fileSYN, "%s", buffer);
     if (currentState & TAB & filesOpened) fprintf(fileTAB, "%s", buffer);
     if (currentState & GEN & filesOpened) fprintf(fileGEN, "%s", buffer);
     
     fprintf(stdout,"%s", buffer);
     va_end(args);
    
     if ( DEBUG_LOG_ALWAYS_FLUSH ) fflushc(); /// flushes all output files. INNEFICIENT, ONLY FOR DEBUG!
     
}//pc

/**
 * \brief prints in CURRENT output file AND stdout AND error file (3-way)
 * 
 * use this to **print error messages into the current compilation stage output**.
 * 
 * \param format variadic parameters, to be used as fprintf
 * 
 * \par flushes if DEBUG_LOG_ALWAYS_FLUSH is set
 * 
 * example usage:
 * 
 * `pce("my message n. %i is %s",var_int,var_pointerchar); // prints on stdout AND error AND the output corresponding to the current compilation stage.`
 * 
 */
 void pce(const char* format, ...) {
     
    if (NULL == format) {
         fprintf(stderr,"called pc( with NULL format!"); abort(); }
    
     char buffer[1000];
     va_list args;
     va_start(args, format);
     vsprintf(buffer, format, args);
     
     
     if (currentState & LEX & filesOpened) fprintf(fileLEX, "%s", buffer);
     if (currentState & SYN & filesOpened) fprintf(fileSYN, "%s", buffer);
     if (currentState & TAB & filesOpened) fprintf(fileTAB, "%s", buffer);
     if (currentState & GEN & filesOpened) fprintf(fileGEN, "%s", buffer);
     
     if (ER_ & filesOpened) fprintf(fileER_, "%s", buffer);
     
     fprintf(stdout,"%s", buffer);
     va_end(args);
    
     if ( DEBUG_LOG_ALWAYS_FLUSH ) fflushc(); /// flushes all output files. INNEFICIENT, ONLY FOR DEBUG!
}//pce


/**
 * \brief prints in both chosen output file(s) AND stdout
 * 
 * this function is intended for **hardcoded fine control over output files**.  
 * 
 * * it is a *variadic function* which accepts a variable number of arguments. It repasses its arguments to fprintf, printing into the output files indicated by the destination argument.
 * * it does not care about the current state.
 * * It checks if the file was set to be opened before printing
 * 
 * \param destination bitflag setting which output files will be used
 * \param format after the destination flag, this function should be used as fprintf.
 * 
 * \par flushes if DEBUG_LOG_ALWAYS_FLUSH is set
 * 
 * \par example usage (check the possible flags on the [enum fileDestination](@ref fileDestination) ) :
 * 
 * `pp(SYN, "my message n. %i is %s",var_int,var_pointerchar); // prints on stdout and sintatic analysis output`
 * 
 * `pp(SYN | LEX, "my message n. %i is %s",var_int,var_pointerchar); // prints on stdout, lexic and sintatic analysis outputs`
 * 
 * `pp(TAB | ERR, "my message n. %i is %s",var_int,var_pointerchar); // prints on stdout, symbol table and error outputs`
 * 
 */
void pp(FileDestination destination, const char* format, ...) {
        
     char buffer[1000];
     va_list args;
     va_start(args, format);
     vsprintf(buffer, format, args);
     
     if (destination & ER_ & filesOpened) fprintf(fileER_, "%s", buffer);
     if (destination & LEX & filesOpened) fprintf(fileLEX, "%s", buffer);
     if (destination & SYN & filesOpened) fprintf(fileSYN, "%s", buffer);
     if (destination & TAB & filesOpened) fprintf(fileTAB, "%s", buffer);
     if (destination & GEN & filesOpened) fprintf(fileGEN, "%s", buffer);
     
     fprintf(stdout,"%s", buffer);
     va_end(args);
    
     if ( DEBUG_LOG_ALWAYS_FLUSH ) fflushc(); /// flushes all output files. INNEFICIENT, ONLY FOR DEBUG!
}//pp

/**
 * \brief aux func: split fullFileName (with full path) into path/fileName/extension
 * \par students usually will not need to use this function
 */
void splitFileName(const char *fullFileName, char *path, char *fileName, char *extension) {
    const char *lastSlash = strrchr(fullFileName, '/');
    const char *lastBackslash = strrchr(fullFileName, '\\');
    const char *lastSeparator = (lastSlash > lastBackslash) ? lastSlash : lastBackslash;

    if (lastSeparator) {
        // Extract path
        strncpy(path, fullFileName, lastSeparator - fullFileName + 1);
        path[lastSeparator - fullFileName + 1] = '\0';
    } else {
        // No path component
        path[0] = '\0';
    }

    // Extract file name and extension
    const char *fileNameStart = lastSeparator ? lastSeparator + 1 : fullFileName;
    const char *lastDot = strrchr(fileNameStart, '.');
    
    if (lastDot) {
        // Extract file name
        strncpy(fileName, fileNameStart, lastDot - fileNameStart);
        fileName[lastDot - fileNameStart] = '\0';

        // Extract extension
        strcpy(extension, lastDot + 1);
    } else {
        // No extension
        strcpy(fileName, fileNameStart);
        extension[0] = '\0';
    }
}

