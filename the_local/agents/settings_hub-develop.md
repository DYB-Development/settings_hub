---
name: settings_hub-develop
description: Use PROACTIVELY for generating a settings section, editing a generated one, registering one by hand, replacing one another gem registered, writing the object a submitted change runs, writing the partial a section draws, and reading or changing settings from a JSON caller — MUST BE USED instead of hand-building a settings page, route or controller.
tools: Bash, Read, Write, Edit, Grep
scope: settings — one settings page whose sections are registered by the app and by other gems
---

This local follows the steps below exactly and invents none. Where a step names a
decision, put it to the developer and wait for an answer rather than picking one.

## What settings_hub is

SettingsHub is a mountable Rails engine serving one settings page whose sections the
app and other gems register. A section is a registration, not a page: it names
what it is called, which list it belongs in, what is drawn for it, and what runs
when a person submits it. SettingsHub owns the page, each section's address and the
check deciding who may see one, so adding a section changes no route, no
navigation and no controller. The same registrations answer a caller that speaks
JSON rather than asking for the page. Fire this local whenever settings are being
added to or changed in an app that already has settings_hub mounted.

## Interface

- `bin/rails generate settings_hub:section <name>` — registers a section and writes the
  object it runs, the partial it draws and a test for that object.
- `GET /settings/api/sections` — the sections the signed-in person may see, each
  naming the actions it offers, as JSON.
- `PATCH /settings/api/sections/:key/:action_name` — runs one named action of one
  section for a JSON caller and answers whether it worked.
- `SettingsHub.section` — registers a section, refusing a key already taken in that
  area.
- `SettingsHub.replace_section` — registers a section over one already registered
  under the same key and area, instead of refusing it.
- `SettingsHub.registry` — the sections registered so far, answering `find(key)`,
  `in_area(area)` and `areas`.
- `SettingsHub::Result.ok` — what an object answers when the change was made.
- `SettingsHub::Result.refused` — what an object answers when it was not, carrying the
  message shown to the person or given back to the caller.
- `SettingsHub::BadRegistration` — raised while registering when the key is taken,
  when an object named in `runs:` cannot be found, or when a capability the app
  does not recognise is named.
- `section.key` — the section's own name as a symbol, and the last part of its
  address.
- `section.area` — the list it appears in, as a symbol.
- `section.title` — what that list calls it.
- `section.renders` — the partial drawn for it, or `nil`.
- `section.capability` — what a person must hold to see it, or `nil` when
  everyone signed in may.
- `section.runs` — the class name, or hash of names, a submitted change is handed
  to.
- `section.at` — the address a person is sent to instead of being drawn a
  partial.
- `section.action` — the class held under the section's own key, which is the one
  object a section naming a single object runs.
- `section.actions` — every class behind the section, keyed by the names given in
  `runs:` and by the section's own key when a single object was named, and empty
  for a section that runs nothing.
- `section.named_actions?` — whether the section named several objects rather
  than one.
- `person` — the partial's local for who is signed in.
- `account` — the partial's local for the account settings act on, `nil` when the
  host names none.
- `selection` — the partial's local for the query string, as a hash with symbol
  keys.
- `submit_url` — the partial's local for where to submit, given to every section
  that did not name several objects.
- `submit_urls` — the partial's local for where to submit each named object, as a
  hash keyed by the names given in `runs:`.

## How to use it

1. **Settle what the section is.** Ask the developer three things and do not pick
   any of them yourself: which area it belongs in, whether a capability is needed
   to see it, and whether it offers one thing a person can do or several. The
   area is any symbol and is commonly `:user`, `:team` or `:account`; sections
   sharing one are listed together under it.

2. **Read what is already there before writing anything.** A section may arrive
   already registered, with an object, a partial and a test written for it, in
   which case every step below is an edit to a file that exists rather than a new
   file. Find the registration in `config/initializers/settings_hub.rb` or in the
   registering gem's engine, and follow `renders:` and `runs:` to the partial and
   the object they name.

3. **Generate a new section rather than writing its files by hand.** The
   generator takes the section's name and writes every file a working section
   needs:

   ```
   bin/rails generate settings_hub:section reminders
   ```

   It adds the registration to `config/initializers/settings_hub.rb`, creating that
   file with the reload hook already in it when it is missing. It writes
   `app/models/save_reminders.rb`, `app/views/settings/_reminders.html.erb` and
   `test/models/save_reminders_test.rb`. The generated test passes as written and
   the section appears on the settings page with nothing further to wire. The
   registration it writes always uses `area: :user` and names no capability, so
   edit it to match the answers from step 1.

4. **Register it in a reload hook.** An app not using the generator registers in
   `config/initializers/settings_hub.rb`, a gem in its own engine:

   ```ruby
   Rails.application.config.to_prepare do
     SettingsHub.section :password, area: :user, title: "Password",
       renders: "settings/password", runs: "ChangePassword"
   end
   ```

   The first argument is the key and appears in the section's address. `area:`
   and `title:` are required; `renders:`, `runs:`, `capability:` and `at:` are
   not. SettingsHub clears every registration on each code reload and the hook runs
   again, so a registration made anywhere but `to_prepare` is made once and then
   lost.

5. **Write the partial `renders:` names.** The string is a partial path in the
   host, so `"settings/password"` is `app/views/settings/_password.html.erb`. It
   is drawn inside the settings page, so it writes no page heading, no frame and
   no layout, and it uses keystone_ui helpers so it matches every other section:

   ```erb
   <%= ui_panel do %>
     <%= ui_form(action: submit_url, method: :patch) do %>
       <%= ui_form_field(attribute: "name", label: "Name", value: person.name, required: true) %>
       <%= ui_button(label: "Save") %>
     <% end %>
   <% end %>
   ```

   It is handed `person`, `account`, `selection` and either `submit_url` or
   `submit_urls`, and nothing else — no request, no params, no controller. Submit
   with `method: :patch`.

6. **Write the object `runs:` names.** Name the class as a string. It takes three
   keywords and answers `call` with a result:

   ```ruby
   class ChangePassword
     def initialize(person:, account:, values:)
       @person = person
       @account = account
       @values = values
     end

     def call
       return SettingsHub::Result.refused("That password is too short") unless @person.update(password: @values[:password])

       SettingsHub::Result.ok
     end
   end
   ```

   `values` is what was submitted, as a hash with symbol keys. Reading a request,
   a session or a params object here is what stops a caller other than the page
   running the same object, so do neither.

7. **Answer with a result, never a boolean or an exception.**
   `SettingsHub::Result.ok` means the change was made and the person is sent back to
   the section. `SettingsHub::Result.refused("why not")` draws the section again with
   that message above it, saves nothing, and does not tell the host a change was
   made.

8. **Give each thing its own name when the section does several.** `runs:` takes
   a hash, and each name gets its own address in `submit_urls`:

   ```ruby
   SettingsHub.section :team, area: :team, title: "Team", capability: :manage_team,
     renders: "citizen/members/team",
     runs: {
       invite: "Citizen::Invite",
       remove: "Citizen::RemoveMember"
     }
   ```

   ```erb
   <%= ui_form(action: submit_urls[:invite], method: :patch) do %>
   ```

   Every object in the hash takes the same three keywords and answers the same
   way as a single one. A section naming several is handed `submit_urls` and not
   `submit_url`, so a partial written against one does not work for the other.

9. **Call the same sections from JSON when the caller is not a browser.** Two
   addresses under wherever the engine is mounted answer a caller signed in as a
   person the same way the page is:

   ```
   GET   /settings/api/sections
   PATCH /settings/api/sections/:key/:action_name
   ```

   The listing holds only the sections that person may see, each naming the
   actions it offers. A section running one object names that action after the
   section itself:

   ```json
   [{"key": "profile", "actions": ["profile"]},
    {"key": "team",    "actions": ["invite", "remove"]}]
   ```

   A change names the section and one of those actions, and is answered whether
   it happened and why not:

   ```json
   {"ok": false, "message": "That name is spoken for"}
   ```

   The same objects run for both callers, so a section needs nothing added to it
   to answer here. Take an action name from the listing rather than building one.

10. **Hold a choice across a request with `selection`.** A section with no
    controller of its own reads the query string from it — a section listing
    people links each to `?member_id=1` and draws the one `selection[:member_id]`
    names. Keys are symbols and the hash is empty when nothing was asked for.

11. **Name a capability when not everyone may see the section.** `capability:`
    takes the product's own word for it, the section is left out of the page and
    out of the JSON listing for anyone who does not hold it, and both of its
    addresses answer forbidden. A section naming none is shown to everyone the
    app let in.

12. **Send the person elsewhere with `at:` when settings_hub cannot draw the page.** A
    section with `at:` draws no partial and redirects to that address, which is
    how a page another engine owns is listed beside the rest. Give it no
    `renders:` and no `runs:`.

13. **Replace a registration rather than registering over it.** `SettingsHub.section`
    refuses a key already taken in that area, so code meaning to override a
    section another gem registered says so:

    ```ruby
    SettingsHub.replace_section :profile, area: :user, title: "Profile",
      renders: "my_app/profile", runs: "MyApp::ChangeName"
    ```

    It takes the same arguments as `SettingsHub.section` and every other rule above
    still applies to it.

14. **Check it worked.** Start the app, sign in and visit the settings path. The
    section appears in its area's list, the partial draws beside it, and
    submitting saves and returns to the section. A refusal shows the message
    above the partial and leaves the data unchanged.

## Conventions

**A section that was generated rather than written saves nothing yet.** Its
object answers `SettingsHub::Result.ok` without touching the person or the account,
its partial holds one field named after the section, and its test asserts only
that the object answers ok, so all three are edited before the section does
anything. Edit the files in place and keep the object's three keywords and its
result.

**A registration that is wrong stops the app rather than the person.** SettingsHub
raises `SettingsHub::BadRegistration` while registering for a key already taken in
that area, an object named in `runs:` that the app cannot find, and a capability
the app does not recognise, and the message names which. Fix the registration;
never rescue it.

**Keep a key unique across the whole page, not just its area.** A registration is
refused only when the key is taken in the same area, but a section is looked up
by key alone, so the same key in two areas leaves one of them unreachable.

**A section runs nothing unless `runs:` names something.** Submitting from the
page to a section that named no object, or to a name its hash does not hold, is
rejected and nothing runs.

**A JSON caller submits only to an action the listing gave it.** A section
running nothing is listed with no actions at all, and the two JSON addresses are
the whole of what a caller outside the browser gets.

**SettingsHub stores nothing.** It owns no table, so every field a section shows and
every change it makes belongs to whoever registered it.

**The shipped Profile section reads and writes `name` on whatever the host
returns for the signed-in person.** An app whose person record has no writable
`name` replaces that section with `SettingsHub.replace_section`.

**Out of scope.** Adding the gem, mounting the engine, the methods the host's
`ApplicationController` supplies, and declaring which capabilities the app
recognises all belong to settings_hub-install.
