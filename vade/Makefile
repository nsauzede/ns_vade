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
VADEROOT:=$(shell dirname $(mkfile_path))/..
VADEMAKEINTERNAL:=make -f $(VADEROOT)/vade/Makefile_internal SILENTMAKE=$(SILENTMAKE) VADEROOT=$(VADEROOT)

AR:=ar
NM:=nm
NASM:=nasm
VALGRIND:=valgrind
VGOPTS:=--exit-on-first-error=yes --error-exitcode=128
VGOPTS$(L)+=-q
VGOPTS+=--leak-check=full

RUNTEST:=$(VALGRIND) $(VGOPTS)

#SRCS=$(patsubst vade/src/test,,$(wildcard vade/src/*))
SRCS=$(wildcard vade/src/*)
DIRS=$(patsubst vade/src/%,%,$(SRCS))
PKGS=$(patsubst %,vade/pkg/%,$(DIRS))
LIBS=$(patsubst vade/src/%,vade/pkg/lib%.a,$(SRCS))

TESTS=$(patsubst %,vade/bin/%_test.exe,$(DIRS))
#RUN_TESTS=$(patsubst %,vade/bin/%_test.exe/RUN,$(DIRS))
RUN_TESTS+=$(patsubst %,%/RUN,$(wildcard vade/bin/*_test.exe))
#RUN_TESTS+=$(patsubst %,%/RUN,$(wildcard vade/bin/*.exe))

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

TFLAGS:=
ifdef L
TFLAGS+=-v
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

CFLAGS+=-DVADE_VERSION=$(VADE_VERSION)
CXXFLAGS+=-DVADE_VERSION=$(VADE_VERSION)

CFLAGS+=-fPIC
CXXFLAGS+=-fPIC

CFLAGS+=-Ivade/src
CXXFLAGS+=-Ivade/src

CFLAGS+=-I$(VADEROOT)/vade/src
CXXFLAGS+=-I$(VADEROOT)/vade/src

.PHONY:all check clean clobber

all: vade/pkg vade/bin $(PKGS)
build: all
test: check

vade/pkg vade/bin:
	$(AT)mkdir $@

DEPSCFILES=$(patsubst vade/src/$(STEM)/%.c,$(STEM)/%,$(wildcard vade/src/$(STEM)/*.c))
DEPSCPPFILES=$(patsubst vade/src/$(STEM)/%.cpp,$(STEM)/%,$(wildcard vade/src/$(STEM)/*.cpp))
DEPSASMFILES=$(patsubst vade/src/$(STEM)/%.asm,$(STEM)/%,$(wildcard vade/src/$(STEM)/*.asm))
vade/pkg/$(STEM)/%.d:
#	$(AT)echo "DEPSCFILES=$(DEPSCFILES)"
#	$(AT)echo "DEPSCPPFILES=$(DEPSCPPFILES)"
#	$(AT)echo "DEPSASMFILES=$(DEPSASMFILES)"
	$(AT)echo -n > $@
	$(AT)for f in $(DEPSCFILES); do \
		$(CC) -MM -MT "vade/pkg/$$f.o" vade/src/$$f.c $(CFLAGS) -DTEST_SYMS | $(VADEROOT)/bin/deps.py >> $@ || exit 1; \
	done
	$(AT)for f in $(DEPSCPPFILES); do \
		$(CXX) -MM -MT "vade/pkg/$$f.o" vade/src/$$f.cpp $(CXXFLAGS) -DTEST_SYMS | $(VADEROOT)/bin/deps.py >> $@ || exit 1; \
	done
	$(AT)for f in $(DEPSASMFILES); do \
		echo "vade/pkg/$$f.bin: vade/src/$$f.asm" >> $@ || exit 1; \
		echo "vade/pkg/$(STEM)/lib$(STEM).a: | vade/pkg/$$f.bin" >> $@ || exit 1 ; \
	done
	$(AT)cat $@ >> vade/pkg/vade_dep.d

vade/pkg/$(STEM)/%.o: vade/src/$(STEM)/%.c
	$(call BRIEF,CC) -c -o $@ $< $(CFLAGS)

vade/pkg/$(STEM)/%.o: vade/src/$(STEM)/%.cpp
	$(call BRIEF,CXX) -c -o $@ $< $(CXXFLAGS)

vade/pkg/$(STEM)/%.o: $(VADEROOT)/vade/src/test/%.c
	$(call BRIEF,CC) -c -o $@ $^ $(CFLAGS) -DTEST_SYMS="\"$(TEST_SYMS)\"" $(VADE_CFLAGS)

vade/pkg/$(STEM)/%.o: $(VADEROOT)/vade/src/test/%.cpp
	$(call BRIEF,CXX) -c -o $@ $^ $(CXXFLAGS) -DTEST_SYMS="\"$(TEST_SYMS)\"" $(VADE_CXXFLAGS)

TESTOBJS=$(patsubst vade/src/$(STEM)/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(wildcard vade/src/$(STEM)/*_test.c)))
TESTOBJS+=$(patsubst vade/src/$(STEM)/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(wildcard vade/src/$(STEM)/*_test.cpp)))

TESTOBJ0=$(patsubst $(VADEROOT)/vade/src/test/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(wildcard $(VADEROOT)/vade/src/test/test.c)))

TESTOBJS+=$(TESTOBJ0)

vade/pkg/test/libtest.a:
#	$(AT)echo "Skipping special libtest.a"
	true

vade/pkg/test/test.a:
#	$(AT)echo "Skipping special test.a"
	true

vade/pkg/test/test.o:
#	$(AT)echo "Skipping special test.o"
	true

lib%.a: %.a
#	@echo "AUTO LIB tgt=$@ deps=$^"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

lib%.a: %.o
#	@echo "AUTO LIB tgt=$@ deps=$^"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

%_test.a: %_test.o
#	@echo "AUTO test LIB tgt=$@ deps=$^"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

PROJ=$(patsubst %.a,%,$(@F))
ALIBOBJS=$(patsubst vade/src/$(PROJ)/%.o,vade/pkg/$(PROJ)/%.o,$(patsubst %.c,%.o,$(patsubst vade/src/$(PROJ)/%_test.c,,$(wildcard vade/src/$(PROJ)/*.c))))
ALIBOBJS+=$(patsubst vade/src/$(PROJ)/%.o,vade/pkg/$(PROJ)/%.o,$(patsubst %.cpp,%.o,$(patsubst vade/src/$(PROJ)/%_test.cpp,,$(wildcard vade/src/$(PROJ)/*.cpp))))
%.a: %.o
#	@echo "AUTO LIB tgt=$@ deps=$^ PROJ=$(PROJ)"
	$(VADEMAKEINTERNAL) $(SILENTMAKE) vade/pkg/$(PROJ)/$(PROJ).o STEM=$(PROJ) V=$(V)
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^
#	$(VADEMAKEINTERNAL) $(SILENTMAKE) vade/pkg/$(PROJ)/$(PROJ).a STEM=$(PROJ) V=$(V)

vade/pkg/$(STEM)/Zlib$(STEM)_test.a: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "lib%_test.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(RM) -f $@
	$(call BRIEF,AR) cr $@ $^

LIBOBJS=$(patsubst vade/src/$(STEM)/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(patsubst vade/src/$(STEM)/%_test.c,,$(wildcard vade/src/$(STEM)/*.c))))
LIBOBJS+=$(patsubst vade/src/$(STEM)/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(patsubst vade/src/$(STEM)/%_test.cpp,,$(wildcard vade/src/$(STEM)/*.cpp))))

vade/pkg/$(STEM)/lib%_test.a: vade/pkg/$(STEM)/%_test.a
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "3LIBOBJS=$(LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

vade/pkg/$(STEM)/%_test.a: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "2LIBOBJS=$(2LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

vade/pkg/$(STEM)/lib%.a: vade/pkg/$(STEM)/%.a
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "0LIBOBJS=$(LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

vade/pkg/$(STEM)/%.bin: vade/src/$(STEM)/%.asm
#	echo "DOING %.bin for STEM=$(STEM)"
	$(NASM) -o $@ $<

DEPS=$(shell test -f vade/pkg/$(STEM)/$(STEM).d && cat vade/pkg/$(STEM)/$(STEM).d | $(VADEROOT)/bin/deps.py)
#DEPS=$(patsubst %.h,%.o,$(patsubst vade/src/%,vade/pkg/%,$(shell test -f vade/pkg/$(STEM)/$(STEM).d && cat vade/pkg/$(STEM)/$(STEM).d | grep -v "_test.o" | grep -v "test" | grep '.h' | cut -f 3 -d " ")))
#vade/pkg/$(STEM)/lib%.a: $(LIBOBJS) $(DEPS) | $(LIBOBJS)
#vade/pkg/$(STEM)/lib%.a: $(LIBOBJS) | $(LIBOBJS)
vade/pkg/$(STEM)/%.a: $(LIBOBJS) | $(LIBOBJS)
#	$(AT)echo "lib%.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "1LIBOBJS=$(LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

vade/bin/lib%_test.so: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "%.so: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(call BRIEF,CC) -o $@ $^ -shared -fPIC

LIB=vade/pkg/$(STEM)/lib$(STEM).a
TESTLIB=vade/pkg/$(STEM)/lib$(STEM)_test.a

SOLIBOBJS=$(patsubst vade/src/$(STEM)/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(wildcard vade/src/$(STEM)/export.cpp)))
SOLIB=$(patsubst vade/src/$(STEM)/%.o,vade/bin/lib$(STEM).so,$(patsubst %.cpp,%.o,$(wildcard vade/src/$(STEM)/export.cpp)))
TESTLIB+=$(SOLIB)

vade/bin/lib$(STEM).so: $(SOLIBOBJS) | $(SOLIBOBJS)
#	$(AT)echo "%.so: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(call BRIEF,CXX) -o $@ $^ -shared -fPIC

TEST_SYMS=$(shell $(NM) vade/pkg/$(STEM)/*_test.o | grep \ T\ $(STEM)_Test | cut -f 3 -d ' ')
TEST_SYMS+=$(shell $(NM) vade/pkg/$(STEM)/*_test.o | grep \ T\ _Z[0-9]*$(STEM)_Test | cut -f 3 -d ' ')
#vade/bin/%_test.exe: $(TESTLIB) $(LIB) | $(TESTLIB) $(LIB)
vade/bin/%_test.exe: $(TESTLIB) | $(TESTLIB)
#	$(AT)echo "%_test.exe: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic $(CFLAGS)
	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic

vade/bin/%.exe: $(LIB) | $(LIB)
#	echo "DOING %.exe for STEM=$(STEM)"
	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive

.PHONY:$(PKGS)

vade/pkg/vade_dep.d:
#	@echo "SRCS=$(SRCS)"
#	@echo "DIRS=$(DIRS)"
#	@echo "PKGS=$(PKGS)"
#	@echo "LIBS=$(LIBS)"
#	@echo "TESTS=$(TESTS)"
	$(AT)for d in $(DIRS); do \
		test -d vade/pkg/$$d || mkdir -p vade/pkg/$$d; \
		$(MAKE) $(SILENTMAKE) vade/pkg/$$d/$$d.d STEM=$$d V=$(V) || exit 1; \
	done

$(PKGS): vade/pkg/vade_dep.d
#	@echo "SRCS=$(SRCS)"
#	@echo "DIRS=$(DIRS)"
#	@echo "PKGS=$(PKGS)"
#	@echo "LIBS=$(LIBS)"
#	@echo "TESTS=$(TESTS)"
#	@echo "tgt=$@"
#	$(AT)echo "vade/pkg/%: how to build $@ ? stem=$* F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT0)test -d $(@) || echo "MKDIR $@" && mkdir -p $(@)
#	$(AT)test -d $(@) || mkdir -p $(@)
#	$(AT)$(MAKE) $(SILENTMAKE) vade/pkg/$(@F)/$(@F).d STEM=$(@F) V=$(V)
#	$(MAKE) $(SILENTMAKE) vade/pkg/$(@F).d STEM=$(@F) V=$(V)
	$(AT)$(VADEMAKEINTERNAL) $(SILENTMAKE) vade/pkg/$(@F)/lib$(@F).a STEM=$(@F) V=$(V)
	$(AT)test -f vade/pkg/$(@F)/lib$(@F).a && $(NM) vade/pkg/$(@F)/lib$(@F).a | grep T\ main > /dev/null && $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(@F).exe STEM=$(@F) V=$(V) || true
	$(AT)test -z "$(wildcard vade/src/$(@F)/*_test.*)" || $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(@F)_test.exe STEM=$(@F) V=$(V)

.PHONY:$(RUN_TESTS)

$(RUN_TESTS):
	$(call BRIEF2,RUN,./$(@D)) $(RUNTEST) ./$(@D) $(TFLAGS) || exit $$?
#	$(call BRIEF2,RUN,./$(@F)) ./$(@F)

_check: $(RUN_TESTS)

check: all
	$(AT)$(MAKE) $(SILENTMAKE) _check

clean:
	$(call BRIEF2,RM,vade/pkg) -Rf vade/pkg

clobber: clean
	$(call BRIEF2,RM,vade/bin) -Rf vade/bin
