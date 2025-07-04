#!/bin/bash

# Apply patch to libmicroros.mk to add esp32 support to atomic workaround

PATCH_FILE="libmicroros.patch"
TARGET_FILE="components/micro_ros_espidf_component/libmicroros.mk"

# Create patch file
cat > "$PATCH_FILE" << 'EOF'
--- components/micro_ros_espidf_component/libmicroros.mk.orig
+++ components/micro_ros_espidf_component/libmicroros.mk
@@ -107,7 +107,7 @@
 
 patch_atomic:$(EXTENSIONS_DIR)/micro_ros_src/install
 # Workaround https://github.com/micro-ROS/micro_ros_espidf_component/issues/18
-ifeq ($(IDF_TARGET),$(filter $(IDF_TARGET),esp32s2 esp32c3 esp32c6))
+ifeq ($(IDF_TARGET),$(filter $(IDF_TARGET),esp32 esp32s2 esp32c3 esp32c6))
 		echo $(UROS_DIR)/atomic_workaround; \
 		mkdir $(UROS_DIR)/atomic_workaround; cd $(UROS_DIR)/atomic_workaround; \
 		$(X_AR) x $(UROS_DIR)/install/lib/librcutils.a; \
EOF

# Apply the patch
if [ -f "$TARGET_FILE" ]; then
    echo "Applying patch to $TARGET_FILE..."
    patch -p0 < "$PATCH_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Patch applied successfully!"
    else
        echo "Failed to apply patch!"
        exit 1
    fi
else
    echo "Target file $TARGET_FILE not found!"
    exit 1
fi

# Clean up patch file
rm -f "$PATCH_FILE"