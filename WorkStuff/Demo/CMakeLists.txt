cmake_minimum_required(VERSION 2.8.4)

cmake_policy(SET CMP0048 NEW)
PROJECT(Demo VERSION 0.05.04 LANGUAGES NONE)

set(MainFile "Demo.tex")	# Is used to define output file name
file(GLOB_RECURSE InputFiles RELATIVE "${CMAKE_SOURCE_DIR}" src/*.tex)
set(InputFiles ${MainFile} Main.tex ${InputFiles}
)
### CMake will copy all source files to its own area
### These standard subdirectories are copied by default
 file(COPY "${CMAKE_SOURCE_DIR}/dat" DESTINATION "${CMAKE_BINARY_DIR}")
 file(COPY "${CMAKE_SOURCE_DIR}/lst" DESTINATION "${CMAKE_BINARY_DIR}")
## Copy extra directories or files similarly, if you need
 

### Select language settings
### If you use dual language source, provide here which source follows first and which is the second
### It might change from project to project!
#
set(FirstLanguage "english") # language must be set!
#
# Select second language setting
#
set(SecondLanguage "magyar") # Usual setting language
#
# Choose if you need both languages
#
option (NEED_BOTH_LANGUAGES "Make both language versions of the course" OFF)
#
# Choose if to use the second or 1st language, if only one language
#
  option (USE_SECOND_LANGUAGE "If to use the 2nd or 1st language" ON)
#

### General-purpose settings
# Choose whether you need debugging support
#
option (DEBUG_MODE "Include debug support for lecture making"  ON)
#

### Beamer-related settings
# 
  option ( DISABLE_WIDE_SCREEN "Use 4:3 screen rather than 16:9" OFF)
  option ( DISABLE_TOC "Disable table of contents, in Beamer only" OFF)
  option ( DISABLE_SECTION_TOC "Disable sections in table of contents, in Beamer only" OFF)
  option ( ENABLE_TIMER "Display passed time, beamer only" OFF)
  option ( LECTURE_TIME_MAX "Maximum time for the presentation" 15)

## Output format related settings
#
  option ( NEED_FORMAT_BEAMER_ME "Generate output in format beamer_ME " ON)
  option ( NEED_FORMAT_MEMOIR_A4FANCY "Generate output in format memoir A4Fancy " ON)
  option ( NEED_FORMAT_MEMOIR_eBook "Generate output in format memoir eBook " OFF)
  option ( NEED_FORMAT_MEMOIR_WEB "Generate output in format memoir WEB " ON)

###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
### 
### !! Do not edit below this line until you know what you are doing!!
###
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

include(../../common/UseLATEX.cmake)     # This is the UseLatex macros
include(../../common/MultEdu.cmake)      # The main part of MultEdu compilation
include(../../common/CleanEdu.cmake)     # Some cleanup