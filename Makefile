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
VADEMAKEINTERNAL:=make -f $(VADEROOT)/internal.mk SILENTMAKE=$(SILENTMAKE) VADEROOT=$(VADEROOT)

# CC0 is gcc, required to build *.so -- TODO fix thin *.a archives for TCC
CC0:=gcc
AR:=ar
NM:=nm
NASM:=nasm
TCC:=tcc
CLANG:=clang
VALGRIND:=valgrind
GCOV:=gcov
VGOPTS:=--exit-on-first-error=yes --error-exitcode=128
VGOPTS$(L)+=-q
VGOPTS+=--leak-check=full

SRCS=$(shell find vade/src -regextype sed -regex ".*\.\(c\|h\)" -exec dirname "{}" \; | uniq)
DIRS=$(patsubst vade/src/%,%,$(SRCS))
VADEPATH:=$(shell realpath .)
RPWD:=$(shell realpath --relative-to=$(VADEPATH) $(PWD))
ifneq ($(findstring vade/src/,$(RPWD)),)
P0:=$(patsubst vade/src/%,%,$(RPWD))
ifneq ($(findstring $(P0),$(DIRS)),)
P:=$(patsubst vade/src/%,%,$(RPWD))
VALGRIND:=
GCOV:=
endif
endif

# Do not autoselect tcc by default
# as it breaks stdarg at link time with gcc (missing __va_arg)
#ifneq (, $(shell which $(TCC) 2>/dev/null))
#CC:=$(TCC)
#endif

ifneq ($(CC),$(CC0))
GCOV:=
endif
# Seems like clang doesn't generate valid dwarf2 for valgrind ?
ifeq ($(CC),$(CLANG))
VALGRIND:=
endif

ifeq (, $(shell which $(VALGRIND) 2>/dev/null))
#$(error "NOT HAVE VALGRIND ($(VALGRIND))")
RUN:=
RUNTEST:=RUN
else
#$(error "HAVE VALGRIND ($(VALGRIND))")
VGRUN:=$(VALGRIND) $(VGOPTS)
RUNTEST:=VGRUN
endif
RUNPYTEST:=RUNPY

ifeq (, $(shell which $(GCOV) 2>/dev/null))
#$(error "NOT HAVE GCOV ($(GCOV))")
HAVE_GCOV:=
else
#$(error "HAVE GCOV ($(GCOV))")
HAVE_GCOV:=1
endif

PSRCS=$(shell find vade/src/$(P) -regextype sed -regex ".*\.\(c\|h\)" -exec dirname "{}" \; 2>/dev/null | uniq)
PKGS=$(patsubst vade/src/%,%,$(PSRCS))

VADE_PKGS=$(patsubst %,vade/pkg/%,$(PKGS))

RUN_TESTS:=$(foreach p,$(PKGS),$(patsubst %,%/RUN,$(wildcard vade/bin/$(p)/$(shell basename $(p))_test.exe)))
RUN_PYTESTS:=$(foreach p,$(PKGS),$(patsubst %,%/RUNPY,$(wildcard vade/src/$(p)/*_test.py)))

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

#CSTD?=c11
CSTD?=gnu11

ifdef CSTD
CFLAGS+=-std=$(CSTD)
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

ifdef HAVE_GCOV
COVFLAGS:=-fprofile-arcs -ftest-coverage
COVLIBS:=-lgcov --coverage
CFLAGS+=$(COVFLAGS)
CXXFLAGS+=$(COVFLAGS)
endif

.PHONY:all test clean clobber

all: vade/pkg vade/bin $(VADE_PKGS)

build: all

vade/pkg vade/bin:
	$(AT)mkdir -p $@

DEPSCFILES=$(patsubst vade/src/$(STEM)/%.c,$(STEM)/%,$(wildcard vade/src/$(STEM)/*.c))
DEPSCPPFILES=$(patsubst vade/src/$(STEM)/%.cpp,$(STEM)/%,$(wildcard vade/src/$(STEM)/*.cpp))
DEPSASMFILES=$(patsubst vade/src/$(STEM)/%.asm,$(STEM)/%,$(wildcard vade/src/$(STEM)/*.asm))

vade/pkg/$(STEM)/%.d:
#	$(AT)echo "STEM=$(STEM) @=$@ @F=$(@F) @D=$(@D)"
#	$(AT)echo "DEPSCFILES=$(DEPSCFILES)"
#	$(AT)echo "DEPSCPPFILES=$(DEPSCPPFILES)"
#	$(AT)echo "DEPSASMFILES=$(DEPSASMFILES)"
	$(AT)echo -n > $@
	$(AT)for f in $(DEPSCFILES); do \
		$(CC) -MM vade/src/$$f.c $(CFLAGS) -DTEST_SYMS='""' | tee $(@).deps | $(VADEROOT)/bin/deps.py `dirname $$f` >> $@ || exit 1; \
	done
	$(AT)for f in $(DEPSCPPFILES); do \
		$(CXX) -MM vade/src/$$f.cpp $(CXXFLAGS) -DTEST_SYMS='""' | tee $(@).deps | $(VADEROOT)/bin/deps.py `dirname $$f` >> $@ || exit 1; \
	done
	$(AT)for f in $(DEPSASMFILES); do \
		echo "vade/pkg/$$f.bin: vade/src/$$f.asm" >> $@ || exit 1; \
		echo "vade/pkg/$(STEM)/lib$(STEM).a: | vade/pkg/$$f.bin" >> $@ || exit 1 ; \
	done
	$(AT)cat $@ >> vade/pkg/vade_dep.d

vade/pkg/$(STEM)/%.o: vade/src/$(STEM)/%.c
	$(AT)$(RM) $(patsubst %.o,%.gcda,$@) 2> /dev/null || true
	$(call BRIEF,CC) -c -o $@ $< $(CFLAGS)

vade/pkg/$(STEM)/%.o: vade/src/$(STEM)/%.cpp
	$(AT)$(RM) $(patsubst %.o,%.gcda,$@) 2> /dev/null || true
	$(call BRIEF,CXX) -c -o $@ $< $(CXXFLAGS)

TEST_SYMS=$(shell $(NM) vade/pkg/$(STEM)/*.o | grep \ T\ $(subst /,_,$(STEM))_Test_ | cut -f 3 -d ' ')
TEST_SYMS+=$(shell $(NM) vade/pkg/$(STEM)/*.o | grep \ T\ _Z[0-9]*$(subst /,_,$(STEM))_Test_ | cut -f 3 -d ' ')

vade/pkg/$(STEM)/%.o: $(VADEROOT)/vade/src/test/%.c $(wildcard vade/src/$(STEM)/*)
#	$(AT)echo "STEM=$(STEM) TEST_SYMS=$(TEST_SYMS) subst=$(patsubst /,_,$(STEM))"
	$(AT)$(RM) $(patsubst %.o,%.gcda,$@) 2> /dev/null || true
	$(call BRIEF,CC) -c -o $@ $< $(CFLAGS) -DTEST_SYMS="\"$(TEST_SYMS)\"" $(VADE_CFLAGS)

vade/pkg/$(STEM)/%.o: $(VADEROOT)/vade/src/test/%.cpp $(wildcard vade/src/$(STEM)/*)
#	$(AT)echo "STEM=$(STEM) TEST_SYMS=$(TEST_SYMS)"
	$(AT)$(RM) $(patsubst %.o,%.gcda,$@) 2> /dev/null || true
	$(call BRIEF,CXX) -c -o $@ $< $(CXXFLAGS) -DTEST_SYMS="\"$(TEST_SYMS)\"" $(VADE_CXXFLAGS)

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
#	@echo "AUTO LIB lib%.a %.a tgt=$@ deps=$^"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

lib%.a: %.o
#	@echo "AUTO LIB lib%.a %.o tgt=$@ deps=$^"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

%_test.a: %_test.o
#	@echo "AUTO LIB %_test.a %_test.o tgt=$@ deps=$^"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

PROJ=$(patsubst %.a,%,$(@F))
ALIBOBJS=$(patsubst vade/src/$(PROJ)/%.o,vade/pkg/$(PROJ)/%.o,$(patsubst %.c,%.o,$(patsubst vade/src/$(PROJ)/%_test.c,,$(wildcard vade/src/$(PROJ)/*.c))))
ALIBOBJS+=$(patsubst vade/src/$(PROJ)/%.o,vade/pkg/$(PROJ)/%.o,$(patsubst %.cpp,%.o,$(patsubst vade/src/$(PROJ)/%_test.cpp,,$(wildcard vade/src/$(PROJ)/*.cpp))))
%.a: %.o
#	@echo "AUTO LIB %.a %.o tgt=$@ deps=$^ PROJ=$(PROJ)"
	$(VADEMAKEINTERNAL) $(SILENTMAKE) vade/pkg/$(PROJ)/$(PROJ).o STEM=$(PROJ) V=$(V)
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^
#	$(VADEMAKEINTERNAL) $(SILENTMAKE) vade/pkg/$(PROJ)/$(PROJ).a STEM=$(PROJ) V=$(V)

LIBOBJS=$(patsubst vade/src/$(STEM)/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.c,%.o,$(patsubst vade/src/$(STEM)/%_test.c,,$(wildcard vade/src/$(STEM)/*.c))))
LIBOBJS+=$(patsubst vade/src/$(STEM)/%.o,vade/pkg/$(STEM)/%.o,$(patsubst %.cpp,%.o,$(patsubst vade/src/$(STEM)/%_test.cpp,,$(wildcard vade/src/$(STEM)/*.cpp))))

vade/pkg/$(STEM)/lib%_test.a: vade/pkg/$(STEM)/%_test.a
#	$(AT)echo "ZARG lib%_test.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
#	$(AT)echo "3LIBOBJS=$(LIBOBJS)"
#	$(AT)echo "_DEPS=$(_DEPS)"
#	$(AT)echo "DEPS=$(DEPS)"
	$(RM) -f $@
	$(call BRIEF,AR) crsT $@ $^

vade/pkg/$(STEM)/%_test.a: $(TESTOBJS) | $(TESTOBJS)
#	$(AT)echo "ZORG %_test.a: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
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

LIB=vade/pkg/$(STEM)/lib$(shell basename $(STEM) 2> /dev/null).a
TESTLIB=vade/pkg/$(STEM)/lib$(shell basename $(STEM) 2> /dev/null)_test.a

vade/bin/$(STEM)/lib$(STEM).so: vade/pkg/$(STEM)/lib$(STEM).a | vade/pkg/$(STEM)/lib$(STEM).a
#	$(AT)echo "%.so: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(AT)mkdir -p $(@D)
	$(call BRIEF,CC0) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -shared -fPIC $(COVLIBS)

#vade/bin/%_test.exe: $(TESTLIB) $(LIB) | $(TESTLIB) $(LIB)
vade/bin/%_test.exe: $(TESTLIB) | $(TESTLIB)
#	$(AT)echo "%_test.exe: how to build $@ ? stem=$* STEM=$(STEM) F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^"
	$(AT)mkdir -p $(@D)
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic $(CFLAGS)
	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic $(COVLIBS)
#	$(call BRIEF,CC) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic

vade/bin/%_test.exe: $(LIB) | $(LIB)
#	@echo "DOING %.exe for STEM=$(STEM)"
	$(AT)mkdir -p $(@D)
	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive -ldl -rdynamic $(COVLIBS)

vade/bin/%.exe: $(LIB) | $(LIB)
#	@echo "DOING %.exe for STEM=$(STEM)"
	$(AT)mkdir -p $(@D)
	$(call BRIEF,CXX) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive $(COVLIBS)

.PHONY:$(VADE_PKGS)

vade/pkg/vade_dep.d:
#	@echo "SRCS=$(SRCS)"
#	@echo "DIRS=$(DIRS)"
#	@echo "VADE_PKGS=$(VADE_PKGS)"
	$(AT)for d in $(DIRS); do \
#		echo "d=$$d"; \
		test -d vade/pkg/$$d || mkdir -p vade/pkg/$$d; \
		$(MAKE) $(SILENTMAKE) vade/pkg/$$d/`basename $$d`.d STEM=$$d V=$(V) || exit 1; \
	done

$(VADE_PKGS): vade/pkg/vade_dep.d
#	@echo "SRCS=$(SRCS)"
#	@echo "DIRS=$(DIRS)"
#	@echo "VADE_PKGS=$(VADE_PKGS)"
#	@echo "tgt=$@"
#	$(AT)(PKG=$(patsubst vade/pkg/%,%,$@) ; echo "vade/pkg/%: how to build $@ ? stem=$* PKG=$$PKG F=$(@F) f=$(patsubst lib%.a,%,$(@F)) D=$(@D) prereq=$^")
#	$(AT0)test -d $(@) || echo "MKDIR $@" && mkdir -p $(@)
#	$(AT)test -d $(@) || mkdir -p $(@)
#	$(AT)$(MAKE) $(SILENTMAKE) vade/pkg/$(@F)/$(@F).d STEM=$(@F) V=$(V)
#	$(MAKE) $(SILENTMAKE) vade/pkg/$(@F).d STEM=$(@F) V=$(V)
#	$(AT)echo "here1"
	$(AT)$(VADEMAKEINTERNAL) $(SILENTMAKE) $@/lib$(@F).a STEM=$(patsubst vade/pkg/%,%,$@) V=$(V)
#	$(AT)echo "here2"
	$(AT)test -f $@/lib$(@F).a && $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(patsubst vade/pkg/%,%,$@)/lib$(@F).so STEM=$(patsubst vade/pkg/%,%,$@) V=$(V) || true
	$(AT)test -f $@/lib$(@F).a && $(NM) $@/lib$(@F).a | grep T\ main > /dev/null && $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(patsubst vade/pkg/%,%,$@)/$(@F).exe STEM=$(patsubst vade/pkg/%,%,$@) V=$(V) || true
#	$(AT)echo "here3 doing vade/bin/$(patsubst vade/pkg/%,%,$@)/$(@F)_test.exe STEM=$(patsubst vade/pkg/%,%,$@)"
#	$(AT)test -z "$(wildcard vade/src/$(patsubst vade/pkg/%,%,$@)/*_test.\(c\|cpp\))" || $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(patsubst vade/pkg/%,%,$@)/$(@F)_test.exe STEM=$(patsubst vade/pkg/%,%,$@) V=$(V)
	$(AT)test -z "$(shell find vade/src/$(patsubst vade/pkg/%,%,$@) -regextype posix-extended -regex '.*_test.(c|cpp)')" || $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(patsubst vade/pkg/%,%,$@)/$(@F)_test.exe STEM=$(patsubst vade/pkg/%,%,$@) V=$(V)
#	$(AT)test -z `$(NM) $@/*.o | grep _Test_ > /dev/null` || $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(patsubst vade/pkg/%,%,$@)/$(@F).exe STEM=$(patsubst vade/pkg/%,%,$@) V=$(V) || true
	$(AT)test -f $@/lib$(@F).a && $(NM) $@/lib$(@F).a | grep _Test_ > /dev/null && $(VADEMAKEINTERNAL) $(SILENTMAKE) vade/bin/$(patsubst vade/pkg/%,%,$@)/$(@F)_test.exe STEM=$(patsubst vade/pkg/%,%,$@) V=$(V) || true
#	$(AT)echo "here4"

.PHONY:$(RUN_TESTS) $(RUN_PYTESTS)

$(RUN_TESTS):
#	@echo "RUN_TESTS=$(RUN_TESTS) @D=$(@D) @F=$(@F)"
	$(call BRIEF2,$(RUNTEST),./$(@D)) ./$(@D) $(TFLAGS) || exit $$?
#	$(call BRIEF2,RUNTEST,./$(@F)) ./$(@F)

$(RUN_PYTESTS):
#	@echo "RUN_PYTESTS=$(RUN_PYTESTS) @D=$(@D) @F=$(@F)"
	$(call BRIEF2,$(RUNPYTEST),./$(@D)) PYTHONPATH=vade/src/test ./$(@D) $(TFLAGS) || exit $$?
#	$(call BRIEF2,RUNPYTEST,./$(@F)) ./$(@F)

_test: $(RUN_TESTS) $(RUN_PYTESTS)

test: all
#	@echo "test RUN_TESTS=$(RUN_TESTS)"
	$(AT)$(MAKE) $(SILENTMAKE) _test
ifdef HAVE_GCOV
	$(AT)echo "=================================="
	$(AT)echo "Code coverage ($(words $(RUN_TESTS)) tests)"
	$(AT)echo "=================================="
	$(AT)for d in $(PKGS); do \
		for c in `ls vade/pkg/$$d/*.gcda 2> /dev/null | grep -v -e "_test.gcda" -e "/test.gcda"`; do \
			echo -n "$$c: "; \
			$(GCOV) -n $$c |grep "Lines executed:"|head -n 1|cut -f 2 -d":"; \
		done; \
	done
endif

clean:
	$(call BRIEF2,RM,vade/pkg) -Rf vade/pkg

clobber: clean
	$(call BRIEF2,RM,vade/bin) -Rf vade/bin
