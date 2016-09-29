### This code is for making the wanted format and language of output files
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

### Assemble which output formats to use
#
if(NEED_FORMAT_BEAMER_ME)
	set(MyFormatList ${MyFormatList} beamer_ME)
endif(NEED_FORMAT_BEAMER_ME)
if(NEED_FORMAT_MEMOIR_A4FANCY)
	set(MyFormatList ${MyFormatList} A4Fancy)
endif(NEED_FORMAT_MEMOIR_A4FANCY)
if(NEED_FORMAT_MEMOIR_eBook)
	set(MyFormatList ${MyFormatList} eBook)
endif(NEED_FORMAT_MEMOIR_eBook)
if(NEED_FORMAT_MEMOIR_WEB)
	set(MyFormatList ${MyFormatList} WEB)
endif(NEED_FORMAT_MEMOIR_WEB)

### Prepare a version file, as if were config file
set(VersionFile "${CMAKE_BINARY_DIR}/src/Version.tex.in" )
file(WRITE  "${VersionFile}"  "%% Project file version; prepared by CMake, will be overwritten\n")
file(APPEND  "${VersionFile}"  "\\def\\Version{" "${PROJECT_VERSION}" "}\n")
configure_file("${VersionFile}" "${CMAKE_BINARY_DIR}/src/Version.tex")
 
### The beginning of the output generating loop
foreach(MyLanguage ${MyLanguageList})
foreach(MyFormat ${MyFormatList})
  ### Prepare a new config file
  #
  set(ConfigFile "${CMAKE_BINARY_DIR}/src/Defines.tex.in" )
  file(WRITE "${ConfigFile}" "%% This file is prepared by CMake, will be overwritten\n")
## Handle the language(s)
  file(APPEND  "${ConfigFile}"  "\\def\\FirstLanguage{"  "${FirstLanguage}"  "} % In dual language macros\n")
  file(APPEND  "${ConfigFile}"  "\\def\\SecondLanguage{" "${SecondLanguage}" "} % In dual language macros\n")
  file(APPEND  "${ConfigFile}"  "\\def\\LectureLanguage{" "${MyLanguage}" "} % Define language features\n")
  if(USE_SECOND_LANGUAGE)
    file(APPEND  "${ConfigFile}"  "\\def\\UseSecondLanguage{YES}   % Now make output in '" "${MyLanguage}"   "'\n")
  endif(USE_SECOND_LANGUAGE)
  file(APPEND  "${ConfigFile}"  "\\def\\EnableDebug{YES} % USE IT ONLY WHEN DEVELOPING FEATURES!!!\n")
  file(APPEND  "${ConfigFile}"  "\\input{src/Version.tex} % Read the CMake-generated version\n")
  
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
    SET(USE_SECOND_LANGUAGE ON CACHE BOOL "If to use the 2nd or 1st language" FORCE)
  else(NOT USE_SECOND_LANGUAGE) 
  endif(NOT USE_SECOND_LANGUAGE)
endforeach(MyLanguage)
