INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = armv7 arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotlightPls
SpotlightPls_FILES = Tweak.xm

SUBPROJECTS += prefs

include $(THEOS_MAKE_PATH)/tweak.mk

include $(THEOS_MAKE_PATH)/aggregate.mk