# Copyright (c) 2016 - present Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

TESTS_DIR = ../..
ROOT_DIR = $(TESTS_DIR)/../..

ANALYZER = infer

BUCK_TARGET = //infer/tests/build_systems/genrule/module2:module2
SOURCES = $(addprefix $(ROOT_DIR), $(shell buck audit input $(BUCK_TARGET)))
TARGET_OUTPUT = $(word 2, $(shell buck targets --show-output $(BUCK_TARGET)))
OBJECTS = $(ROOT_DIR)/$(TARGET_OUTPUT)

INFER_TARGET = $(BUCK_TARGET)_infer
GENRULE_OUTPUT = $(word 2, $(shell GENERATE_INFER_GENRULES=1 buck targets --show-output $(INFER_TARGET)))
JSON_REPORT = $(ROOT_DIR)/$(GENRULE_OUTPUT)/report.json

INFER_OPTIONS = --project-root $(ROOT_DIR)
INFERPRINT_OPTIONS = --project-root $(ROOT_DIR) --issues-tests
CLEAN_EXTRA = $(ROOT_DIR)/buck-out/genruletest

include $(TESTS_DIR)/java.make
include $(TESTS_DIR)/base.make

$(OBJECTS): $(JAVA_SOURCE_FILES)
	cd $(ROOT_DIR) && \
	$(call silent_on_success,\
	NO_BUCKD=1 buck build --no-cache $(BUCK_TARGET))

.PHONY: genrule
genrule: $(JSON_REPORT)


$(JSON_REPORT): $(JAVA_DEPS) $(JAVA_SOURCE_FILES)
	cd $(ROOT_DIR) && \
    $(REMOVE_DIR) buck-out && \
	$(call silent_on_success,\
	INFER_BIN="$(INFER_BIN)" NO_BUCKD=1 GENERATE_INFER_GENRULES=1 \
	buck build --no-cache $(INFER_TARGET))
	touch $@

infer-out/report.json: $(JSON_REPORT)
	$(MKDIR_P) infer-out
#	the report contains absolute paths
	@sed -e 's#$(abspath $(TESTS_DIR))/##g' $< > $@