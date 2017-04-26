BUILD = build
BOOKNAME = my-book
TITLE = title.txt
METADATA = metadata.xml
CHAPTERS = ch01.md ch02.md ch03.md
TOC = --toc --toc-depth=2
COVER_IMAGE = images/cover.jpg
LATEX_CLASS = report

#
USER_ID = $(shell id -u ${USER})
GROUP_ID = $(shell id -g ${USER})
#
DOCKER_CMD = docker run \
		-it --rm \
		-v `pwd`:/source \
		-v /etc/group:/etc/group:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-u $(USER_ID):$(GROUP_ID) \
		${DOCKER_ID_USER}/pandoc \
		bash -c

all: book

book: epub html pdf

clean:
	rm -r $(BUILD)

epub: $(BUILD)/epub/$(BOOKNAME).epub

html: $(BUILD)/html/$(BOOKNAME).html

pdf: $(BUILD)/pdf/$(BOOKNAME).pdf

$(BUILD)/epub/$(BOOKNAME).epub: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/epub
	$(DOCKER_CMD) " \
		pandoc $(TOC) -S --epub-metadata=$(METADATA) --epub-cover-image=$(COVER_IMAGE) -o $@ $^"

$(BUILD)/html/$(BOOKNAME).html: $(CHAPTERS)
	mkdir -p $(BUILD)/html
	$(DOCKER_CMD) " \
		pandoc $(TOC) --standalone --to=html5 -o $@ $^"

$(BUILD)/pdf/$(BOOKNAME).pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/pdf
	$(DOCKER_CMD) " \
		pandoc \
			$(TOC) \
			--template common/pdf-template.tex \
			--latex-engine=xelatex \
			-V documentclass=$(LATEX_CLASS) \
			-o $@ $^"

.PHONY: all book clean epub html pdf
