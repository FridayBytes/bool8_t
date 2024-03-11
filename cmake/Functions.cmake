# set the project target properties
function(set_project_properties target)

    # set the c++ standart library
    set_target_properties(${target}
                          PROPERTIES 
                          CXX_STANDARD ${${PROJECT_NAME}_CXX_STANDARD}
                          CXX_STANDARD_REQUIRED TRUE
                          CXX_EXTENSIONS FALSE)

    # set the build type postfix
    if(${PROJECT_NAME}_BUILD_SHARED_LIBS)
        set_target_properties(${target}  
                              PROPERTIES 
                              DEBUG_POSTFIX _d
                              RELWITHDEBINFO_POSTFIX _rwdi
                              MINSIZEREL_POSTFIX _msr)
    else()
        set_target_properties(${target} 
                              PROPERTIES 
                              DEBUG_POSTFIX _s_d
                              RELWITHDEBINFO_POSTFIX _s_rwdi
                              MINSIZEREL_POSTFIX _s_msr
                              RELEASE_POSTFIX _s)
    endif()

    # select a MSVC runtime library
    if(${PROJECT_NAME}_USE_STATIC_STD_LIBS)
        set(cxx_std_lib "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    else()
        set(cxx_std_lib "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    endif()

    set_target_properties(${target}  
                          PROPERTIES 
                          MSVC_RUNTIME_LIBRARY ${cxx_std_lib})

endfunction()

# set the project target warning options
function(set_project_options target)

    # set compilers
    set(gcc_like_cxx "$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>")
    set(msvc_cxx "$<COMPILE_LANG_AND_ID:CXX,MSVC>")

    # set warning flags
    target_compile_options(${target}
                            PRIVATE
                            "$<${gcc_like_cxx}:$<BUILD_INTERFACE:-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused>>"
                            "$<${gcc_like_cxx}:$<INSTALL_INTERFACE:-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused>>"
                            "$<${msvc_cxx}:$<BUILD_INTERFACE:-W3>>"
                            "$<${msvc_cxx}:$<INSTALL_INTERFACE:-W3>>")

endfunction()


# add a project library
# example: add_project_library(lib
#                              PARENT_DIRECTORY lib
#                              PUBLIC_HEADERS lib.hpp ...  # library public headers
#                              [SOURCES lib.cpp ... ]) # library private headers and sources
function(add_project_library target)

    # parse the function arguments
	cmake_parse_arguments("THIS" "" "PARENT_DIRECTORY" "PUBLIC_HEADERS;SOURCES" ${ARGN})

    if (DEFINED THIS_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Extra unparsed arguments when calling add_project_library: ${THIS_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED THIS_PUBLIC_HEADERS)
        message(FATAL_ERROR "PUBLIC_HEADERS is not used when calling add_project_library")
    endif()

    # get a config name
    if(${PROJECT_NAME}_BUILD_SHARED_LIBS)
        set(config_name SHARED)
    else()
        set(config_name STATIC)
    endif()

    # add a library target
    add_library(${target}
                ${config_name}
                "${THIS_PUBLIC_HEADERS}"
                "${THIS_SOURCES}")

    # set the library flags
    if(${PROJECT_NAME}_BUILD_SHARED_LIBS)

        # Windows export flag
        if(WIN32)
            target_compile_definitions(${target} 
                                       PRIVATE 
                                       ${PROJECT_NAME}_EXPORT)
        endif()

    else()
        # static flag
        target_compile_definitions(${target} 
                                   PUBLIC
                                   ${PROJECT_NAME}_STATIC)
    endif()

    # include the library build directories
    target_include_directories(${target}
                               PUBLIC
                               "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>")

    # set an install path
    if(${PROJECT_NAME}_FRAMEWORK)
        set(library_install_path ${target}.framework)
    else()
        set(library_install_path ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    # include the library install directories
    target_include_directories(${target}
                               PUBLIC
                               "$<INSTALL_INTERFACE:${library_install_path}>")

    # set the library warning flags
    if(${PROJECT_NAME}_USE_WARNING_FLAGS)
        set_project_options(${target})
    endif()

    # set the project properties
    set_project_properties(${target})

    # hide the symbols of the shared libs
    if(${PROJECT_NAME}_BUILD_SHARED_LIBS)
        set_target_properties(${target}
                              PROPERTIES
                              CXX_VISIBILITY_PRESET hidden
                              VISIBILITY_INLINES_HIDDEN TRUE)
    endif()

    # set the public headers                      
    set_target_properties(${target}
                          PROPERTIES
                          PUBLIC_HEADER "${THIS_PUBLIC_HEADERS}")

    # set the framework properties
	if(${PROJECT_NAME}_FRAMEWORK)
		set_target_properties(${target}
		                      PROPERTIES
                              FRAMEWORK TRUE
                              FRAMEWORK_VERSION ${PROJECT_VERSION})
	endif()

    # adapt an install directory to allow distributing dylibs/frameworks 
    # in user's frameworks/application bundle but only if cmake rpath options aren't set
    if(NOT CMAKE_SKIP_RPATH AND NOT CMAKE_SKIP_INSTALL_RPATH AND NOT CMAKE_INSTALL_RPATH 
       AND NOT CMAKE_INSTALL_RPATH_USE_LINK_PATH AND NOT CMAKE_INSTALL_NAME_DIR)

        set_target_properties(${target} 
                              PROPERTIES 
                              INSTALL_NAME_DIR "@rpath"
                              BUILD_WITH_INSTALL_RPATH TRUE)

    endif()

    # install the target
    install(TARGETS ${target}
            EXPORT ${PROJECT_NAME}Targets
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT ${target} 
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT ${target} 
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT ${target} 
            PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${target} COMPONENT ${target} 
            FRAMEWORK DESTINATION "." COMPONENT ${target})

    if(WIN32)

        # install a pdb file
        if(MSVC)
            set(pdb_dir "$<TARGET_FILE_DIR:${target}>")
            set(pdb_config_name "$<TARGET_FILE_BASE_NAME:${target}>.pdb")
            install(FILES "${pdb_dir}/${pdb_config_name}"
                    DESTINATION ${CMAKE_INSTALL_LIBDIR}
                    COMPONENT ${target}
                    OPTIONAL)
        endif()

    endif()

endfunction()


# add an project example
# example: add_project_example(lib
#                              SOURCES ex.cpp ...      # example headers and sources
#                              [RESOURCES ex.png ... ] # example resources
#                              DEPENDS depend_lib ...) # dependent targets
function(add_project_example target)

    # parse the function arguments
	cmake_parse_arguments("THIS" "" "" "SOURCES;RESOURCES;DEPENDS" ${ARGN})

    # throw error if the function has an unparced arguments
    if (DEFINED THIS_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Extra unparsed arguments when calling add_project_library: ${THIS_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED THIS_SOURCES)
        message(FATAL_ERROR "SOURCES is not used when calling add_project_library")
    endif()

    if(NOT DEFINED THIS_DEPENDS)
        message(FATAL_ERROR "DEPENDS is not used when calling add_project_library")
    endif()

    # add an example target
    add_executable(${target}
                   "${THIS_SOURCES}"
                   "${THIS_RESOURCES}")

    # link the compiler flags and depends 
    target_link_libraries(${target} 
                          PRIVATE
                          ${THIS_DEPENDS})

    # set the library warning flags
    if(${PROJECT_NAME}_USE_WARNING_FLAGS)
        set_project_options(${target})
    endif()

    # set the properties
    set_project_properties(${target})

    # set the target's folder (for IDEs that support it, e.g. Visual Studio)
    set_target_properties(${target}
                          PROPERTIES
                          FOLDER examples)

    # set the bundle properties
    if(IOS)
        # Bare executables are not usable on iOS, only bundle applications
        set_target_properties(${target} 
                              PROPERTIES
                              MACOSX_BUNDLE TRUE 
                              MACOSX_BUNDLE_BUNDLE_NAME ${target}
                              MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION})
    endif()

    # install the source files
    install(FILES "${THIS_SOURCES}"
            DESTINATION examples/${target}
            COMPONENT examples)

    # install the resources
    if(DEFINED THIS_RESOURCES)
        install(FILES "${THIS_RESOURCES}"
                DESTINATION examples/${target}/resources
                COMPONENT examples)
    endif()

    # install the target
    install(TARGETS ${target}
            DESTINATION examples/${target}
            COMPONENT examples)
    
    if(WIN32)

        # install a pdb file
        if(MSVC)
            set(PDB_DIR "$<TARGET_FILE_DIR:${target}>")
            set(CURRENT_PDB_NAME "$<TARGET_FILE_BASE_NAME:${target}>.pdb")
            install(FILES "${PDB_DIR}/${CURRENT_PDB_NAME}"
                    DESTINATION examples/${target}
                    COMPONENT examples
                    OPTIONAL)
        endif()

        # copy the dependent dll libraries  
        add_custom_command(TARGET ${target} 
                           POST_BUILD
                           COMMAND ${CMAKE_COMMAND} -E copy -t 
                           $<TARGET_FILE_DIR:${target}> 
                           $<TARGET_RUNTIME_DLLS:${target}>
                           COMMAND_EXPAND_LISTS)

    endif()

endfunction()


# make the project package using CPack
function(project_package)

    # get a config name
    if(${PROJECT_NAME}_BUILD_SHARED_LIBS)
        set(config_name Shared)
    else()
        set(config_name Static)
    endif()

    # set the CPack properties
    set(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME}-${config_name})
    set(CPACK_PACKAGE_INSTALL_DIRECTORY ${PROJECT_NAME}-${PROJECT_VERSION}-${config_name})

    # set the NSIS configurations
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
    set(CPACK_NSIS_DISPLAY_NAME ${PROJECT_NAME})

    # make a CPack config file
    include(CPack)

endfunction()


# export the project
function(project_export)

    # get a config name
    if(${PROJECT_NAME}_BUILD_SHARED_LIBS)
        set(config_name Shared)
    else()
        set(config_name Static)
    endif()

    # set an export targets file
    set(export_targets_file ${PROJECT_NAME}${config_name}Targets.cmake)

    # set an install directory of the export files
    if (${PROJECT_NAME}_FRAMEWORK)
        set(exports_install_dir ${target}.framework/Resources/CMake)
    else()
        set(exports_install_dir ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
    endif()

    # install the export targets file
    install(EXPORT ${PROJECT_NAME}Targets
            FILE ${export_targets_file}
            DESTINATION ${exports_install_dir})

    # generate the export targets file for the build tree
    export(EXPORT ${PROJECT_NAME}Targets
           FILE "${PROJECT_BINARY_DIR}/${export_targets_file}")

    include(CMakePackageConfigHelpers)

    # generate an export config file
    configure_package_config_file(cmake/Config.cmake.in
                                  ${PROJECT_NAME}Config.cmake
                                  INSTALL_DESTINATION ${exports_install_dir})

    # generate a version file for the export config file
    write_basic_package_version_file(${PROJECT_NAME}ConfigVersion.cmake
                                     COMPATIBILITY SameMajorVersion)

    # install the generated export configuration files
    install(FILES
            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
            DESTINATION ${exports_install_dir})

endfunction()