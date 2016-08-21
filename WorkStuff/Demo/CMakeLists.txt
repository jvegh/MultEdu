cmake_minimum_required(VERSION 2.8.4)

cmake_policy(SET CMP0048 NEW)
PROJECT(Demo VERSION 0.02.1 LANGUAGES NONE)

set(MainFile "Demo.tex")	# Is used to define output file name
set(InputFiles ${MainFile} Main.tex
   src/Heading.tex src/Abstract.tex src/Copyright.tex src/Glossary.tex
   src/Figures.tex src/Listings.tex src/Sectioning.tex
)
## Copy extra directories, if you need
 file(COPY "${CMAKE_SOURCE_DIR}/dat" DESTINATION "${CMAKE_BINARY_DIR}")
 file(COPY "${CMAKE_SOURCE_DIR}/lst" DESTINATION "${CMAKE_BINARY_DIR}")

# Select language setting
#
set(FirstLanguage "magyar") # language must be set!
#
# Select second language setting
#
set(SecondLanguage "english") # Usual setting language
#
# Choose whether you need debugging support
#
option (DEBUG_MODE "Include debug support for lecture making"  ON)
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
 
## !! Do not edit below this line until you know what you are doing!!
include(../../common/UseLATEX.cmake)
# This CMakeLists is called from ./build/build
# Make a private copy of MultEdu/build/common
#
set(commonMultEdu "${CMAKE_BINARY_DIR}/../../../../common")
set(MyCommon "${CMAKE_BINARY_DIR}/../../")
file(GLOB_RECURSE MyFiles "${commonMultEdu}/*.*")
file(MAKE_DIRECTORY "${MyCommon}")
file(COPY ${commonMultEdu} DESTINATION "${MyCommon}/")

# This CMakeLists is called from ./build/build

#?? set(MyLanguageList ${MyLanguageList} magyar)
#?? set(MyLanguageList ${MyLanguageList} english)
#  set(MyFormatList ${MyFormatList} eBook)
#  set(MyFormatList ${MyFormatList} WEB)
#  set(MyFormatList ${MyFormatList} A4Fancy)
  set(MyFormatList ${MyFormatList} beamertry)
  
  
#
# Assemble list of languages to prepare
#
set(MyLanguageList "")
if(NEED_BOTH_LANGUAGES)
  set(MyLanguageList ${MyLanguageList} ${FirstLanguage} ${SecondLanguage})
  option (USE_SECOND_LANGUAGE "If to use the 2nd or 1st language" OFF) 
else(NEED_BOTH_LANGUAGES)
if(USE_2ND_LANGUAGE)
  set(MyLanguageList ${MyLanguageList} ${SecondLanguage})
else(USE_2ND_LANGUAGE)
  set(MyLanguageList ${MyLanguageList} ${FirstLanguage})
endif(USE_2ND_LANGUAGE)
endif(NEED_BOTH_LANGUAGES)
  
  
### The beginning of the output generating loop
foreach(MyLanguage ${MyLanguageList})
foreach(MyFormat ${MyFormatList})
  message("Preparing " "format '${MyFormat}'" " in language " "'${MyLanguage}'")
  ## Prepare a new config file
  #
  set(ConfigFile "${CMAKE_SOURCE_DIR}/src/Defines.tex.in" )
  file(WRITE "${ConfigFile}" "%% This file is prepared by CMake, will be overwritten\n")
## Handle the language
  file(APPEND  "${ConfigFile}"  "\\def\\LectureLanguage{" "${MyLanguage}" "}\n")
#  file(APPEND  "${ConfigFile}"  "\\documentclass{memoir}\n")
  file(APPEND  "${ConfigFile}"  "\\def\\Version{" "${PROJECT_VERSION}" "}\n")
  file(APPEND  "${ConfigFile}"  "\\def\\EnableDebug{" "yes" "} % USE IT ONLY WHEN DEBUGGING!!!\n")
  file(APPEND  "${ConfigFile}"  "\\input{../../common/formats/${MyFormat}}\n")
## Now configure Defines.tex
  set(PrefixFile "${CMAKE_BINARY_DIR}/src/Defines.tex")
  configure_file("${ConfigFile}" ${PrefixFile})
  
## At this point we have a configuration in "${CMAKE_BINARY_DIR}/src/Defines.tex"
## Now prepend it to the original Main.tex and  prepare new source files 
  set(MyFileName "${MyLanguage}_${MyFormat}_${PROJECT_VERSION}_${MainFile}")
  file(READ    ${PrefixFile}   newfile)
  file(WRITE   ${MyFileName} "${newfile}" )
  file(APPEND  ${MyFileName} "\\input{Main.tex}\n"  )

  ADD_LATEX_DOCUMENT( ${MyFileName}   #TARGET_NAME
  INPUTS     "${InputFiles}" 
    IMAGE_DIRS fig 
    CONFIGURE src/Defines.tex
    BIBFILES src/Bibliography.bib
    USE_GLOSSARY
    USE_INDEX
   )

# Just use the second language if multiple languages  
  option (USE_SECOND_LANGUAGE "If to use the 2nd or 1st language" ON) 

endforeach(MyFormat)
endforeach(MyLanguage)



