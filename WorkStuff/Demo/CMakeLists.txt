cmake_minimum_required(VERSION 2.8.4)

cmake_policy(SET CMP0048 NEW)
PROJECT(Demo VERSION 0.02.02 LANGUAGES NONE)

set(MainFile "Demo.tex")	# Is used to define output file name
set(InputFiles ${MainFile} Main.tex
   src/Heading.tex src/Abstract.tex src/Copyright.tex src/Glossary.tex
   src/Figures.tex src/General.tex src/Listings.tex src/Organizing.tex src/Sectioning.tex
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
set(FirstLanguage "magyar") # language must be set!
#
# Select second language setting
#
set(SecondLanguage "english") # Usual setting language
#
# Choose if you need both languages
#
option (NEED_BOTH_LANGUAGES "Make both language versions of the course" ON)
#
# Choose if to use the second or 1st language, if only one language
#
if(NOT NEED_BOTH_LANGUAGES)
  option (USE_SECOND_LANGUAGE "If to use the 2nd or 1st language" OFF) 
endif(NOT NEED_BOTH_LANGUAGES)
#

### General-purpose settings
# Choose whether you need debugging support
#
option (DEBUG_MODE "Include debug support for lecture making"  ON)
#

 
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
### 
### !! Do not edit below this line until you know what you are doing!!
###
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

set(MyLanguageList ${MyLanguageList} magyar)
set(MyLanguageList ${MyLanguageList} english)
set(MyFormatList ${MyFormatList} eBook)
set(MyFormatList ${MyFormatList} WEB)
set(MyFormatList ${MyFormatList} A4Fancy)
set(MyFormatList ${MyFormatList} beamer_ME)
  
### The beginning of the output generating loop
foreach(MyLanguage ${MyLanguageList})
foreach(MyFormat ${MyFormatList})
  message("Preparing " "format '${MyFormat}'" " in language " "'${MyLanguage}'")
  ### Prepare a new config file
  #
  set(ConfigFile "${CMAKE_SOURCE_DIR}/src/Defines.tex.in" )
  file(WRITE "${ConfigFile}" "%% This file is prepared by CMake, will be overwritten\n")
## Handle the language
  file(APPEND  "${ConfigFile}"  "\\def\\LectureLanguage{" "${MyLanguage}" "}\n")
  file(APPEND  "${ConfigFile}"  "\\def\\Version{" "${PROJECT_VERSION}" "}\n")
  file(APPEND  "${ConfigFile}"  "\\def\\EnableDebug{" "yes" "} % USE IT ONLY WHEN DEBUGGING!!!\n")
  file(APPEND  "${ConfigFile}"  "\\input{../../common/formats/${MyFormat}}\n")

### Now the configuration file is ready, make configuration
## Now configure Defines.tex
  set(PrefixFile "${CMAKE_BINARY_DIR}/src/Defines.tex")
  configure_file("${ConfigFile}" ${PrefixFile})
###
## Now prepend it to the original Main.tex and  prepare new source files 
  set(MyFileName "${MyLanguage}_${MyFormat}_${PROJECT_VERSION}_${MainFile}")
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
    ${MyIndex}                     # Use index
   )

# Just use the second language if multiple languages  
  option (USE_SECOND_LANGUAGE "If to use the 2nd or 1st language" ON) 
endforeach(MyFormat)
endforeach(MyLanguage)



