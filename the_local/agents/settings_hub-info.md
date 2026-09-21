---
name: settings_hub-info
description: Use to learn what settings_hub offers — the shared settings page, sections as registrations, and the vocabulary its other locals assume.
tools: Read
scope: settings — one settings page whose sections are registered by the app and by other gems
---

This local explains what settings_hub is and which of its other locals you want. It
changes nothing and gives no steps.

## What settings_hub is

SettingsHub is the settings page an app mounts instead of building. It is a mountable
Rails engine that owns the page itself, the list of what appears on it, the
address each entry is served at, and the check deciding who may see one. An app
or another gem adds to that page by registering a section, and a section owns
only its own fields and the things a person can do with them. Adding one changes
no routing, no navigation and no controller in the host.

Reach for it when a product needs one settings page that several parts of the
codebase contribute to — the app's own settings beside settings that belong to
gems the app installs. Those same registrations also answer a caller that speaks
JSON rather than asking for the page, so a client outside the browser reads and
changes settings without the app building a second interface for them. SettingsHub
owns no database table and stores nothing; every section's data belongs to
whoever registered it. Every page is drawn with keystone_ui, so a host that does
not use keystone_ui gets a settings page that does not match the rest of it.

## Interface

SettingsHub's surface is split between its other two locals and this one documents
none of it.

- **settings_hub-install** — putting the gem in, mounting the engine, the methods the
  host's `ApplicationController` supplies for who is signed in and what settings
  act on, and telling settings_hub which capabilities the app recognises.
- **settings_hub-develop** — writing a new section's starting files, registering a
  section by hand, replacing one another gem registered, the object a section
  hands a submitted change to, the result that object answers with, the locals
  its partial is drawn with, and the addresses a JSON caller reads and submits
  at.

## How to use it

- Putting settings_hub into an app for the first time, or an app has it and no section
  is appearing — **settings_hub-install**.
- Starting a section from nothing, editing one that was generated, registering
  one by hand, changing one that already exists, or calling settings from
  outside the browser — **settings_hub-develop**.

Both, in that order, when an app is taking settings_hub and its first section in the
same pass.

## Conventions

**Section** — one registration, not a page and not a controller. It names what
it is called, which list it belongs in, what is drawn for it, and what runs when
a person submits it.

**Area** — the list a section appears in on the page, named by a symbol. The
person's own settings, a team's and an account's are the usual three, any symbol
is allowed, and sections sharing an area are shown together.

**Key** — the section's own name, used in its address under wherever the engine
is mounted. A registration taking a key already held in that area is refused
when the app starts rather than in front of a person, and a section is found by
key alone, so the same key in two areas leaves one of them unreachable.

**Action** — one thing a person can do in a section, named by a symbol and
answered by its own object. A section that offers several names each of them; a
section that offers one has that action named after the section itself, so a
caller addresses every action the same way whichever kind it is.

**Capability** — the product's word for what a person must hold to see a
section. A section that names none is shown to everyone signed in, and the host
answers whether the signed-in person holds one. The refusal to register a
capability the app does not recognise runs only once the app declares which
capabilities exist, which is what lets settings_hub be installed without the gem that
would normally supply them.

**Registration time** — registrations are made in the reload hook rather than at
boot, and settings_hub clears what it holds on each reload, so the set of sections is
rebuilt from scratch every time the code reloads.

**Refusal** — a submitted change that did not happen. The object behind the
section says so with a message, nothing is saved, and the host is not told a
change was made. A person is drawn the section again with the message above it,
and a JSON caller is answered that it did not happen and given the same message.

**Generated code is a starting point.** A section written from nothing runs and
its test passes as written, and everything in it is meant to be edited rather
than kept as it came out.
