# Relocatable SDK target for the single-header Meson installation.
if(NOT TARGET nlohmann_json::nlohmann_json)
  get_filename_component(_nlohmann_prefix "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
  add_library(nlohmann_json::nlohmann_json INTERFACE IMPORTED GLOBAL)
  set_target_properties(nlohmann_json::nlohmann_json PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_nlohmann_prefix}/include")
  unset(_nlohmann_prefix)
endif()
