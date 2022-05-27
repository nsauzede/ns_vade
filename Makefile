#    Vade - Tool for managing C/C++ source code using GNU Make
#    Copyright (C) 2017  Nicolas Sauzede <nsauzede@laposte.net>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# support using this Makefile from foreign location
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKE:=make -f $(mkfile_path)
VADEROOT:=$(shell dirname $(mkfile_path))

AR:=ar

SMKDIR=test -d $(@D) || mkdir -p $(@D)

SRCS=$(patsubst src/testing,,$(wildcard src/*))
DIRS=$(patsubst src/%,%,$(SRCS))
PKGS=$(patsubst %,pkg/%,$(DIRS))
LIBS=$(patsubst src/%,pkg/lib%.a,$(SRCS))

TESTS=$(patsubst %,bin/%_test.exe,$(DIRS))
#RUN_TESTS=$(patsubst %,bin/%_test.exe/RUN,$(DIRS))
#RUN_TESTS+=$(patsubst %,%/RUN,$(wildcard bin/*_test.exe))
RUN_TESTS+=$(patsubst %,%/RUN,$(wildcard bin/*.exe))

_AT_=@
_AT_1=
#AT2=$(AT)printf "\t$1\t%s\n" $2 &&
_AT2_=@printf "\t$1\t%s\n" $2 &&
_AT2_1=
AT2=$(_AT2_$(V))
AT=$(_AT_$(V))

#_SILENTMAKE_=-s
_SILENTMAKE_=--no-print-directory
_SILENTMAKE_1=
SILENTMAKE=$(_SILENTMAKE_$(V))

BRIEF2=$(AT2) $($1)
#BRIEF2=$(_AT2_$(V)) $($1)
BRIEF=$(call BRIEF2,$1,`basename $@`)

#DEBUG?=-g
ifdef $(DEBUG)
CFLAGS+=$(DEBUG)
CXXFLAGS+=$(DEBUG)
endif

OPT?=-O0
ifdef OPT
CFLAGS+=$(OPT)
CXXFLAGS+=$(OPT)
endif

#CXXSTD?=11
CXXSTD?=17

CSTD?=c11

ifdef CSTD
CFLAGS+=-std=c11
endif

ifdef CXXSTD
CXXFLAGS+=-std=c++$(CXXSTD)
endif

CFLAGS+=-Wall -Werror -Wextra
#CFLAGS+=-pedantic
CXXFLAGS+=-Wall -Werror -Wextra -pedantic

CFLAGS+=-fPIC
CXXFLAGS+=-fPIC

CFLAGS+=-Isrc
CXXFLAGS+=-Isrc

CFLAGS+=-I$(VADEROOT)/src
CXXFLAGS+=-I$(VADEROOT)/src

.PHONY:all check clean clobber

all: pkg bin $(PKGS)

info:
	$(AT)echo "DIRS=$(DIRS)"

pkg bin:
#	echo "V=${V}"
	$(AT)mkdir $@

pkg/$(STEM)/%.o: src/$(STEM)/%.c
	$(AT)$(SMKDIR)
	$(call BRIEF,CC) -c -o $@ $^ $(CFLAGS)

pkg/$(STEM)/%.d: src/$(STEM)/%.c
	$(AT)$(SMKDIR)
	$(call BRIEF,CC) -MM -MP -o $@ $^ $(CFLAGS)

pkg/$(STEM)/%.o: src/$(STEM)/%.cpp
	$(AT)$(SMKDIR)
	$(call BRIEF,CXX) -c -o $@ $^ $(CXXFLAGS)

pkg/$(STEM)/%.d pkg/$(STEM)/%.d: src/$(STEM)/%.cpp
	$(AT)$(SMKDIR)
	$(call BRIEF,CXX) -MT pkg/$(STEM)/$(patsubst %.cpp,%.o,$(notdir $^)) -M -MP -o $@ $^ $(CXXFLAGS)

pkg/$(STEM)/%.d: $(VADEROOT)/src/testing/%.c
	$(AT)$(SMKDIR)
	$(call BRIEF,CC) -MT pkg/$(STEM)/$(patsubst %.cpp,%.o,$(notdir $^)) -M -MP -o $@ $^ $(CFLAGS) -DTESTING_SYMS="\"$(TESTING_SYMS)\""

pkg/$(STEM)/%.o: $(VADEROOT)/src/testing/%.c
	$(AT)$(SMKDIR)
	$(call BRIEF,CC) -c -o $@ $^ $(CFLAGS) -DTESTING_SYMS="\"$(TESTING_SYMS)\""

pkg/$(STEM)/%.o: $(VADEROOT)/src/testing/%.cpp
	$(AT)$(SMKDIR)
	$(call BRIEF,CXX) -c -o $@ $^ $(CXXFLAGS) -DTESTING_SYMS="\"$(TESTING_SYMS)\""

#DEPS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.h:,%.o,$(shell test -f pkg/$(STEM)/$(STEM).d && cat pkg/$(STEM)/$(STEM).d | grep '.h:')))
#pkg/$(STEM)/lib%.a: $(LIBOBJS) $(DEPS) | $(LIBOBJS)
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "LIBOBJS=$(LIBOBJS)"
#	$(call BRIEF,AR) cr $@ $^
#	$(call BRIEF,AR) cr $@ $^

bin/lib%_test.so: $(TESTOBJS) | $(TESTOBJS)
	$(AT)$(SMKDIR)
#	$(AT)echo "%.so: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(call BRIEF,CC) -o $@ $^ -shared -fPIC

LIB=pkg/$(STEM)/lib$(STEM).a
TESTLIB=pkg/$(STEM)/lib$(STEM)_test.a

SOLIBOBJS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(wildcard src/$(STEM)/export.cpp)))
SOLIB=$(patsubst src/$(STEM)/%.o,bin/lib$(STEM).so,$(patsubst %.cpp,%.o,$(wildcard src/$(STEM)/export.cpp)))
TESTLIB+=$(SOLIB)

bin/lib$(STEM).so: $(SOLIBOBJS) | $(SOLIBOBJS)
	$(AT)$(SMKDIR)
#	$(AT)echo "%.so: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(call BRIEF,CXX) -o $@ $^ -shared -fPIC

#TESTING_SYMS=$(shell nm pkg/$(STEM)/*_test.o | grep \ T\ $(STEM)_Test | cut -f 3 -d ' ')
#TESTING_SYMS+=$(shell nm pkg/$(STEM)/*_test.o | grep \ T\ _Z[0-9]*$(STEM)_Test | cut -f 3 -d ' ')
#bin/%_test.exe: $(TESTLIB) $(LIB) | $(TESTLIB) $(LIB)
#	$(AT)echo "%_test.exe: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic $(CFLAGS)
#	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic

include $(pkg/$(STEM)/*.d)

TESTOBJS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(wildcard src/$(STEM)/*_test.c)))
TESTOBJS+=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(wildcard src/$(STEM)/*_test.cpp)))

TESTOBJ0=$(patsubst $(VADEROOT)/src/testing/%.o,pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(wildcard $(VADEROOT)/src/testing/testing.c)))

TESTOBJS+=$(TESTOBJ0)

#pkg/$(STEM)/lib$(STEM)_test.a: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "lib%_test.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(call BRIEF,AR) cr $@ $^

LIBTESTOBJS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(wildcard src/$(STEM)/*_test.c)))
LIBTESTOBJS+=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(wildcard src/$(STEM)/*_test.cpp)))
LIBTESTOBJS+=pkg/$(STEM)/testing.o
LIBTESTDEPSGEN=$(patsubst %.o,%.d,$(LIBTESTOBJS))
pkg/$(STEM)/lib$(STEM)_test.a: $(LIBTESTDEPSGEN) $(LIBTESTOBJS) | $(LIBTESTDEPSGEN) $(LIBTESTOBJS)
	$(AT)$(SMKDIR)
	$(AT)echo "AR $@" ; $(AR) cr $@ $(LIBTESTOBJS)

LIBOBJS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(patsubst src/$(STEM)/%_test.c,,$(wildcard src/$(STEM)/*.c))))
LIBOBJS+=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(patsubst src/$(STEM)/%_test.cpp,,$(wildcard src/$(STEM)/*.cpp))))
#DEPSGEN=$(patsubst src/$(STEM)/%.cpp,pkg/$(STEM)/%_cpp.d,$(patsubst src/$(STEM)/%.c,pkg/$(STEM)/%_c.d,$(PKGLIBSRCS)))
LIBDEPSGEN=$(patsubst %.o,%.d,$(LIBOBJS))
#DEPS=$(shell test -n "$(PKGSRCS)" && cat pkg/$(STEM)/*.d | grep '.h:')
LIBDEPS=$(foreach pkg,$(shell test -z "$(wildcard pkg/$(STEM)/*d)" || cat pkg/$(STEM)/*.d | grep 'src/.*\.h:' | cut -f 2 -d "/"),pkg/$(pkg)/lib$(pkg).a)
pkg/$(STEM)/lib$(STEM).a: pkg/$(STEM)/$(STEM).d $(LIBDEPSGEN) $(LIBOBJS) $(LIBDEPS) | $(LIBDEPSGEN) $(LIBOBJS) $(LIBDEPS)
	$(AT)$(SMKDIR)
	$(AT)echo "LIBDEPSGEN=$(LIBDEPSGEN)"
	$(AT)echo "LIBDEPS=$(LIBDEPS)"
	$(AT)echo "AR $@" ; $(AR) cr $@ $(LIBOBJS)

LIB=pkg/$(STEM)/lib$(STEM).a
bin/$(STEM).exe: $(LIB) | $(LIB)
	$(AT)$(SMKDIR)
	$(AT)echo "CXX $@" ; $(CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive

TESTLDLIBS=$(shell cat pkg/$(STEM)/*.d | grep "/usr/include/dlfcn.h" > /dev/null && echo -ldl)
bin/$(STEM)_test.exe: LDLIBS+=$(TESTLDLIBS)

LIBTEST= pkg/$(STEM)/lib$(STEM)_test.a pkg/$(STEM)/lib$(STEM).a
bin/$(STEM)_test.exe: $(LIBTEST) | $(LIBTEST)
	$(AT)$(SMKDIR)
	$(AT)echo "CXX $@" ; $(CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive $(LDLIBS)

#bin/%.exe: $(LIB) | $(LIB)
#	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive

.PHONY:$(PKGS)
$(PKGS):
	$(AT)$(SMKDIR)
#	$(AT)echo "pkg/%: how to build $@ ? stem=$* F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)$(MAKE) $(SILENTMAKE) pkg/$(@F)/$(@F).d STEM=$(@F) V=$(V)
	$(AT)$(MAKE) $(SILENTMAKE) pkg/$(@F)/lib$(@F).a STEM=$(@F) V=$(V)
	$(AT)nm pkg/$(@F)/lib$(@F).a | grep "T main" > /dev/null && $(MAKE) $(SILENTMAKE) bin/$(@F).exe STEM=$(@F) V=$(V) || true
#	$(AT)test -f src/$(@F)/$(@F).h || $(MAKE) $(SILENTMAKE) bin/$(@F).exe STEM=$(@F) V=$(V)
#	$(AT)test -z "$(wildcard src/$(@F)/*_test.*)" || $(MAKE) $(SILENTMAKE) bin/$(@F)_test.exe STEM=$(@F) V=$(V)

	$(AT)$(MAKE) $(SILENTMAKE) pkg/$(@F)/lib$(@F)_test.a STEM=$(@F) V=$(V)
	$(AT)nm pkg/$(@F)/lib$(@F)_test.a | grep "_Test" > /dev/null && $(MAKE) $(SILENTMAKE) bin/$(@F)_test.exe STEM=$(@F) V=$(V) || true

.PHONY:$(RUN_TESTS)
$(RUN_TESTS):
	$(call BRIEF2,RUN,./$(@D)) ./$(@D)
#	$(call BRIEF2,RUN,./$(@F)) ./$(@F)

_check: $(RUN_TESTS)

check: all
	$(AT)$(MAKE) $(SILENTMAKE) _check

clean:
	$(call BRIEF2,RM,pkg) -Rf pkg

clobber: clean
	$(call BRIEF2,RM,bin) -Rf bin
