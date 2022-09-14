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
VADEMAKEINTERNAL:=make -f $(VADEROOT)/Makefile_internal SILENTMAKE=$(SILENTMAKE) VADEROOT=$(VADEROOT)

AR:=ar
NM:=nm

#SRCS=$(patsubst src/testing,,$(wildcard src/*))
SRCS=$(wildcard src/*)
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
_SILENTMAKE_=--no-print-directory -s
_SILENTMAKE_1=
SILENTMAKE=$(_SILENTMAKE_$(V))

BRIEF2=$(AT2) $($1)
#BRIEF2=$(_AT2_$(V)) $($1)
BRIEF=$(call BRIEF2,$1,`basename $@`)

#OPT?=-O2
ifdef OPT
CFLAGS+=$(OPT)
CXXFLAGS+=$(OPT)
else
CFLAGS+=-g -O0
CXXFLAGS+=-g -O0
endif

CXXSTD?=11
#CXXSTD?=17

CSTD?=c11

ifdef CSTD
CFLAGS+=-std=c11
endif

ifdef CXXSTD
CXXFLAGS+=-std=c++$(CXXSTD)
endif

VADE_CFLAGS+=-Wall -Wextra
VADE_CFLAGS+=-Werror
VADE_CXXFLAGS+=-Wall -Wextra
VADE_CXXFLAGS+=-Werror

CFLAGS+=-fPIC
CXXFLAGS+=-fPIC

CFLAGS+=-Isrc
CXXFLAGS+=-Isrc

CFLAGS+=-I$(VADEROOT)/src
CXXFLAGS+=-I$(VADEROOT)/src

.PHONY:all check clean clobber

all: pkg bin $(PKGS)
build: all
test: check

pkg bin:
	$(AT)mkdir $@

DEPSCFILES=$(patsubst src/$(STEM)/%.c,$(STEM)/%,$(wildcard src/$(STEM)/*.c))
DEPSCPPFILES=$(patsubst src/$(STEM)/%.cpp,$(STEM)/%,$(wildcard src/$(STEM)/*.cpp))
pkg/$(STEM)/%.d:
#	$(AT)echo "DEPSCFILES=$(DEPSCFILES)"
#	$(AT)echo "DEPSCPPFILES=$(DEPSCPPFILES)"
	$(AT)echo -n > $@
	$(AT)for cf in $(DEPSCFILES); do \
		$(CC) -MM -MT "pkg/$$cf.o" src/$$cf.c $(CFLAGS) -DTESTING_SYMS | $(VADEROOT)/deps.py >> $@ || exit 1; \
	done
	$(AT)for cf in $(DEPSCPPFILES); do \
		$(CXX) -MM -MT "pkg/$$cf.o" src/$$cf.cpp $(CXXFLAGS) -DTESTING_SYMS | $(VADEROOT)/deps.py >> $@ || exit 1; \
	done
	$(AT)cat $@ >> pkg/vade_dep.d

pkg/$(STEM)/%.o: src/$(STEM)/%.c
	$(call BRIEF,CC) -c -o $@ $< $(CFLAGS)

pkg/$(STEM)/%.o: src/$(STEM)/%.cpp
	$(call BRIEF,CXX) -c -o $@ $< $(CXXFLAGS)

pkg/$(STEM)/%.o: $(VADEROOT)/src/testing/%.c
	$(call BRIEF,CC) -c -o $@ $^ $(CFLAGS) -DTESTING_SYMS="\"$(TESTING_SYMS)\"" $(VADE_CFLAGS)

pkg/$(STEM)/%.o: $(VADEROOT)/src/testing/%.cpp
	$(call BRIEF,CXX) -c -o $@ $^ $(CXXFLAGS) -DTESTING_SYMS="\"$(TESTING_SYMS)\"" $(VADE_CXXFLAGS)

TESTOBJS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(wildcard src/$(STEM)/*_test.c)))
TESTOBJS+=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(wildcard src/$(STEM)/*_test.cpp)))

TESTOBJ0=$(patsubst $(VADEROOT)/src/testing/%.o,pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(wildcard $(VADEROOT)/src/testing/testing.c)))

TESTOBJS+=$(TESTOBJ0)

pkg/testing/libtesting.a:
#	$(AT)echo "Skipping special libtesting.a"
	true

pkg/testing/testing.a:
#	$(AT)echo "Skipping special testing.a"
	true

pkg/testing/testing.o:
#	$(AT)echo "Skipping special testing.o"
	true

lib%.a: %.a
#	@echo "AUTO LIB tgt=$@ deps=$^"
	$(call BRIEF,AR) crsT $@ $^

lib%.a: %.o
#	@echo "AUTO LIB tgt=$@ deps=$^"
	$(call BRIEF,AR) crsT $@ $^

%_test.a: %_test.o
#	@echo "AUTO test LIB tgt=$@ deps=$^"
	$(call BRIEF,AR) crsT $@ $^

PROJ=$(patsubst %.a,%,$(@F))
ALIBOBJS=$(patsubst src/$(PROJ)/%.o,pkg/$(PROJ)/%.o,$(patsubst %.c,%.o,$(patsubst src/$(PROJ)/%_test.c,,$(wildcard src/$(PROJ)/*.c))))
ALIBOBJS+=$(patsubst src/$(PROJ)/%.o,pkg/$(PROJ)/%.o,$(patsubst %.cpp,%.o,$(patsubst src/$(PROJ)/%_test.cpp,,$(wildcard src/$(PROJ)/*.cpp))))
%.a: %.o
#	@echo "AUTO LIB tgt=$@ deps=$^ PROJ=$(PROJ)"
	$(VADEMAKEINTERNAL) $(SILENTMAKE) pkg/$(PROJ)/$(PROJ).o STEM=$(PROJ) V=$(V)
	$(call BRIEF,AR) crsT $@ $^
#	$(VADEMAKEINTERNAL) $(SILENTMAKE) pkg/$(PROJ)/$(PROJ).a STEM=$(PROJ) V=$(V)

pkg/$(STEM)/Zlib$(STEM)_test.a: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "lib%_test.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(call BRIEF,AR) cr $@ $^

LIBOBJS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(patsubst src/$(STEM)/%_test.c,,$(wildcard src/$(STEM)/*.c))))
LIBOBJS+=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(patsubst src/$(STEM)/%_test.cpp,,$(wildcard src/$(STEM)/*.cpp))))

pkg/$(STEM)/lib%_test.a: pkg/$(STEM)/%_test.a
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "3LIBOBJS=$(LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(call BRIEF,AR) crsT $@ $^

pkg/$(STEM)/%_test.a: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "2LIBOBJS=$(2LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(call BRIEF,AR) crsT $@ $^

pkg/$(STEM)/lib%.a: pkg/$(STEM)/%.a
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "0LIBOBJS=$(LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(call BRIEF,AR) crsT $@ $^

DEPS=$(shell test -f pkg/$(STEM)/$(STEM).d && cat pkg/$(STEM)/$(STEM).d | $(VADEROOT)/deps.py)
#DEPS=$(patsubst %.h,%.o,$(patsubst src/%,pkg/%,$(shell test -f pkg/$(STEM)/$(STEM).d && cat pkg/$(STEM)/$(STEM).d | grep -v "_test.o" | grep -v "testing" | grep '.h' | cut -f 3 -d " ")))
#pkg/$(STEM)/lib%.a: $(LIBOBJS) $(DEPS) | $(LIBOBJS)
#pkg/$(STEM)/lib%.a: $(LIBOBJS) | $(LIBOBJS)
pkg/$(STEM)/%.a: $(LIBOBJS) | $(LIBOBJS)
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "1LIBOBJS=$(LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(call BRIEF,AR) crsT $@ $^

bin/lib%_test.so: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "%.so: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(call BRIEF,CC) -o $@ $^ -shared -fPIC

LIB=pkg/$(STEM)/lib$(STEM).a
TESTLIB=pkg/$(STEM)/lib$(STEM)_test.a

SOLIBOBJS=$(patsubst src/$(STEM)/%.o,pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(wildcard src/$(STEM)/export.cpp)))
SOLIB=$(patsubst src/$(STEM)/%.o,bin/lib$(STEM).so,$(patsubst %.cpp,%.o,$(wildcard src/$(STEM)/export.cpp)))
TESTLIB+=$(SOLIB)

bin/lib$(STEM).so: $(SOLIBOBJS) | $(SOLIBOBJS)
#	$(AT)echo "%.so: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(call BRIEF,CXX) -o $@ $^ -shared -fPIC

TESTING_SYMS=$(shell $(NM) pkg/$(STEM)/*_test.o | grep \ T\ $(STEM)_Test | cut -f 3 -d ' ')
TESTING_SYMS+=$(shell $(NM) pkg/$(STEM)/*_test.o | grep \ T\ _Z[0-9]*$(STEM)_Test | cut -f 3 -d ' ')
#bin/%_test.exe: $(TESTLIB) $(LIB) | $(TESTLIB) $(LIB)
bin/%_test.exe: $(TESTLIB) | $(TESTLIB)
#	$(AT)echo "%_test.exe: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic $(CFLAGS)
	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic

bin/%.exe: $(LIB) | $(LIB)
	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive

.PHONY:$(PKGS)

pkg/vade_dep.d:
#	@echo "SRCS=$(SRCS)"
#	@echo "DIRS=$(DIRS)"
#	@echo "PKGS=$(PKGS)"
#	@echo "LIBS=$(LIBS)"
#	@echo "TESTS=$(TESTS)"
	$(AT)for d in $(DIRS); do \
		test -d pkg/$$d || mkdir -p pkg/$$d; \
		$(MAKE) $(SILENTMAKE) pkg/$$d/$$d.d STEM=$$d V=$(V) || exit 1; \
	done

$(PKGS): pkg/vade_dep.d
#	@echo "SRCS=$(SRCS)"
#	@echo "DIRS=$(DIRS)"
#	@echo "PKGS=$(PKGS)"
#	@echo "LIBS=$(LIBS)"
#	@echo "TESTS=$(TESTS)"
#	@echo "tgt=$@"
#	$(AT)echo "pkg/%: how to build $@ ? stem=$* F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT0)test -d $(@) || echo "MKDIR $@" && mkdir -p $(@)
#	$(AT)test -d $(@) || mkdir -p $(@)
#	$(AT)$(MAKE) $(SILENTMAKE) pkg/$(@F)/$(@F).d STEM=$(@F) V=$(V)
#	$(MAKE) $(SILENTMAKE) pkg/$(@F).d STEM=$(@F) V=$(V)
	$(AT)$(VADEMAKEINTERNAL) $(SILENTMAKE) pkg/$(@F)/lib$(@F).a STEM=$(@F) V=$(V)
	$(AT)test -f pkg/$(@F)/lib$(@F).a && $(NM) pkg/$(@F)/lib$(@F).a | grep T\ main > /dev/null && $(VADEMAKEINTERNAL) $(SILENTMAKE) bin/$(@F).exe STEM=$(@F) V=$(V) || true
	$(AT)test -z "$(wildcard src/$(@F)/*_test.*)" || $(VADEMAKEINTERNAL) $(SILENTMAKE) bin/$(@F)_test.exe STEM=$(@F) V=$(V)

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
