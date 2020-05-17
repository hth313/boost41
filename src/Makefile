OS4 = ../../OS4/src
LIB4 = ../../lib41/include
RPN_SRCS =
SRCS = boost.s ramed.s compile.s poll.s cat.s xmemory.s xeq.s \
        assign.s readrom16.s writerom16.s random.s partialKeys.s \
        compare.s delay.s

OBJS = $(SRCS:%.s=%.o) $(RPN_SRCS:%.rpn=%.o)
MOD = boost.mod boost.mod2

all: $(MOD)

%.o: %.rpn
	rpncomp -l --no-fat --prefix-labels LBL_ $<

%.o: %.s
	asnut --cpu=newt  -I$(LIB4) -I$(OS4) -g -l $<

$(MOD): $(OBJS) linker.scm boost.moddesc ../../lib41/src/lib41.a
	lnnut -g $(OBJS) --list-file=linker.lst --extra-output-formats=mod2 linker.scm boost.moddesc  ../../lib41/src/lib41.a

clean:
	rm $(OBJS) $(MOD)
