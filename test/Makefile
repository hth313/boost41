
RPNS = top.rpn stack.rpn

SRCS = boostTest.s
OBJS = $(RPNS:%.rpn=%.o) $(SRCS:%.s=%.o)
MOD = boostTest.mod

all: $(MOD)

%.o: %.s
	asnut -l -g $<

%.o: %.rpn
	rpncomp -I../src -l $<

$(MOD): $(OBJS) Plugin4K.scm boostTest.moddesc
	lnnut --list-file=linker.lst -g $(OBJS) Plugin4K.scm boostTest.moddesc

clean:
	rm $(OBJS) $(MOD)
