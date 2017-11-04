###########################################################################
#
#  Library:   PkModeling
#
#  Copyright (c) Kitware Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0.txt
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################

#-----------------------------------------------------------------------------
# PkModeling dependencies - Projects should be TOPOLOGICALLY ordered
#-----------------------------------------------------------------------------
set(PkModeling_DEPENDENCIES
  zlib
  DCMTK
  ITK
  )

if(PkModeling_BUILD_APPS)
  list(APPEND PkModeling_DEPENDENCIES
    SlicerExecutionModel
    )
endif()

#-----------------------------------------------------------------------------
# WARNING - No change should be required after this comment
#           when you are adding a new external project dependency.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Make sure ${PkModeling_BINARY_DIR}/${PROJECT_NAME_LC}-build/bin exists
# May be used by some external project to install libs
if(NOT EXISTS ${PkModeling_BINARY_DIR}/${PROJECT_NAME_LC}-build/bin)
  file(MAKE_DIRECTORY ${PkModeling_BINARY_DIR}/${PROJECT_NAME_LC}-build/bin)
endif()

#-----------------------------------------------------------------------------
set(proj PkModeling)

ExternalProject_Include_Dependencies(PkModeling DEPENDS_VAR PkModeling_DEPENDENCIES)

set(PkModeling_EP_CMAKE_ARGS)
if(NOT PkModeling_BUILD_SLICER_EXTENSION)
  set(PkModeling_EP_CMAKE_ARGS CMAKE_ARGS
    -USlicer_DIR
    )
endif()

set(PkModeling_EP_CMAKE_CACHE_ARGS)
# XXX Workaround https://gitlab.kitware.com/cmake/cmake/issues/15448
#     and explicitly pass GIT_EXECUTABLE and Subversion_SVN_EXECUTABLE
foreach(varname IN ITEMS GIT_EXECUTABLE Subversion_SVN_EXECUTABLE)
  if(EXISTS "${${varname}}")
    list(APPEND PkModeling_EP_CMAKE_CACHE_ARGS -D${varname}:FILEPATH=${${varname}})
  endif()
endforeach()

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  DOWNLOAD_COMMAND ""
  ${PkModeling_EP_CMAKE_ARGS}
  CMAKE_CACHE_ARGS
    -DPkModeling_SUPERBUILD:BOOL=OFF
    -DPkModeling_SUPERBUILD_BINARY_DIR:PATH=${PkModeling_BINARY_DIR}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS_INIT:STRING=${CMAKE_CXX_FLAGS_INIT}
    -DCMAKE_C_FLAGS_INIT:STRING=${CMAKE_C_FLAGS_INIT}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    -DEXTENSION_SUPERBUILD_BINARY_DIR:PATH=${${PROJECT_NAME}_BINARY_DIR}
    ${PkModeling_EP_CMAKE_CACHE_ARGS}
  SOURCE_DIR ${PkModeling_SOURCE_DIR}
  BINARY_DIR ${PkModeling_BINARY_DIR}/${PROJECT_NAME_LC}-build
  PREFIX ${PROJECT_NAME_LC}-prefix
  USES_TERMINAL_CONFIGURE 1
  USES_TERMINAL_BUILD 1
  INSTALL_COMMAND ""
  DEPENDS
    ${PkModeling_DEPENDENCIES}
  )

ExternalProject_AlwaysConfigure(${proj})
