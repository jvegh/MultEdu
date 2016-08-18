cmake_minimum_required(VERSION 2.8.4)

PROJECT(Demo NONE)

set(MainFile "Demo.tex")
set(InputFiles
 ${MainFile} Main.tex src/Heading.tex   
 )
 
## !! Do not edit below this line until you know what you are doing!!
include(../../common/UseLATEX.cmake)
# file(GLOB_RECURSE InputFiles ${MainFile} Main.tex src ) # It is WRONG
# This CMakeLists is called from ./build/build
# Make a private copy of MultEdu/build/common
#
set(commonMultEdu "${CMAKE_BINARY_DIR}/../../../../common")
set(MyCommon "${CMAKE_BINARY_DIR}/../../")
#message("Copy "  ${commonMultEdu} " to " ${MyCommon})
file(GLOB_RECURSE MyFiles "${commonMultEdu}/*.*")
file(MAKE_DIRECTORY "${MyCommon}")
#file(COPY "${MyFiles}" DESTINATION "${MyCommon}/")
file(COPY ${commonMultEdu} DESTINATION "${MyCommon}/")
# Include UseLATEX macros

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

# Choose which formats you need
option (NEED_BEAMER "Make the Beamer version of the lecture"  ON)
  # Select sub-option
option (NEED_BOOK "If to use book format PDF" ON)
  # Select book sub-format
  option(NEED_EBOOK "If you need eBook format PDF" ON)
  option(NEED_WEBBOOK "If you need webBook format PDF" ON)
  option(NEED_FancyA4BOOK "If you need fancy A4 size Book format PDF" ON)

cmake_policy(SET CMP0053 NEW)
set(LectureLanguage "magyar")

#
# Assemble list of formats to prepare
#
set(MyFormatList "")
if(NEED_EBOOK)
  set(MyFormatList ${MyFormatList} memoir_eBook)
endif(NEED_EBOOK)
if(NEED_WEBBOOK)
  set(MyFormatList ${MyFormatList} memoir_WEB)
endif(NEED_WEBBOOK)

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
## Choose if 2nd or 1st language
  if(USE_2ND_LANGUAGE)  
    file(APPEND  "${ConfigFile}"  "\\def\\\UseSecondLanguage{yes}\n")
  endif(USE_2ND_LANGUAGE) 
## Handle debug option
  if(DEBUG_MODE)
    file(APPEND  "${ConfigFile}"  "\\def\\EnableDebug{yes} % USE IT ONLY WHEN DEBUGGING!!!\n")
  endif(DEBUG_MODE)

  file(APPEND  "${ConfigFile}"  "\\input{../../common/formats/${MyFormat}}\n")
## Now configure Defines.tex
  configure_file("${ConfigFile}" "${CMAKE_BINARY_DIR}/src/Defines.tex")

  set(MyFileName "${MyLanguage}_${MyFormat}_${MainFile}")
  file(READ  "${CMAKE_BINARY_DIR}/src/Defines.tex" newfile)
  file(WRITE  "${MyFileName}" "${newfile}" )
  file(APPEND  "${MyFileName}" "\\input{Main.tex}\n"  )


  ADD_LATEX_DOCUMENT( "${MyFileName}"   #TARGET_NAME
	INPUTS     ${InputFiles} 
    IMAGE_DIRS fig lst dat
    CONFIGURE src/Defines.tex
    BIBFILES src/Bibliography.bib
    USE_GLOSSARY
    USE_INDEX
   )

# Just use the second language if multiple languages  
  option (USE_SECOND_LANGUAGE "If to use the 2nd or 1st language" ON) 

endforeach(MyFormat)
endforeach(MyLanguage)



