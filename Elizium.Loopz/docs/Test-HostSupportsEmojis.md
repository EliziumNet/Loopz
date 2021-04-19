---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Test-HostSupportsEmojis

## SYNOPSIS

This is a rudimentary function to determine if the host can display emojis. This
function will be super-ceded when this issue (on microsoft/terminal
https://github.com/microsoft/terminal/issues/1040) is resolved.

## SYNTAX

```powershell
Test-HostSupportsEmojis
```

## DESCRIPTION

There is currently no standard way to determine this. As a crude workaround, this function
can determine if the host is Windows Terminal and returns true. Fluent Terminal can
display emojis, but does not render them very gracefully, so the default value
returned for Fluent is false. Its assumed that hosts on Linux and Mac can support
the display of emojis, so they return true. If user want to enforce using emojis,
then they can define LOOPZ_FORCE_EMOJIS in the environment, this will force this
function to return.

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Boolean

Returns $true if Host is deemed to support emoji display, $false otherwise.

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
