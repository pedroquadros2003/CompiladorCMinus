cmake_minimum_required(VERSION 3.10)

project(ces41lex VERSION 0.1 LANGUAGES C)

include(CMakePrintHelpers)
cmake_print_variables(CMAKE_VERSION)

SET(DOPARSE TRUE CACHE BOOL "if false, bison is not used, and only lexical analysis is performed")

# https://cmake.org/cmake/help/latest/module/FindFLEX.html
if(DOPARSE) 
   find_package(BISON) 
endif()
find_package(FLEX)

SET(CES41_SRC "src" CACHE FILEPATH "Directory with student sources")

include_directories(  ${CMAKE_CURRENT_BINARY_DIR} include lib)

FILE(GLOB labSrc ${CES41_SRC}/*.c  )
FILE(GLOB lablib lib/*.c  )

#file(GLOB_RECURSE C_FILES ${CES41_SRC}/*.c)
#set_source_files_properties(${C_FILES} {CMAKE_CURRENT_BINARY_DIR}/lexer.c )

FLEX_TARGET(scanner ${CES41_SRC}/cminus.l  ${CMAKE_CURRENT_BINARY_DIR}/lexer.c )
if(DOPARSE) 
  BISON_TARGET(myparser ${CES41_SRC}/cminus.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
  ADD_FLEX_BISON_DEPENDENCY(scanner myparser)
endif()

message("   * DOPARSE = ${DOPARSE}")
message("   * Flex OUT = ${FLEX_scanner_OUTPUTS}")
if(DOPARSE) 
  message("   * BisonOUT = ${BISON_myparser_OUTPUTS}")
else()
  message("   * Bison NOT CALLED. Only Lexical Analysis")
endif()
message("   * SRC FILES = ${labSrc}")

#include_directories(${CMAKE_CURRENT_BINARY_DIR})

if(DOPARSE) 
    add_executable(mycmcomp
        ${labSrc}
        ${lablib}
        ${BISON_myparser_OUTPUTS}
        ${FLEX_scanner_OUTPUTS}
    )
    target_include_directories(mycmcomp PUBLIC ${CES41_SRC})
    target_link_libraries(mycmcomp )
else()
    add_executable(mycmcomp
        ${labSrc}
        ${lablib}
        ${FLEX_scanner_OUTPUTS}
    )
    target_include_directories(mycmcomp PUBLIC ${CES41_SRC})   
    target_link_libraries(mycmcomp ${FLEX_LIBRARIES})
endif()

 #${FLEX_LIBRARIES})
 # compilation problem of undefined yylex - noyywrap - it only works with one src file
 # https://stackoverflow.com/questions/1480138/undefined-reference-to-yylex

add_custom_target(runmycmcomp ALL
  COMMENT "running mycmcomp"
  COMMAND ../scripts/runcmcomp
  DEPENDS mycmcomp
  VERBATIM
  USES_TERMINAL
)

add_custom_target(rundiff ALL
  COMMENT "running diff"
  COMMAND ../scripts/rundiff
  DEPENDS runmycmcomp
  VERBATIM
  USES_TERMINAL
)

add_custom_target(ddiff 
  COMMENT "running detail diff"
  COMMAND ../scripts/rundetaildiff
  DEPENDS runmycmcomp
  VERBATIM
  USES_TERMINAL
)

add_custom_target(lexdiff 
  COMMENT "running lex diff (no syntax errors)"
  COMMAND ../scripts/runLEXdiff
  DEPENDS runmycmcomp
  VERBATIM
  USES_TERMINAL
)

########## compiling the tiny compiler  #############3

if (DOPARSE)
FLEX_TARGET(tinyscanner TinyGeracaoCodigo/tiny.l  ${CMAKE_CURRENT_BINARY_DIR}/tinylexer.c )
BISON_TARGET(tinyparser TinyGeracaoCodigo/tiny.y ${CMAKE_CURRENT_BINARY_DIR}/tinyparser.c)
ADD_FLEX_BISON_DEPENDENCY(tinyscanner tinyparser)
FILE(GLOB tinycode TinyGeracaoCodigo/*.c  )
add_executable(tiny
        ${tinycode}
        ${lablib}
        ${BISON_tinyparser_OUTPUTS}
        ${FLEX_tinyscanner_OUTPUTS}
    )
target_include_directories(tiny PUBLIC TinyGeracaoCodigo )
target_link_libraries(tiny)
else()
FLEX_TARGET(tinyscanner TinyFlex/tiny.l  ${CMAKE_CURRENT_BINARY_DIR}/tinylexer.c )
FILE(GLOB tinycode TinyFlex/*.c  )
add_executable(tiny
        ${tinycode}
        ${lablib}
        ${FLEX_tinyscanner_OUTPUTS}
    )
target_include_directories(tiny PUBLIC TinyFlex )
target_link_libraries(tiny ${FLEX_LIBRARIES})
endif()



# explaning about diff options
# diff -Z (trail space) -b (change space) -B (blank lines)

#######################################33
### previous attempts, less succesfull
# works, but file is hardcoded
# add_custom_target(mdcout ALL
#   COMMAND mylex ../example/mdc.cm > mdc.out
#   COMMENT "running diff for mdc.cm"
#   COMMAND diff -ZbB ../output/mdc.out  mdc.out
#   DEPENDS mylex
# )

# problem: does not run when lex is up to date
#add_custom_command( TARGET lex POST_BUILD
#  COMMAND lex ../example/mdc.cm > mdc.out
#  COMMENT "running diff for mdc.cm"
#  COMMAND diff -ZbB ../output/mdc.out  mdc.out
#  MAIN_DEPENDENCY lex
#)
##########################################3


