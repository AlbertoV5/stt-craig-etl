PROJECT_NAME = etl
# Run the publishing functions from given .el file on given file path.
# Make sure to open emacs server/GUI in project directory.
EMACS = emacsclient --suppress-output --eval
# Directories:
CONFIG = config
DOCS = .
PUBLIC = docs
RESOURCES = resources
SOURCE = src
BUILD = $(PUBLIC)/build
STATIC = $(PUBLIC)/resources
# Specific directories for commands to run after publishing.
INDEX = $(PUBLIC)/index.html
README = README.md
# Project name based
INDEX_TARGET = build/$(PROJECT_NAME).html
README_DOC = $(DOCS)/$(PROJECT_NAME).md
# Get the root of the current Emacs server (ideally the project root).
SERVER_DIR = (with-current-buffer (current-buffer) default-directory)
TIME = $(shell date +%Y-%m-%d-%H:%M:%S)
DONE = @echo "\033[1m-> DONE\x1b[0m"

#----------------
# MAIN COMMANDS
#----------------
all: title publish $(INDEX) $(README)

clean: title clean-exports publish-force $(INDEX) $(README)

update:
	@git submodule foreach git pull origin main
	$(DONE)

title:
	@echo "\033[1m-------------------------\n Processing: $(PROJECT_NAME)\n-------------------------\x1b[0m"

.PHONY: all clean update commit
#---------------------------
#	EMACS-HANDLED TARGETS
#---------------------------
publish: $(SOURCE)
	$(info    Publishing $<...)
	@$(EMACS) '(load-file (concat $(SERVER_DIR) "$(CONFIG)/$@.el"))'
	$(DONE)

publish-force: $(SOURCE)
	$(info    Publishing (Forced) $<...)
	@$(EMACS) '(load-file (concat $(SERVER_DIR) "$(CONFIG)/$@.el"))'
	$(DONE)
#------------------
#	OTHER TARGETS
#------------------
$(README): $(README_DOC)
	$(info    Building $@ from $<...)
	@cp $< $@
	$(DONE)

$(INDEX): $(CONFIG)/index.py $(PUBLIC)/$(INDEX_TARGET)
	$(info    Building Index (redirecting to $(INDEX_TARGET))...)
	@python $< $(INDEX_TARGET) $@
	$(DONE)

clean-others: $(INDEX) $(README)
	rm $^
#-------------------
#	OTHER COMMANDS
#-------------------
commit: all
	@git add .
	@git status
	@git commit -m 'Auto-commit published: $(TIME)'
	@echo "\033[1mAuto-commit published: $(TIME)\x1b[0m"

clean-exports: $(STATIC) $(BUILD)
	$(info    Cleaning $^...)
	@touch $(STATIC) && rm -r $(STATIC) && mkdir $(STATIC)
	@touch $(BUILD) && rm -r $(BUILD) && mkdir $(BUILD)
	$(DONE)
