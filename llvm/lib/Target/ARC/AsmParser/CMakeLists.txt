add_llvm_component_library(LLVMARCAsmParser
  ARCAsmParser.cpp

  LINK_COMPONENTS
  MC
  MCParser
  Support
  ARCDesc
  ARCInfo

  ADD_TO_COMPONENT
  ARC
  )
