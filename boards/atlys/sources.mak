BOARD_SRC=$(wildcard $(BOARD_DIR)/top.v)

JHASH_SRC=$(wildcard $(CORES_DIR)/jhash/rtl/*.v)

CORES_SRC=$(JHASH_SRC)
