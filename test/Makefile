PRIV_DIR := $(MIX_APP_PATH)/priv
NIF_PATH := $(PRIV_DIR)/libfinest.so
C_SRC := $(shell pwd)/c_src

CPPFLAGS := -shared -fPIC -fvisibility=hidden -std=c++17 -Wall -Wextra
CPPFLAGS += -I$(ERTS_INCLUDE_DIR) -I$(FINE_INCLUDE_DIR)
CPPFLAGS += -DFINE_ENABLE_TEST_HOOKS
# We want to eliminate all warnings, so the end user doesn't see any.
CPPFLAGS += -Werror
CPPFLAGS += $(EXTRA_CPPFLAGS)
LDFLAGS += $(EXTRA_LDFLAGS)

ifdef DEBUG
	CPPFLAGS += -g
else
	CPPFLAGS += -O3
endif

ifndef TARGET_ABI
  TARGET_ABI := $(shell uname -s | tr '[:upper:]' '[:lower:]')
endif

ifeq ($(TARGET_ABI),darwin)
	CPPFLAGS += -undefined dynamic_lookup -flat_namespace
endif

ifeq ($(TARGET_ABI),linux)
	CPPFLAGS += -fstack-protector-strong -D_FORTIFY_SOURCE=2
	LDFLAGS += -Wl,-z,relro -Wl,-z,now
endif

SOURCES := $(wildcard $(C_SRC)/*.cpp)
# We add dependency on Fine header file, since it can change as we test.
FINE_HEADERS := $(wildcard $(FINE_INCLUDE_DIR)/*.hpp)

all: $(NIF_PATH)
	@ echo > /dev/null # Dummy command to avoid the default output "Nothing to be done"

$(NIF_PATH): $(SOURCES) $(FINE_HEADERS)
	@ mkdir -p $(PRIV_DIR)
	$(CXX) $(CPPFLAGS) $(SOURCES) -o $(NIF_PATH) $(LDFLAGS)
