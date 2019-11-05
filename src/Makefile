OS4 = ../../OS4/src
LIB4 = ../../lib41/include
RPN_SRCS =
SRCS = boost.s ramed.s compile.s mainframe.s poll.s tvm.s cat.s xmemory.s

OBJS = $(SRCS:%.s=%.o) $(RPN_SRCS:%.rpn=%.o)
MOD = boost.mod

all: $(MOD)

%.o: %.rpn
	rpncomp -l --no-fat --prefix-labels LBL_ $<

%.o: %.s
	asnut -I$(LIB4) -I$(OS4) -g -l $<

$(MOD): $(OBJS) linker.scm boost.moddesc ../../lib41/src/lib41.a
	lnnut -g $(OBJS) --list-file=linker.lst linker.scm boost.moddesc  ../../lib41/src/lib41.a

clean:
	rm $(OBJS) $(MOD)
