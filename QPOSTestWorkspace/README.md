## Framework Creation Guide

To create the framework, the following steps were taken:

### Model Framework Creation
- A model framework was created using Xcode.
- The necessary files were added to the framework.

### Build Settings Configuration
- In the **Build Settings** section:
  - **Import Paths**: `$(PROJECT_DIR)/QPOSTestFramework/QPOSFiles` was added.
  - **Header Search Paths**: `$(PROJECT_DIR)/QPOSTestFramework/QPOSFiles` was added.
  - **Other Linker Flags**: `-lqpos-ios-release-sdk-v3.6.7` was added.

### Build Phases Configuration
- In the **Build Phases** section:
  - All headers were set to **Public**.

### Application Modifications
- Changes were made to the `ViewController` file.
- The key **Privacy - Bluetooth Always Usage Description** was added to `Info.plist`.

