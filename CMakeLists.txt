cmake_minimum_required(VERSION 3.16)
project(GameOfLife CXX)

# Find Verilator
find_package(verilator HINTS ${VERILATOR_ROOT} $ENV{VERILATOR_ROOT})

# SystemC dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Find SystemC using SystemC's CMake integration
find_package(SystemCLanguage PATHS ${SYSTEMC_HOME})

add_executable(VGameOfLife_tb GameOfLife_tb.cc)

set_property(
	TARGET VGameOfLife_tb
	PROPERTY CXX_STANDARD ${SystemC_CXX_STANDARD}
)

verilate(VGameOfLife_tb SYSTEMC COVERAGE TRACE
	INCLUDE_DIRECTORIES "."
	SOURCES GameOfLife.v
)

verilator_link_systemc(VGameOfLife_tb)

