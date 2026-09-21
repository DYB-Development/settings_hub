---
name: settings_hub-install
description: Use to hook settings_hub into a project — adding the gem, mounting the settings engine, supplying the methods it asks the host controller for, and declaring which capabilities the app recognises.
tools: Bash, Read, Edit
scope: settings — one settings page whose sections are registered by the app and by other gems
---

This local follows the steps below exactly and invents none. Where a step names a
decision, put it to the developer and wait for an answer rather than picking one.

## What settings_hub is

SettingsHub is a mountable Rails engine serving one settings page whose sections the
app and other gems register; hook it in when a product needs that page instead of
building one.

## Interface

- `gem "settings_hub"` — puts the engine, the settings page and the shipped Profile
  section into the app.
- `mount SettingsHub::Engine => "/settings"` — serves the settings page and every
  section's address under the path you mount it at.
- `current_person` — the host's answer for who is signed in, and the only one of
  these methods settings_hub always needs.
- `settings_account` — the host's answer for which account settings act on, asked
  for before `current_account` and falling back to it.
- `can?(capability)` — the host's answer for whether the signed-in person holds a
  capability, needed once any section names one.
- `after_settings_change(section:, person:)` — the host's hook, run after a
  change submitted from the settings page succeeds and skipped when one is
  refused.
- `SettingsHub.capabilities` — the list of capabilities the app recognises, which
  settings_hub checks a registration's capability against once it is set.

## How to use it

1. **Add the gem.** Put `gem "settings_hub"` in the app's `Gemfile` and run `bundle
   install`. There is no migration to run, because settings_hub owns no database table.

2. **Check keystone_ui is hooked up.** SettingsHub draws every page with keystone_ui
   and brings it in as a dependency, so a host that has not set keystone_ui up
   gets a settings page that does not match the rest of the app. Hooking that up
   is keystone_ui's own local, not this one.

3. **Mount the engine.** Add one line to `config/routes.rb`:

   ```ruby
   mount SettingsHub::Engine => "/settings"
   ```

   Ask the developer which path to mount it at if the app already serves
   something at `/settings`. Every settings address sits under whatever you
   choose, the ones a caller outside the browser uses included, and nothing else
   in the app changes when it moves.

4. **Add `current_person` to `app/controllers/application_controller.rb`.** It
   returns the signed-in person record and may be private:

   ```ruby
   private

   def current_person
     Current.person
   end
   ```

   SettingsHub's controllers inherit from the app's `ApplicationController`, so the
   app's own `before_action` filters — authentication included — already run on
   the settings page. Do not add a second authentication check.

5. **Decide which account settings act on.** Define `settings_account` on
   `ApplicationController` when the settings page acts on something other than
   the account the app calls `current_account`. SettingsHub asks for
   `settings_account` first, uses `current_account` when it is not defined, and
   passes `nil` when neither is — which is correct for a product whose settings
   are all personal. Ask the developer which of the three applies; there is no
   safe default.

6. **Add `can?` once a section names a capability.** It takes one capability and
   answers true or false:

   ```ruby
   def can?(capability)
     Current.person.can?(capability)
   end
   ```

   A section naming no capability is shown to everyone the app let in, so an app
   whose sections all name none does not need this method.

7. **Declare the app's capabilities, if it has any.** Assign `SettingsHub.capabilities`
   in `config/initializers/settings_hub.rb`, creating that file if the app has none:

   ```ruby
   SettingsHub.capabilities = -> { Citizen.capabilities }
   ```

   It takes a list or something answering `call` that returns one; use the
   callable form when the list comes from a class the app reloads. An app that
   declares nothing is never refused a registration naming a capability, which is
   what lets settings_hub be installed without the gem that would normally supply the
   list. Ask the developer where the app's capability list comes from rather than
   guessing at a constant.

8. **Add `after_settings_change` only if the app needs it.** It takes `section:`
   and `person:` as keywords and runs after a change succeeds:

   ```ruby
   def after_settings_change(section:, person:)
     Audit.record(person: person, changed: section)
   end
   ```

   Leave it out unless the developer names something the app must do on every
   settings change. SettingsHub runs it for a change submitted from the settings page
   and not for one submitted by a caller outside the browser, so tell the
   developer this hook does not see every change if the app also has such
   callers.

## Conventions

**Check it worked.** Start the app, sign in and visit the mount path. SettingsHub
registers a Profile section itself, so a working install shows a `User` list with
`Profile` in it and a Name field beside it. An empty page means the engine is
mounted but nothing registered; a failure on the Name field means
`current_person` returns something that does not answer `name`.

**The shipped Profile section reads and writes `name` on whatever
`current_person` returns.** An app whose person record has no writable `name`
replaces that section, which is settings_hub-develop's job rather than this one's.

**`can?` and `SettingsHub.capabilities` become required later.** Installing a gem that
registers sections naming capabilities makes both necessary even though the app
did not need them at install time — a section whose capability the app does not
recognise stops the app from starting, and one whose capability nothing answers
for is never shown.

**Re-run these steps when the host changes who is signed in.** Renaming or moving
the app's current-person method, or changing which account settings act on,
breaks the settings page and nothing else reports it.

**Out of scope.** Adding the app's own sections, editing the object a submitted
change is handed to, and writing the partial a section draws all belong to
settings_hub-develop. So does replacing a section another gem registered, and so does
reading or changing settings from outside the browser.
