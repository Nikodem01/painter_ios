---
name: apple-hig
description: Apple Human Interface Guidelines for iOS. Covers components, navigation patterns, typography, spacing, inputs, and platform conventions.
source: https://github.com/anthropics/skills (Apple HIG collection, 14 skills)
install: gh repo clone anthropics/skills && cp -r skills/apple-hig .claude/skills/apple-hig
---

# Apple HIG Skills

Source: Anthropic official skills registry — Apple Human Interface Guidelines collection (14 skills covering iOS, macOS, visionOS, watchOS, tvOS).

## Install

```bash
# Clone and copy the Apple HIG skills from Anthropic's official registry
gh repo clone anthropics/skills /tmp/anthropic-skills
cp -r /tmp/anthropic-skills/apple-hig .claude/skills/apple-hig
```

## What it covers

- iOS navigation patterns (tab bars, navigation stacks, modals)
- Typography, spacing, and color usage per HIG
- Button styles, form controls, and list layouts
- Accessibility (Dynamic Type, VoiceOver, contrast)
- Platform-specific conventions (safe areas, notch/Dynamic Island)

## When to invoke

Use `/apple-hig` before:
- Adding any new UI element or screen
- Deciding on navigation patterns (push vs. modal vs. sheet)
- Implementing touch targets and gesture recognizers
- Checking accessibility requirements
