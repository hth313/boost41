
RPNS = top.rpn stack.rpn

SRCS = boostTest.s
OBJS = $(RPNS:%.rpn=%.o) $(SRCS:%.s=%.o)
MOD = lb-test.mod

all: $(MOD)

%.o: %.s
	asnut -l -g $<

%.o: %.rpn
	rpncomp -I../src -l $<

$(MOD): $(OBJS) Plugin4K.scm boost.moddesc
	lnnut --list-file=linker.lst -g $(OBJS) Plugin4K.scm boost.moddesc

clean:
	rm $(OBJS) $(MOD)
