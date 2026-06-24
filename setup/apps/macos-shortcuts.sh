#!/bin/bash

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$(cd "$SETUP_DIR/.." && pwd)"

# shellcheck source=setup/lib/common.sh
source "$SETUP_DIR/lib/common.sh"

plist_buddy="/usr/libexec/PlistBuddy"
services_dir="${HOME}/Library/Services"
backups_dir="${services_dir}/.dotfiles-shortcut-backups"
preferences_dir="${HOME}/Library/Preferences"
pbs_plist="${preferences_dir}/pbs.plist"
services_menu_cache="${preferences_dir}/com.apple.ServicesMenu.Services.plist"
local_script_dir="${DOTFILES_DIR}/local/macos-shortcuts"
install_dir="${HOME}/.local/share/dotfiles/macos-shortcuts"
service_prefix="dotfiles-shortcut"
timestamp="$(date +%Y%m%d%H%M%S)"

shortcut_slots() {
    printf '%s\n' 1 2 5 6 7
}

assert_macos() {
    local action="$1"

    if [ "$(uname -s)" != "Darwin" ]; then
        print_error "macOS shortcut slots can only be ${action} on macOS"
        exit 1
    fi

    if [ ! -x "$plist_buddy" ]; then
        print_error "PlistBuddy not found at $plist_buddy"
        exit 1
    fi
}

shell_quote() {
    local value="${1//\'/\'\\\'\'}"

    printf "'%s'" "$value"
}

escape_xml() {
    sed \
        -e 's/&/\&amp;/g' \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g'
}

escape_plist_key() {
    printf '%s' "$1" | sed 's/ /\\ /g'
}

slot_service_name() {
    local slot="$1"

    printf '%s-%s\n' "$service_prefix" "$slot"
}

slot_local_script() {
    local slot="$1"

    printf '%s/%s.sh\n' "$local_script_dir" "$slot"
}

slot_installed_script() {
    local slot="$1"

    printf '%s/%s.sh\n' "$install_dir" "$slot"
}

slot_command() {
    local slot="$1"
    local installed_script

    installed_script="$(slot_installed_script "$slot")"
    printf '/bin/sh %s' "$(shell_quote "$installed_script")"
}

backup_path() {
    local path="$1"
    local basename

    if [ ! -e "$path" ] && [ ! -L "$path" ]; then
        return 0
    fi

    mkdir -p "$backups_dir"
    basename="$(basename "$path")"
    mv "$path" "${backups_dir}/${basename}.bak.${timestamp}"
}

install_slot_symlink() {
    local slot="$1"
    local local_script
    local installed_script

    local_script="$(slot_local_script "$slot")"
    installed_script="$(slot_installed_script "$slot")"

    mkdir -p "$local_script_dir" "$install_dir"

    if [ -L "$installed_script" ] && [ "$(readlink "$installed_script")" = "$local_script" ]; then
        return 0
    fi

    backup_path "$installed_script"
    ln -s "$local_script" "$installed_script"
}

write_info_plist() {
    local path="$1"
    local service_name="$2"

    mkdir -p "$(dirname "$path")"
    cat > "$path" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSServices</key>
  <array>
    <dict>
      <key>NSBackgroundColorName</key>
      <string>background</string>
      <key>NSIconName</key>
      <string>NSActionTemplate</string>
      <key>NSMenuItem</key>
      <dict>
        <key>default</key>
        <string>${service_name}</string>
      </dict>
      <key>NSMessage</key>
      <string>runWorkflowAsService</string>
    </dict>
  </array>
</dict>
</plist>
PLIST
}

write_document_wflow() {
    local path="$1"
    local shell_script="$2"

    shell_script="$(printf '%s' "$shell_script" | escape_xml)"

    cat > "$path" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>AMApplicationBuild</key>
  <string>531</string>
  <key>AMApplicationVersion</key>
  <string>2.10</string>
  <key>AMDocumentVersion</key>
  <string>2</string>
  <key>actions</key>
  <array>
    <dict>
      <key>action</key>
      <dict>
        <key>ActionBundlePath</key>
        <string>/System/Library/Automator/Run Shell Script.action</string>
        <key>ActionName</key>
        <string>Run Shell Script</string>
        <key>ActionParameters</key>
        <dict>
          <key>CheckedForUserDefaultShell</key>
          <false/>
          <key>COMMAND_STRING</key>
          <string>${shell_script}</string>
          <key>inputMethod</key>
          <integer>0</integer>
          <key>shell</key>
          <string>/bin/sh</string>
          <key>source</key>
          <string>${shell_script}</string>
        </dict>
        <key>AMAccepts</key>
        <dict>
          <key>Container</key>
          <string>List</string>
          <key>Optional</key>
          <true/>
          <key>Types</key>
          <array>
            <string>com.apple.applescript.object</string>
            <string>com.apple.cocoa.string</string>
          </array>
        </dict>
        <key>AMActionVersion</key>
        <string>2.0.3</string>
        <key>AMApplication</key>
        <array>
          <string>Automator</string>
        </array>
        <key>AMParameterProperties</key>
        <dict>
          <key>source</key>
          <dict/>
        </dict>
        <key>AMProvides</key>
        <dict>
          <key>Container</key>
          <string>List</string>
          <key>Types</key>
          <array>
            <string>com.apple.applescript.object</string>
            <string>com.apple.cocoa.string</string>
          </array>
        </dict>
        <key>arguments</key>
        <dict>
          <key>0</key>
          <dict>
            <key>default value</key>
            <string>${shell_script}</string>
            <key>name</key>
            <string>source</string>
            <key>required</key>
            <string>0</string>
            <key>type</key>
            <string>0</string>
            <key>uuid</key>
            <string>0</string>
          </dict>
        </dict>
        <key>BundleIdentifier</key>
        <string>com.apple.RunShellScript</string>
        <key>CanShowSelectedItemsWhenRun</key>
        <false/>
        <key>CanShowWhenRun</key>
        <true/>
        <key>Category</key>
        <array>
          <string>AMCategoryUtilities</string>
        </array>
        <key>CFBundleVersion</key>
        <string>2.0.3</string>
        <key>Class Name</key>
        <string>RunShellScriptAction</string>
        <key>InputUUID</key>
        <string>14261827-CBC1-40DA-B529-72EF16DE63EA</string>
        <key>Keywords</key>
        <array>
          <string>Run</string>
        </array>
        <key>OutputUUID</key>
        <string>6C30DDCE-B6A6-4ED3-BD5F-7D4C648B3F04</string>
        <key>UUID</key>
        <string>068799C6-24F6-41DF-A163-A941149643D4</string>
        <key>isViewVisible</key>
        <integer>1</integer>
        <key>location</key>
        <string>309.000000:368.000000</string>
        <key>nibPath</key>
        <string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
      </dict>
      <key>isViewVisible</key>
      <integer>1</integer>
    </dict>
  </array>
  <key>connectors</key>
  <dict/>
  <key>workflowMetaData</key>
  <dict>
    <key>applicationBundleIDsByPath</key>
    <dict/>
    <key>applicationPaths</key>
    <array/>
    <key>inputTypeIdentifier</key>
    <string>com.apple.Automator.nothing</string>
    <key>outputTypeIdentifier</key>
    <string>com.apple.Automator.nothing</string>
    <key>presentationMode</key>
    <integer>11</integer>
    <key>processesInput</key>
    <false/>
    <key>serviceInputTypeIdentifier</key>
    <string>com.apple.Automator.nothing</string>
    <key>serviceOutputTypeIdentifier</key>
    <string>com.apple.Automator.nothing</string>
    <key>serviceProcessesInput</key>
    <false/>
    <key>systemImageName</key>
    <string>NSActionTemplate</string>
    <key>useAutomaticInputType</key>
    <false/>
    <key>workflowTypeIdentifier</key>
    <string>com.apple.Automator.servicesMenu</string>
  </dict>
</dict>
</plist>
PLIST
}

install_workflow() {
    local slot="$1"
    local service_name
    local workflow_dir

    service_name="$(slot_service_name "$slot")"
    workflow_dir="${services_dir}/${service_name}.workflow"

    backup_path "$workflow_dir"
    mkdir -p "${workflow_dir}/Contents"
    write_info_plist "${workflow_dir}/Contents/Info.plist" "$service_name"
    write_document_wflow "${workflow_dir}/Contents/document.wflow" "$(slot_command "$slot")"
    plutil -lint "${workflow_dir}/Contents/Info.plist" "${workflow_dir}/Contents/document.wflow" >/dev/null
}

ensure_pbs_plist() {
    mkdir -p "$preferences_dir"
    if [ ! -f "$pbs_plist" ]; then
        cat > "$pbs_plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
PLIST
    fi

    if ! "$plist_buddy" -c "Print :NSServicesStatus" "$pbs_plist" >/dev/null 2>&1; then
        "$plist_buddy" -c "Add :NSServicesStatus dict" "$pbs_plist"
    fi
}

delete_service_shortcut() {
    local service_name="$1"
    local key="(null) - ${service_name} - runWorkflowAsService"

    "$plist_buddy" -c "Delete :NSServicesStatus:$(escape_plist_key "$key")" "$pbs_plist" >/dev/null 2>&1 || true
}

set_service_shortcut() {
    local slot="$1"
    local service_name
    local shortcut
    local key
    local key_path

    service_name="$(slot_service_name "$slot")"
    shortcut="@^\$$slot"
    key="(null) - ${service_name} - runWorkflowAsService"
    key_path="$(escape_plist_key "$key")"

    delete_service_shortcut "$service_name"
    "$plist_buddy" -c "Add :NSServicesStatus:${key_path} dict" "$pbs_plist"
    "$plist_buddy" -c "Add :NSServicesStatus:${key_path}:key_equivalent string ${shortcut}" "$pbs_plist"
    "$plist_buddy" -c "Add :NSServicesStatus:${key_path}:presentation_modes dict" "$pbs_plist"
    "$plist_buddy" -c "Add :NSServicesStatus:${key_path}:presentation_modes:ContextMenu bool true" "$pbs_plist"
    "$plist_buddy" -c "Add :NSServicesStatus:${key_path}:presentation_modes:ServicesMenu bool true" "$pbs_plist"
    "$plist_buddy" -c "Add :NSServicesStatus:${key_path}:presentation_modes:TouchBar bool true" "$pbs_plist"
}

install_shortcuts() {
    local slot

    assert_macos "installed"
    print_step "Installing macOS shortcut slots..."

    mkdir -p "$services_dir" "$install_dir" "$local_script_dir"

    while IFS= read -r slot; do
        install_slot_symlink "$slot"
        install_workflow "$slot"
    done < <(shortcut_slots)

    ensure_pbs_plist
    cp "$pbs_plist" "${pbs_plist}.bak.${timestamp}"

    while IFS= read -r slot; do
        set_service_shortcut "$slot"
    done < <(shortcut_slots)

    plutil -lint "$pbs_plist" >/dev/null

    if [ -f "$services_menu_cache" ]; then
        cp "$services_menu_cache" "${services_menu_cache}.bak.${timestamp}"
        rm "$services_menu_cache"
    fi

    killall com.apple.automator.runner >/dev/null 2>&1 || true
    killall cfprefsd >/dev/null 2>&1 || true
    killall pbs >/dev/null 2>&1 || true

    while IFS= read -r slot; do
        print_success "Installed shortcut slot $slot (Ctrl+Cmd+Shift+$slot)"
    done < <(shortcut_slots)
}

assert_equal() {
    local expected="$1"
    local actual="$2"
    local label="$3"

    if [ "$actual" != "$expected" ]; then
        printf 'Unexpected %s\nexpected: %s\nactual:   %s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}

check_workflow() {
    local slot="$1"
    local service_name
    local workflow_dir
    local info_plist
    local document_wflow
    local actual

    service_name="$(slot_service_name "$slot")"
    workflow_dir="${services_dir}/${service_name}.workflow"
    info_plist="${workflow_dir}/Contents/Info.plist"
    document_wflow="${workflow_dir}/Contents/document.wflow"

    test -d "$workflow_dir"
    test -f "$info_plist"
    test -f "$document_wflow"
    plutil -lint "$info_plist" "$document_wflow" >/dev/null

    actual="$(plutil -extract NSServices.0.NSMenuItem.default raw -o - "$info_plist")"
    assert_equal "$service_name" "$actual" "$service_name menu name"

    actual="$(plutil -extract actions.0.action.ActionName raw -o - "$document_wflow")"
    assert_equal "Run Shell Script" "$actual" "$service_name action name"

    actual="$(plutil -extract actions.0.action.ActionParameters.shell raw -o - "$document_wflow")"
    assert_equal "/bin/sh" "$actual" "$service_name shell"

    actual="$(plutil -extract actions.0.action.ActionParameters.COMMAND_STRING raw -o - "$document_wflow")"
    assert_equal "$(slot_command "$slot")" "$actual" "$service_name command"
}

check_shortcut() {
    local slot="$1"
    local service_name
    local shortcut
    local key
    local key_path
    local actual

    service_name="$(slot_service_name "$slot")"
    shortcut="@^\$$slot"
    key="(null) - ${service_name} - runWorkflowAsService"
    key_path="$(escape_plist_key "$key")"
    actual="$("$plist_buddy" -c "Print :NSServicesStatus:${key_path}:key_equivalent" "$pbs_plist")"
    assert_equal "$shortcut" "$actual" "$service_name keyboard shortcut"
}

check_slot_script() {
    local slot="$1"
    local local_script
    local installed_script

    local_script="$(slot_local_script "$slot")"
    installed_script="$(slot_installed_script "$slot")"

    test -L "$installed_script"
    assert_equal "$local_script" "$(readlink "$installed_script")" "slot $slot symlink target"

    if [ -f "$local_script" ]; then
        /bin/sh -n "$local_script"
    else
        print_info "No local script yet for slot $slot: $local_script"
    fi
}

check_shortcuts() {
    local slot

    assert_macos "checked"
    print_step "Checking macOS shortcut slots..."
    test -f "$pbs_plist"

    while IFS= read -r slot; do
        check_slot_script "$slot"
        check_workflow "$slot"
        check_shortcut "$slot"
    done < <(shortcut_slots)

    print_success "macOS shortcut slots are installed"
}

case "${1:-install}" in
    install)
        install_shortcuts
        ;;
    check)
        check_shortcuts
        ;;
    *)
        print_error "Usage: $0 [install|check]"
        exit 1
        ;;
esac
