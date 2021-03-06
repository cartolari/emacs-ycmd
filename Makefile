EMACS = emacs
EMACSFLAGS =
CASK = cask
ERTSELECTOR = t
YCMDPATH=../ycmd/ycmd
CONVERT = convert
VERSION := $(shell EMACS=$(EMACS) $(CASK) version)
PKGDIR := $(shell EMACS=$(EMACS) $(CASK) package-directory)

# Export the used EMACS to recipe environments
export EMACS

SRCS = ycmd.el \
	third-party/ycmd-request.el \
	third-party/ycmd-request-deferred.el \
	contrib/ycmd-next-error.el

OBJECTS = $(SRCS:.el=.elc)

SRCS_COMP = company-ycmd.el
OBJECTS_COMP = $(SRCS_COMP:.el=.elc)

SRCS_FLYC = flycheck-ycmd.el
OBJECTS_FLYC = $(SRCS_FLYC:.el=.elc)

SRCS_ELDOC = ycmd-eldoc.el
OBJECTS_ELDOC = $(SRCS_ELDOC:.el=.elc)

DISTDIR = dist
BUILDDIR = build

EMACSBATCH = $(EMACS) -Q --batch $(EMACSFLAGS)

.PHONY: deps all ycmd company-ycmd flycheck-ycmd ycmd-eldoc dist \
	test clean clean-elc clobber clobber-dist clobber-deps

# Build targets
all : $(OBJECTS) $(OBJECTS_COMP) $(OBJECTS_FLYC) $(OBJECTS_ELDOC)

ycmd : $(OBJECTS)

company-ycmd : ycmd $(OBJECTS_COMP)

flycheck-ycmd : ycmd $(OBJECTS_FLYC)

ycmd-eldoc : ycmd $(OBJECTS_ELDOC)

dist :
	$(CASK) package

# Test targets
test : $(OBJECTS) $(OBJECTS_COMP) $(OBJECTS_FLYC) $(OBJECTS_ELDOC)
	$(EMACSBATCH) --script test/run.el '$(YCMDPATH)' '$(ERTSELECTOR)'

# Support targets
deps : $(PKGDIR)

# Cleanup targets
clean : clean-elc
clobber: clobber-dist clobber-deps

clean-elc :
	rm -rf $(OBJECTS) $(OBJECTS_COMP) $(OBJECTS_FLYC) $(OBJECTS_ELDOC)

clobber-dist :
	rm -rf $(DISTDIR)

clobber-deps :
	rm -rf .cask/

$(PKGDIR) : Cask
	$(CASK) install
	touch $(PKGDIR)

%.elc : %.el $(PKGDIR)
	$(CASK) exec $(EMACSBATCH) \
		--eval "(add-to-list 'load-path \"${PWD}/third-party\")" \
		-L . -f batch-byte-compile $<
