cmake_minimum_required(VERSION 2.8.4)

cmake_policy(SET CMP0048 NEW)
PROJECT(Demo VERSION 0.05.03 LANGUAGES NONE)

set(MainFile "Demo.tex")	# Is used to define output file name
file(GLOB_RECURSE InputFiles RELATIVE "${CMAKE_SOURCE_DIR}" src/*.tex)
set(InputFiles ${MainFile} Main.tex ${InputFiles}
#   src/Heading.tex src/Abstract.tex src/Copyright.tex src/Glossary.tex
#   src/Compiling.tex  src/Figures.tex src/General.tex src/Listings.tex src/Organizing.tex src/Sectioning.tex
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
option (NEED_BOTH_LANGUAGES "Make both language versions of the course" ON)
#
# Choose if to use the second or 1st language, if only one language
#
  option (USE_SECOND_LANGUAGE "If to use the 2nd or 1st language" OFF) 
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
 
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
### 
### !! Do not edit below this line until you know what you are doing!!
###
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# This is the UseLatex macros
include(../../common/UseLATEX.cmake)
#
# This CMakeLists is called from ./build/build to allow using private copy of ../../common
# Make a private copy of MultEdu/build/common
#
set(commonMultEdu "${CMAKE_BINARY_DIR}/../../../../common")
set(MyCommon "${CMAKE_BINARY_DIR}/../../")
file(GLOB_RECURSE MyFiles "${commonMultEdu}/*.*")
file(MAKE_DIRECTORY "${MyCommon}")
file(COPY ${commonMultEdu} DESTINATION "${MyCommon}/")

# This CMakeLists is called from ./build/build

### Assemble which language(s) to use
#
if(NEED_BOTH_LANGUAGES)
  set(MyLanguageList  ${FirstLanguage} ${SecondLanguage})
  SET(USE_SECOND_LANGUAGE OFF CACHE BOOL "If to use the 2nd or 1st language" FORCE)
else(NEED_BOTH_LANGUAGES)
  if(USE_SECOND_LANGUAGE)
    set(MyLanguageList ${SecondLanguage})
  else(USE_SECOND_LANGUAGE)
    set(MyLanguageList ${FirstLanguage})
  endif(USE_SECOND_LANGUAGE)
endif(NEED_BOTH_LANGUAGES)

set(MyFormatList ${MyFormatList} beamer_ME)
set(MyFormatList ${MyFormatList} eBook)
set(MyFormatList ${MyFormatList} WEB)
set(MyFormatList ${MyFormatList} A4Fancy)
  
### The beginning of the output generating loop
foreach(MyLanguage ${MyLanguageList})
foreach(MyFormat ${MyFormatList})
  ### Prepare a new config file
  #
  set(ConfigFile "${CMAKE_SOURCE_DIR}/src/Defines.tex.in" )
  file(WRITE "${ConfigFile}" "%% This file is prepared by CMake, will be overwritten\n")
## Handle the language(s)
  file(APPEND  "${ConfigFile}"  "\\def\\FirstLanguage{"  "${FirstLanguage}"  "} % In dual language macros\n")
  file(APPEND  "${ConfigFile}"  "\\def\\SecondLanguage{" "${SecondLanguage}" "} % In dual language macros\n")
  file(APPEND  "${ConfigFile}"  "\\def\\LectureLanguage{" "${MyLanguage}" "} % What you want to print\n")
  if(USE_SECOND_LANGUAGE)
    file(APPEND  "${ConfigFile}"  "\\def\\UseSecondLanguage{YES}   % Now make output in '" "${MyLanguage}"   "'\n")
  endif(USE_SECOND_LANGUAGE)
  file(APPEND  "${ConfigFile}"  "\\def\\Version{" "${PROJECT_VERSION}" "}\n")
  file(APPEND  "${ConfigFile}"  "\\def\\EnableDebug{YES} % USE IT ONLY WHEN DEVELOPING FEATURES!!!\n")
  
if( ${MyFormat} MATCHES  "beamer")
  ## Make beamer-only settings
  if(DISABLE_WIDE_SCREEN)
    file(APPEND  "${ConfigFile}"  "\\def\\DisableWideScreen{YES} % I need 4:3 ratio\n")
  endif(DISABLE_WIDE_SCREEN)
  if(DISABLE_TOC)
    file(APPEND  "${ConfigFile}"  "\\def\\DisableTOC{YES} % I need no Table of Contents at all \n")
  else(DISABLE_TOC)
    if(DISABLE_SECTION_TOC)
    file(APPEND  "${ConfigFile}"  "\\def\\DisableSectionTOC{YES} % you need chapters but sections in Table of Contents\n")
    endif(DISABLE_SECTION_TOC)  
  endif(DISABLE_TOC)
else( ${MyFormat} MATCHES  "beamer") 
  ## Make printed-only settings     
  set(MyIndex "USE_INDEX")
endif( ${MyFormat} MATCHES  "beamer")
  
    option ( DISABLE_TOC "Disable table of contents, in Beamer only" OFF)
    option ( DISABLE_SECTION_TOC "Disable sections in table of contents, in Beamer only" OFF)
  
  file(APPEND  "${ConfigFile}"  "\\input{../../common/formats/${MyFormat}}\n")

  ### Now the configuration file is ready, make configuration
  set(PrefixFile "${CMAKE_BINARY_DIR}/src/Defines.tex")
  configure_file("${ConfigFile}" ${PrefixFile})
###
## Now prepend it to the original Main.tex and prepare new source files 
  set(MyFileName "${MyLanguage}_${MyFormat}_${PROJECT_VERSION}_${MainFile}")
  message("Preparing file " '${MyFileName}')
  file(READ    ${PrefixFile}   newfile)
  file(WRITE   ${MyFileName} "${newfile}" )
  file(APPEND  ${MyFileName} "\\input{Main.tex}\n"  )

### This part prepares the LaTeX target files
#
## Find out if to disable 'USE_INDEX'

if( ${MyFormat} MATCHES  "beamer")
  set(MyIndex "")
else( ${MyFormat} MATCHES  "beamer")      
  set(MyIndex "USE_INDEX")
endif( ${MyFormat} MATCHES  "beamer")

  ADD_LATEX_DOCUMENT( ${MyFileName}  #TARGET_NAME
    INPUTS     "${InputFiles}" 
    IMAGE_DIRS fig  			  # Allow to copy figures subdirectory
    CONFIGURE src/Defines.tex	  # Prepare a config file for manual compile
#    BIBFILES src/Bibliography.bib # Use bibliography file
    USE_GLOSSARY                  # Use glossary           
    ${MyIndex}                     # Use index, if not a beamer format
   )
endforeach(MyFormat)

# Be sure to use the second language if multiple languages  
  if(NOT USE_SECOND_LANGUAGE)
#    message("Use 2nd language WAS OFF")
    SET(USE_SECOND_LANGUAGE ON CACHE BOOL "If to use the 2nd or 1st language" FORCE)
#    message("Use 2nd language is switched on")
  else(NOT USE_SECOND_LANGUAGE) 
#     message("Use 2nd language is now on")
  endif(NOT USE_SECOND_LANGUAGE)
endforeach(MyLanguage)

### http://stackoverflow.com/questions/9680420/looking-for-a-cmake-clean-command-to-clear-up-cmake-output
###
### Clean up all generated files

add_custom_target(clean-all
   COMMAND ${CMAKE_BUILD_TOOL} clean
   COMMAND ${CMAKE_COMMAND} -P clean-all.cmake
)

add_custom_target(clean-cmake-files
   COMMAND ${CMAKE_COMMAND} -P clean-all.cmake
)

## clean-all.cmake
set(cmake_generated ${CMAKE_BINARY_DIR}/CMakeCache.txt
                    ${CMAKE_BINARY_DIR}/cmake_install.cmake  
                    ${CMAKE_BINARY_DIR}/Makefile
                    ${CMAKE_BINARY_DIR}/CMakeFiles
)

foreach(file ${cmake_generated})

  if (EXISTS ${file})
     file(REMOVE_RECURSE ${file})
  endif()

endforeach(file)

