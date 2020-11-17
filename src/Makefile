OS4 = ../../OS4/src
RPN_SRCS =
SRCS = boost.s ramed.s compile.s poll.s cat.s xmemory.s xeq.s \
        assign.s readrom16.s writerom16.s random.s partialKeys.s \
        compare.s delay.s returnStack.s luhn.s apx.s fixeng.s vmant.s \
	yntest.s alpha.s binbcds.s arithmetic.s code.s decode.s stack.s \
	bufferUtils.s

OBJS = $(SRCS:%.s=%.o) $(RPN_SRCS:%.rpn=%.o)
MOD = boost.mod boost.mod2

all: $(MOD)

%.o: %.rpn
	rpncomp -l --no-fat --prefix-labels LBL_ $<

%.o: %.s
	asnut --cpu=newt  -I$(OS4) -g -l $<

$(MOD): $(OBJS) linker.scm boost.moddesc
	lnnut -g $(OBJS) --list-file=linker.lst --extra-output-formats=mod2 linker.scm boost.moddesc
	modtool --extract-module-export boost.mod

clean:
	rm $(OBJS) $(MOD)
