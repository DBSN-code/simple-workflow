# Remove only exact, uncustomized blocks emitted by the old installer.
# The caller skips files containing TOML multiline strings or CRLF.
{ lines[NR] = $0 }
END {
    root = 1
    for (i = 1; i <= NR; i++) {
        if (root && lines[i] == "# Simple Workflow — managed defaults" &&
            lines[i+1] == "model = \"gpt-5.6\"" &&
            lines[i+2] == "model_reasoning_effort = \"medium\"" &&
            lines[i+3] == "plan_mode_reasoning_effort = \"high\"") {
            i += 3
            continue
        }
        if (!keep_astra && lines[i] == "# Simple Workflow — optional Astra profile" &&
            lines[i+1] == "[profiles.astra]" &&
            lines[i+2] == "model = \"gpt-6-astra\"" &&
            lines[i+3] == "model_reasoning_effort = \"low\"" &&
            lines[i+4] == "plan_mode_reasoning_effort = \"medium\"") {
            safe = 1
            for (j = i+5; j <= NR && lines[j] !~ /^[ \t]*\[/; j++) {
                if (lines[j] !~ /^[ \t]*(#.*)?$/) safe = 0
            }
            if (safe) { i += 4; continue }
        }
        if (lines[i] ~ /^[ \t]*\[/) root = 0
        print lines[i]
    }
}
