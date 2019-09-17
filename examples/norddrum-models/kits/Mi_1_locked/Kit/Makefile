COMPILE_CMD = faust2jack
FLAGS = -midi

SRC_DIR =./src
BIN_DIR =./bin
SNAP_DIR =./jack-snapshots

SRC = $(wildcard $(SRC_DIR)/*.dsp)
EXECUTABLES = $(addprefix $(BIN_DIR)/, $(notdir $(basename $(wildcard $(SRC)))))

all : $(EXECUTABLES)

$(BIN_DIR)/% : $(SRC_DIR)/%.dsp
	cd $(SRC_DIR) && $(COMPILE_CMD) $(FLAGS) '$(<F)' && \
	cd .. && mv $(SRC_DIR)/'$(@F)' $(BIN_DIR)/

start :
	for file in $(EXECUTABLES);do (./$$file &); done

connect:
	aj-snapshot -r $(SNAP_DIR)/snap_1

clean:
	rm -rf $(EXECUTABLES)
