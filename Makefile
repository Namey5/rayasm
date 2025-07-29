BUILD_DIR=build
ASFLAGS=
LDFLAGS=
ARGS=

.PHONY: all clean run

all: $(BUILD_DIR)/rayasm

clean:
	rm -rf $(BUILD_DIR)

run: $(BUILD_DIR)/rayasm
	./$(BUILD_DIR)/rayasm $(ARGS)

$(BUILD_DIR)/main.o: main.s
	mkdir -p $(BUILD_DIR)
	as $(ASFLAGS) -o $(BUILD_DIR)/main.o main.s

$(BUILD_DIR)/rayasm: $(BUILD_DIR)/main.o
	gcc $(LDFLAGS) -o $(BUILD_DIR)/rayasm $(BUILD_DIR)/main.o
