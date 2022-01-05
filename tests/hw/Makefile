# This is the default target, which will be built when 
# you invoke make
.PHONY: all
all: hw

# This rule tells make how to build hw from hw.cpp
hw: hw.c
    c99 -o hw hw.c

# This rule tells make to copy hw to the binaries subdirectory,
# creating it if necessary
.PHONY: install
install:
    mkdir -p binaries
    cp -p hw binaries

# This rule tells make to delete hw and hw.o
.PHONY: clean 
clean:
    rm -f hw
