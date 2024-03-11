# set a library headers directory
set(include_dir "${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}")

# set the project config file paths
set(config_file_input "${include_dir}/Config.hpp.in")
set(config_file_output "${include_dir}/Config.hpp")

# make the project config file
configure_file("${config_file_input}"
               "${config_file_output}"
               @ONLY)

# install the project config file
install(FILES "${config_file_output}"
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})

# add the libraries
add_project_library(bool8_t
                    PUBLIC_HEADERS 
                    "${include_dir}/bool8_t.hpp"
                    SOURCES 
                    bool8_t.cpp)