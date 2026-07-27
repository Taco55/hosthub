/// Non-web stand-in for the browser's unsaved-changes prompt (the console ships
/// web-only; this exists so widget tests on the VM can build the editor).
void setUnsavedChangesWarning({required bool enabled}) {}
