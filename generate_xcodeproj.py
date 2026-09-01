#!/usr/bin/env python3
"""Generate QuietFactory.xcodeproj for CI (no Xcode required on Linux)."""

import hashlib
import os
import textwrap

ROOT = os.path.dirname(os.path.abspath(__file__))
PROJECT_NAME = "QuietFactory"
BUNDLE_ID = "com.quietfactory.app"
TEST_BUNDLE_ID = "com.quietfactory.app.tests"
IOS_DEPLOYMENT = "17.0"

def uid(seed: str) -> str:
    return hashlib.md5(seed.encode()).hexdigest()[:24].upper()


# Collect Swift sources
app_sources = []
for folder in ["App", "GameCore", "GameScene", "Audio"]:
    base = os.path.join(ROOT, PROJECT_NAME, folder)
    if os.path.isdir(base):
        for name in sorted(os.listdir(base)):
            if name.endswith(".swift"):
                app_sources.append(f"{PROJECT_NAME}/{folder}/{name}")

test_sources = []
tests_dir = os.path.join(ROOT, f"{PROJECT_NAME}Tests")
for name in sorted(os.listdir(tests_dir)):
    if name.endswith(".swift"):
        test_sources.append(f"{PROJECT_NAME}Tests/{name}")

# IDs
project_id = uid("project")
main_group_id = uid("main_group")
products_group_id = uid("products_group")
app_group_id = uid("app_group")
tests_group_id = uid("tests_group")
frameworks_group_id = uid("frameworks_group")
app_target_id = uid("app_target")
test_target_id = uid("test_target")
app_product_id = uid("app_product")
test_product_id = uid("test_product")
app_sources_phase_id = uid("app_sources_phase")
test_sources_phase_id = uid("test_sources_phase")
app_frameworks_phase_id = uid("app_frameworks_phase")
test_frameworks_phase_id = uid("test_frameworks_phase")
app_resources_phase_id = uid("app_resources_phase")
target_dep_id = uid("target_dep")
container_proxy_id = uid("container_proxy")
project_config_list_id = uid("project_config_list")
app_config_list_id = uid("app_config_list")
test_config_list_id = uid("test_config_list")
debug_config_id = uid("debug_config")
release_config_id = uid("release_config")
app_debug_config_id = uid("app_debug_config")
app_release_config_id = uid("app_release_config")
test_debug_config_id = uid("test_debug_config")
test_release_config_id = uid("test_release_config")

file_refs = {}
build_files_app = {}
build_files_test = {}

for path in app_sources:
    ref_id = uid(f"ref_{path}")
    build_id = uid(f"build_{path}")
    file_refs[path] = ref_id
    build_files_app[path] = build_id

for path in test_sources:
    ref_id = uid(f"ref_{path}")
    build_id = uid(f"build_{path}")
    file_refs[path] = ref_id
    build_files_test[path] = build_id

info_plist_ref = uid("ref_info_plist")
info_plist_build = uid("build_info_plist")
assets_path = f"{PROJECT_NAME}/Assets.xcassets"
assets_ref = uid(f"ref_{assets_path}")
assets_build = uid(f"build_{assets_path}")

lines = []
lines.append("// !$*UTF8*$!")
lines.append("{")
lines.append(f"	archiveVersion = 1;")
lines.append(f"	classes = {{}};")
lines.append(f"	objectVersion = 56;")
lines.append(f"	objects = {{")

# PBXBuildFile
for path, build_id in build_files_app.items():
    lines.append(f"		{build_id} /* {os.path.basename(path)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[path]} /* {os.path.basename(path)} */; }};")
for path, build_id in build_files_test.items():
    lines.append(f"		{build_id} /* {os.path.basename(path)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[path]} /* {os.path.basename(path)} */; }};")
lines.append(f"		{assets_build} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_ref} /* Assets.xcassets */; }};")

# PBXContainerItemProxy
lines.append(f"		{container_proxy_id} /* PBXContainerItemProxy */ = {{isa = PBXContainerItemProxy; containerPortal = {project_id} /* Project object */; proxyType = 1; remoteGlobalIDString = {app_target_id}; remoteInfo = {PROJECT_NAME}; }};")

# PBXFileReference
lines.append(f"		{app_product_id} /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
lines.append(f"		{test_product_id} /* {PROJECT_NAME}Tests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {PROJECT_NAME}Tests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};")
lines.append(f"		{info_plist_ref} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
lines.append(f"		{assets_ref} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};")
for path, ref_id in file_refs.items():
    lines.append(f"		{ref_id} /* {os.path.basename(path)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {os.path.basename(path)}; sourceTree = \"<group>\"; }};")

# PBXFrameworksBuildPhase
lines.append(f"		{app_frameworks_phase_id} /* Frameworks */ = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};")
lines.append(f"		{test_frameworks_phase_id} /* Frameworks */ = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};")

# PBXGroup
lines.append(f"		{frameworks_group_id} /* Frameworks */ = {{isa = PBXGroup; children = (); name = Frameworks; sourceTree = \"<group>\"; }};")
lines.append(f"		{products_group_id} /* Products */ = {{isa = PBXGroup; children = ({app_product_id} /* {PROJECT_NAME}.app */, {test_product_id} /* {PROJECT_NAME}Tests.xctest */, ); name = Products; sourceTree = \"<group>\"; }};")

# App subgroups
subgroup_ids = {}
for folder in ["App", "GameCore", "GameScene", "Audio"]:
    gid = uid(f"group_{folder}")
    subgroup_ids[folder] = gid
    children = []
    base = os.path.join(ROOT, PROJECT_NAME, folder)
    for name in sorted(os.listdir(base)):
        if name.endswith(".swift"):
            path = f"{PROJECT_NAME}/{folder}/{name}"
            children.append(f"{file_refs[path]} /* {name} */")
    lines.append(f"		{gid} /* {folder} */ = {{isa = PBXGroup; children = ({', '.join(children)}, ); path = {folder}; sourceTree = \"<group>\"; }};")

app_children = [f"{subgroup_ids[f]} /* {f} */" for f in ["App", "GameCore", "GameScene", "Audio"]]
app_children.append(f"{info_plist_ref} /* Info.plist */")
app_children.append(f"{assets_ref} /* Assets.xcassets */")
lines.append(f"		{app_group_id} /* {PROJECT_NAME} */ = {{isa = PBXGroup; children = ({', '.join(app_children)}, ); path = {PROJECT_NAME}; sourceTree = \"<group>\"; }};")

test_children = []
for path in test_sources:
    test_children.append(f"{file_refs[path]} /* {os.path.basename(path)} */")
lines.append(f"		{tests_group_id} /* {PROJECT_NAME}Tests */ = {{isa = PBXGroup; children = ({', '.join(test_children)}, ); path = {PROJECT_NAME}Tests; sourceTree = \"<group>\"; }};")

lines.append(f"		{main_group_id} = {{isa = PBXGroup; children = ({app_group_id} /* {PROJECT_NAME} */, {tests_group_id} /* {PROJECT_NAME}Tests */, {products_group_id} /* Products */, {frameworks_group_id} /* Frameworks */, ); sourceTree = \"<group>\"; }};")

# PBXNativeTarget
lines.append(f"		{app_target_id} /* {PROJECT_NAME} */ = {{isa = PBXNativeTarget; buildConfigurationList = {app_config_list_id} /* Build configuration list for PBXNativeTarget \"{PROJECT_NAME}\" */; buildPhases = ({app_sources_phase_id} /* Sources */, {app_frameworks_phase_id} /* Frameworks */, {app_resources_phase_id} /* Resources */, ); buildRules = (); dependencies = (); name = {PROJECT_NAME}; productName = {PROJECT_NAME}; productReference = {app_product_id} /* {PROJECT_NAME}.app */; productType = \"com.apple.product-type.application\"; }};")
lines.append(f"		{test_target_id} /* {PROJECT_NAME}Tests */ = {{isa = PBXNativeTarget; buildConfigurationList = {test_config_list_id} /* Build configuration list for PBXNativeTarget \"{PROJECT_NAME}Tests\" */; buildPhases = ({test_sources_phase_id} /* Sources */, {test_frameworks_phase_id} /* Frameworks */, ); buildRules = (); dependencies = ({target_dep_id} /* PBXTargetDependency */, ); name = {PROJECT_NAME}Tests; productName = {PROJECT_NAME}Tests; productReference = {test_product_id} /* {PROJECT_NAME}Tests.xctest */; productType = \"com.apple.product-type.bundle.unit-test\"; }};")

# PBXProject
lines.append(f"		{project_id} /* Project object */ = {{isa = PBXProject; attributes = {{LastSwiftUpdateCheck = 1500; LastUpgradeCheck = 1500; TargetAttributes = {{{test_target_id} = {{CreatedOnToolsVersion = 15.0; TestTargetID = {app_target_id}; }}; }}; }}; buildConfigurationList = {project_config_list_id} /* Build configuration list for PBXProject \"{PROJECT_NAME}\" */; compatibilityVersion = \"Xcode 14.0\"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, Base, ); mainGroup = {main_group_id}; productRefGroup = {products_group_id} /* Products */; projectDirPath = \"\"; projectRoot = \"\"; targets = ({app_target_id} /* {PROJECT_NAME} */, {test_target_id} /* {PROJECT_NAME}Tests */, ); }};")

# PBXResourcesBuildPhase
lines.append(f"		{app_resources_phase_id} /* Resources */ = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({assets_build} /* Assets.xcassets in Resources */, ); runOnlyForDeploymentPostprocessing = 0; }};")

# PBXSourcesBuildPhase
app_source_entries = [f"{build_files_app[p]} /* {os.path.basename(p)} in Sources */" for p in app_sources]
lines.append(f"		{app_sources_phase_id} /* Sources */ = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({', '.join(app_source_entries)}, ); runOnlyForDeploymentPostprocessing = 0; }};")
test_source_entries = [f"{build_files_test[p]} /* {os.path.basename(p)} in Sources */" for p in test_sources]
lines.append(f"		{test_sources_phase_id} /* Sources */ = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({', '.join(test_source_entries)}, ); runOnlyForDeploymentPostprocessing = 0; }};")

# PBXTargetDependency
lines.append(f"		{target_dep_id} /* PBXTargetDependency */ = {{isa = PBXTargetDependency; target = {app_target_id} /* {PROJECT_NAME} */; targetProxy = {container_proxy_id} /* PBXContainerItemProxy */; }};")

# XCBuildConfiguration - project
common_debug = textwrap.dedent("""
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				IPHONEOS_DEPLOYMENT_TARGET = {ios};
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
""").strip()

common_release = textwrap.dedent("""
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				IPHONEOS_DEPLOYMENT_TARGET = {ios};
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
""").strip()

lines.append(f"		{debug_config_id} /* Debug */ = {{isa = XCBuildConfiguration; buildSettings = {{{common_debug.format(ios=IOS_DEPLOYMENT)}}}; name = Debug; }};")
lines.append(f"		{release_config_id} /* Release */ = {{isa = XCBuildConfiguration; buildSettings = {{{common_release.format(ios=IOS_DEPLOYMENT)}}}; name = Release; }};")

app_settings_debug = textwrap.dedent(f"""
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_TESTABILITY = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = {PROJECT_NAME}/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 0.1.0;
				PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
""").strip()

app_settings_release = app_settings_debug

test_settings = textwrap.dedent(f"""
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = {IOS_DEPLOYMENT};
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@loader_path/Frameworks",
				);
				MARKETING_VERSION = 0.1.0;
				PRODUCT_BUNDLE_IDENTIFIER = {TEST_BUNDLE_ID};
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/{PROJECT_NAME}.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/{PROJECT_NAME}";
				TEST_TARGET_NAME = {PROJECT_NAME};
""").strip()

lines.append(f"		{app_debug_config_id} /* Debug */ = {{isa = XCBuildConfiguration; buildSettings = {{{app_settings_debug}}}; name = Debug; }};")
lines.append(f"		{app_release_config_id} /* Release */ = {{isa = XCBuildConfiguration; buildSettings = {{{app_settings_release}}}; name = Release; }};")
lines.append(f"		{test_debug_config_id} /* Debug */ = {{isa = XCBuildConfiguration; buildSettings = {{{test_settings}}}; name = Debug; }};")
lines.append(f"		{test_release_config_id} /* Release */ = {{isa = XCBuildConfiguration; buildSettings = {{{test_settings}}}; name = Release; }};")

# XCConfigurationList
lines.append(f"		{project_config_list_id} /* Build configuration list for PBXProject \"{PROJECT_NAME}\" */ = {{isa = XCConfigurationList; buildConfigurations = ({debug_config_id} /* Debug */, {release_config_id} /* Release */, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
lines.append(f"		{app_config_list_id} /* Build configuration list for PBXNativeTarget \"{PROJECT_NAME}\" */ = {{isa = XCConfigurationList; buildConfigurations = ({app_debug_config_id} /* Debug */, {app_release_config_id} /* Release */, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
lines.append(f"		{test_config_list_id} /* Build configuration list for PBXNativeTarget \"{PROJECT_NAME}Tests\" */ = {{isa = XCConfigurationList; buildConfigurations = ({test_debug_config_id} /* Debug */, {test_release_config_id} /* Release */, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")

lines.append("	};")
lines.append(f"	rootObject = {project_id} /* Project object */;")
lines.append("}")

pbxproj_dir = os.path.join(ROOT, f"{PROJECT_NAME}.xcodeproj")
os.makedirs(pbxproj_dir, exist_ok=True)
with open(os.path.join(pbxproj_dir, "project.pbxproj"), "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

# Shared scheme
scheme_dir = os.path.join(pbxproj_dir, "xcshareddata", "xcschemes")
os.makedirs(scheme_dir, exist_ok=True)
scheme_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{app_target_id}"
               BuildableName = "{PROJECT_NAME}.app"
               BlueprintName = "{PROJECT_NAME}"
               ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{test_target_id}"
               BuildableName = "{PROJECT_NAME}Tests.xctest"
               BlueprintName = "{PROJECT_NAME}Tests"
               ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "{PROJECT_NAME}.app"
            BlueprintName = "{PROJECT_NAME}"
            ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "{PROJECT_NAME}.app"
            BlueprintName = "{PROJECT_NAME}"
            ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
with open(os.path.join(scheme_dir, f"{PROJECT_NAME}.xcscheme"), "w", encoding="utf-8") as f:
    f.write(scheme_xml)

print(f"Generated {pbxproj_dir}")
print(f"App sources: {len(app_sources)}")
print(f"Test sources: {len(test_sources)}")
