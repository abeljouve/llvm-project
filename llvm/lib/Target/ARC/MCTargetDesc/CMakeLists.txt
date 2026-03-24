add_llvm_component_library(LLVMARCDesc
  ARCAsmBackend.cpp
  ARCELFObjectWriter.cpp
  ARCInstPrinter.cpp
  ARCMCCodeEmitter.cpp
  ARCMCTargetDesc.cpp
  ARCMCAsmInfo.cpp

  LINK_COMPONENTS
  MC
  Support
  ARCInfo

  ADD_TO_COMPONENT
  ARC
  )
