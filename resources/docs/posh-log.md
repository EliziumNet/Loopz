<!-- MarkDownLint-disable MD013 -->
<!-- MarkDownLint-disable MD033 -->

# :nazar_amulet: Elizium.Loopz PoSh Log

One of the main rationale's for the development of :scroll: __Build-PoShLog__ (*chog*) was in recognition of the fact that a repo's commit history may be sub-optimal perhaps not conforming to the guidelines set out in sites like [Conventional Commits](https://www.conventionalcommits.org) and [Keep A Change Log](https://keepachangelog.com). *Build-PoShLog* was built to be flexible and allow for a wide variety of customisation options defined in json config file. Most of the options are cosmetic with a few that define the structure. Also, the user can keep the default regular expressions (which conform to keep-a-changelog). One of the properties of a good change log are that commits should be grouped together based upon change type/scope/commit-type/breaking changes. This change log implementation performs groupings based on all of these
categories. The quality of the generated changelog depends heavily on the quality of the commit messages in the repo.

The following is a list of the main aims of *Build-PoShLog* command:

1. Grouping commits by scope/type/change/breaking. These items are represented in the regular expressions defined in the options config

2. Filtering commits via 'Include' and 'Exclude' regular expressions

3. Squashing commits, usually by common issue number. If a repo contains un-squashed commits that refer to the same issue number, then they need to be treated as a single entry in the change log.

4. Harness the visual appeal of emoji's in highlighting categories of commits.

The _Build-PoShLog_ command can be used on any repo not just *PowerShell* projects.

## Quick Start

First, in a command line, the user should navigate to the repo for which the change log should be generated (trying to invoke the *Build-PoShLog* command from outside of a git repo will just fail), then perform the following steps:

### (1) __eject options config__

> Build-PoShLog -name 'Alpha' -eject -emoji

In the above, _Alpha_ is the name of a pre-defined config (_Elizium_ and _Zen_ are both available too). the *-emoji* switch is optional, but indicates that the ejected config will contain emojis. Running this eject, will create a folder under the root of the repo *'loopz'* and inside it will be the config just ejected, in this case ___Alpha-emoji-changelog.options.json___ and a template markdown file ___TEMPLATE. md___

### (2) __edit options config__

+ modify regular expressions (at ___./Selection/Subject/Include___): If the commits are already in a good format and adhere to the standards previously mentioned, then there will be no need to modify or add new expressions. However, this may not be the case. If the user can identify an alternative regular expression that matches the commits of their repo, then they should be defined and added to the include list. For each commit, the *Include* regular expressions are tried in the order they are defined, so it would probably be best to add the custom regular expression at the top. It would also be best to remove any regular expressions that do not suit the repo.

+ modify scopes (at ___./Output/LookUp/Scopes___): (This step can be ignored if not using emojis). Add an entry for each scope defined in the repo. Eg, if there is a scope called 'authentication' in the repo against which there are commits (eg subject: _'feat(authentication): Add GitHub authentication (#42)'_), then add an _authentication_ entry into scopes:

```json
  "Scopes": {
    "all": ":star:",
    "authentication": ":key:",
    "?": ":lock:"
  },
```

Repeat this for all valid scopes in the repo.

+ modify statements (at ___./Output/Statements___): This is an optional step, but doing so can aid the users understanding of how the tool works. The statements simply specify literal content and/or refer to other statements. For each commit entry in the change log, the entry point is the 'Commit' statement at ___./Output/Statements/Commit___. For each heading, the entry points are the those statements defined in the headings at ___./Output/Headings/H?___. So these statements should be present and the ones that they in turn refer to. New statements can be defined, see [Statement](#snippet.statement) for more details.

:warning: *A cautionary note about editing json config*: When *Build-PoShLog* is run, it validates the options via a [json schema](https://github.com/EliziumNet/Klassy/blob/master/Elizium.Klassy/FileList/options-chog.schema.json) and this validation process is case sensitive. So be careful when modifying json elements as a case mismatch can result in hard to resolve errors.

### (3) __edit the TEMPLATE. md file__

This is optional. Defines the template of markdown file and contains placeholders for different components of the change log. Do not remove the placeholders, but other adjustments can be applied. This is not an important step because that content can be adjusted anyway in the generated output.

## Using Build-PoShLog command

Before running, the user needs to eject a config (json), then modify it for the repo's
needs. There are a few pre-defined configs from which to choose, that customises the
appearance of the generated change log. Most of the options are cosmetic with a few
that define the structure.

Once a ChangeLog has been generated, the user can if they want, just use the generated output as is. However, this is not the intention behind this command. Generating output, is just the first step in creating a useful change log meaning extra curation is required of the user to ensure the items marked as Squashed for example, are cleaned up (the end user is probably not interested in whether an item is squashed or not).

  An alternative way to change the appearance of the change log is the use of emojis
which can really help in identifying items generated in the log and the nature of
that change. The user is welcome to change the emojis used by updating the options
file.

  The user also needs to decide how the grouping of commits is to be performed. This is
controlled by the _GroupBy_ setting at ___Options.Output.GroupBy___. The default is "scope/type/change/break". This
GroupBy can have any combination of these 4 values and the path doesn't even have to
have all of those values. Eg, the user could if they wanted specify just 'scope' and in this
scenario, all commits are just grouped by the scope and nothing else. Each leg of the
GroupBy path, eg 'scope' is assigned a heading type. So for the default of
"scope/type/change/break", _scope_ appears as a H3 heading, _type_ as a H4, _change_ as a
H5 and _break_ as a H6. No more than four segments can be defined and will result in
an error. It is recommended that the user tries all the defaults with/without
emojis to see which one best suits their needs and to try alternative values given
for the _GroupBy_ value to see how entries are organised.

  If the repo is a large one, the user probably doesn't want every single commit to appear
as its own entry in the commit log. This will make for a correspondingly large commit log.
It is recommended that the user specifies some exclusion criteria in the excludes regular
expressions (there are none by default).

The generated ChangeLog markdown content is created inside a subdirectory ('loopz') inside the repo's root directory. It is expected that the user would copy this file to it's publish location, probably as 'ChangeLog .md' in the repo root. Alternatively, the user can specify the _PassThru_ flag and re-direct straight to the publish path. The options file also in the 'loopz' directory should be checked into source control.

:warning: The name of a git tag is not significant when specifying a range. Rather, the date that is associated with the tag is the important entity. It would be easy to assume that tag '3.0.0' comes after a tag '2.0.0', but this is not based on the content of the tag label, it's the underlying date that matters. It just so happens, that '3.0.0' should come after '2.0.0', providing '2.0.0' was released before '2.0.0'. If a tag  contains extra info such as '3.0.0-beta', or perhaps it was defined as 'beta-3.0.0', it now becomes clear that the content of the tag label is not the important entity.

:pick: It was envisaged that the user would run the _Build-PoShLog_ command initially for the entire commit history. Refine the initial output, then check-in. Then on subsequent releases, the command can then be run just for unreleased commits (using the _Unreleased_ switch). If the repo is a large one, then it would probably be unwise to generate a build log for the entire history in 1 go; in this scenario, the user can be selective by specifying a range using _From_ and _Until_ tags.

### Build-PoShLog parameters

+ __Name__: The name of the config to use. The current list of predefined configs are 'Alpha',
  'Elizium' and 'Zen' (more may be added in future). However, the user can specify a
  custom name, in which case a custom default options file will be generated under that
  name. In this case, the user should at least review its content and adjust if so required. It should
  be noted that the name is just a logical identifier. A file name is generated from
  this logical name. As configs are repo specific, they are created inside the repo and
  should be committed into source control.

+ __From__: Is a git Tag value. Commits that come after the date associated with this tag are selected.
  If specified, overrides the From value in the options config under ___Options.Selection.Tags.From___ setting.

+ __Until__: Is a git Tag value. Commits that come before the date associated with this tag are selected.
  If specified, overrides the Until value in the options config under ___Options.Selection.Tags.Until___ setting.

+ __Unreleased__: switch to indicate the build log should only contain entries that represent commits that have not yet been released, ie changes that are coming in the next release.

+ __Eject__: switch to indicate a config should be ejected for use. A change log is not generated
  when a config is ejected as it is assumed the user needs to make adjustments to the
  ejected options config file.

+ __PassThru__: switch to indicate that the generated markdown content is to be sent through the pipeline
instead of being saved to a file.

:warning: _From/Until/Unreleased_ parameters specified on the command line override those defined in the options config. So, if _From/Until_ are specified, then the _Unreleased_ value (if present) in the options is ignored and vice-versa.

### :eject_button: Eject a config

#### Example 1

Eject 'Alpha' emojis options config into the repo under <root>/.loopz/
as "Alpha-emoji-changelog.options.json"

> Build-PoShLog -name 'Alpha' -Eject -Emoji

#### Example 2

Eject 'Zen' options config without emojis into the repo under <root>/.loopz/
as "Zen-changelog.options.json"

> Build-PoShLog -name 'Zen' -Eject

### :gift: Create a Change Log

#### Example 3

Build a change log using the pre-defined Zen config without emojis.

> Build-PoShLog -name 'Zen'

#### Example 4

Build a change log using a custom 'foo' config. If the 'foo' config does not exist
a default config is used. The user needs to update the config and re-run.

> Build-PoShLog -name 'foo'

#### Example 5

Build a change log that contains for commits in releases within a specified range.

> Build-PoShLog -name 'Zen' -From '1.0.0 -Until '3.0.0'

#### Example 6

Build a change log that contains unreleased commits only.

> Build-PoShLog -name 'Zen' -Unreleased

---

## Options Config

The options config is a json file (the json schema can be found [here](https://github.com/EliziumNet/Klassy/blob/master/Elizium.Klassy/FileList/posh-log.options.schema.json)), which needs to first be ejected and then modified to suit the needs of the repo. The following table shows the main sections of the options config:

| Options group                               | DESCRIPTION
|---------------------------------------------|---------------------------------------------------------
| [Snippet](#options.snippet)                 | Documentary information about how statements are defined
| [Selection](#options.selection)             | Selection of commits to be included in the change log
| [SourceControl](#options.sourcecontrol)     | git related information
| [Output](#options.output)                   | Controls the generation of output
| [Output Headings](#options.output.headings) | Headings statements that correspond to GroupBy definition
| [Output Lookup](#options.output.lookup)     | Allows the definition of content referenced by the lookup of a value

### Snippet <a name="options.snippet"></a>

The snippets defined are for documentary purposes only. They show which prefix character is used for a particular type of snippet. A snippet is of the form \<prefix\>{\<symbol\>}, eg a break statement would be referenced from another statement as:

> *{breakStmt}

and refers to the content defined inside of ___Options.Output.Statements.Break___

+ __Conditional__ snippet: __'?'__
+ __Literal__ snippet: __'!'__
+ __Lookup__ snippet: __'&'__
+ __NamedGroupRef__ snippet: __'^'__
+ __Statement__ snippet: __'*'__
+ __Variable__ snippet: __'+'__

#### Conditional Snippet <a name="snippet.conditional"></a>

There is a slight exception to the previously mentioned statement format for conditional statements. Conditional statements are expressed as:

> ?{var;trueStmt;elseStmt}

where the '*var*' is a variable or a regular expression's named group reference that defines the condition.

If the variable exists and is a non empty string value, then the statement *trueStmt* will be evaluated. Alternatively, if *var* is a named group reference, then if it matched and thus present, then the *trueStmt* statement is evaluated. The *elseStmt* component is optional and refers to any defined statement. If *var* is not defined and *elseStmt* is specified, the *elseStmt* will be evaluated instead. If *var* is a boolean value, then choice between which statement is evaluated depends on whether the result of it is *true* or *false*. Also note that the *trueStmt* or *elseStmt* can refer to a literal defined in ___Options.Output.Literals___; eg the *Broken* literal can be referenced just as *Broken* from either the *trueStmt* or *elseStmt* (you do not need to use the '!' literal prefix in this context).

Only statements can be conditional and a literal can't be used as a *var*. The user is free to define as many statements as they require. Usually the statement is related to the variable. Eg *break* would be used with *breakStmt* and *scope* would be used with *scopeStmt*, but this is not mandatory. The user is free to use any variable with any statement as long as the statement is defined.

See [Variable](#snippet.variable) for the full list of pre-defined variables.

#### Literal Snippet <a name="snippet.literal"></a>

Defines constant pieces of textual content.

#### Lookup Snippet <a name="snippet.lookup"></a>

Provides a mechanism for mapping a value to some other content. Each pre-defined hashtable has been allocated a special character:

| Name      | Hash reference        | Special char reference
|-----------|-----------------------|------------------------
| author    | Lookup.Authors        | &{_A}
| break     | Lookup.BreakingStatus | &{_B}
| change    | Lookup.ChangeTypes    | &{_C}
| scope     | Lookup.Scopes         | &{_S}
| type      | Lookup.Types          | &{_T}

If a value is not found in the Lookup, the then '?' entry will be used. All Lookups must have a '?' entry and is present by default.

#### NamedGroupRef Snippet <a name="snippet.namedGroupRef"></a>

All named group references defined in any of the *Include* regular expressions can be referenced. If a regular expression contains a named group reference defined as _foo_ then this can be referenced as '^{foo}'. Some named groups are universal, such as 'change', 'type', 'scope' and 'break' so they can be referenced as named group reference or by variable eg: '+{scope}'.

#### Statement Snippet <a name="snippet.statement"></a>

A statement, eg *{authorStmt}, must be defined in ___Options.Output.Statements___ so _authorStmt_ refers to ___Options.Output.Statements.Author___. Statements can contain literal content or other statements that needs to be evaluated. Statements should not be recursive either directly or transitively. Recursive definitions are detected and cause a runtime error instead of a stack overflow.

The following table shows the statements that are defined by default so that the reader can understand how they work and allow them to write their own if they wish to.

##### :books: Active Scope Statement <a name="statement.active-scope"></a>

+ *Value*: "ActiveScope": "+{scope}"

Just evaluates the `scope` variable. This was primarily designed to be referenced from the `scopeStmt` which in turn is referenced by the _Scope_ header. Since it is referenced from a header and `scope` may not be set for commits categorised by _Scope_, it (_activeScopeStmt_) needs to be accessed from a conditional statement (see [Scope Statement](#statement.scope)).

##### :books: Author Statement <a name="statement.author"></a>

+ *Value*: " by \`@+{author}\` &{_A}"

References `author` as variable, and uses the _Authors_ lookup to express who the author was for this commit alongside their defined _Author_ emoji (assuming it has been defined as an emoji). This is not referenced by default as the author is represented by the avatar by default from the [Commit Statement](#statement.commit). If the user prefers to see the emoji, then the commit statement can be modified to reference this `authorStmt`.

##### :books: Avatar Statement <a name="statement.avatar"></a>

+ *Value*: " by \`@+{author}\` +{avatar-img}"

References `author` and `avatar-img` as variables, to express who the author was for this commit alongside their avatar. Currently referenced by the [Commit Statement](#statement.commit).

##### :books: Break Statement <a name="statement.break"></a>

+ *Value*: "&{_B}"

Header entry point so it is mandatory and any statements and/or literals it references are also mandatory. Performs a lookup of the breaking state of the commit which results in the value defined in the *BreakingStatus* lookup. This lookup defines that content by default as ':radioactive: BREAKING CHANGE' or ':recycle: NON BREAKING CHANGES', but of course this can be changed by the user at will. This is currently only referenced from within a heading title.

##### :books: Breaking Statement <a name="statement.breaking"></a>

+ *Value*: "!{broken} *BREAKING CHANGE* "

`broken` is a literal defined in ___Options.Output.Literals___. This statement is used for each commit entry (see the _Commit Statement_).

##### :books: Change Statement <a name="statement.change"></a>

+ *Value*: "Change Type: &{_C}+{change}"

Header entry point so it is mandatory and any statements and/or literals it references are also mandatory. This is designed for a header, which looks up the change value in the map defined in ___Options.Output.Lookup.ChangeTypes___ which by default refers to an emoji (assuming emojis are being used) alongside the value of `change` variable.

##### :books: Commit Statement <a name="statement.commit"></a>

+ *Value*: "+ ?{is-breaking;breakingStmt}?{is-squashed;squashedStmt}?{change;changeCommitStmt}\*{subjectStmt}\*{avatarStmt}\*{metaStmt}"

This is an entry point statement so is mandatory. Any statement or literal that it references are also mandatory as a result. `breakStmt`, `squashedStmt` and `changeCommitStmt` are referenced as conditionals because we only want their content to be displayed under their respective conditions (`is-breaking`, `is-squashed` and `change` respectively).

The main commit content is defined as [`subjectStmt`](#statement.subject), [`avatarStmt`](#statement.avatar) and [`metaStmt`](#statement.meta) in the __Elizium__ options, but is slightly different in the other pre-defined options.

##### :books: Dirty Statement <a name="statement.dirty"></a>

+ *Value*: "!{dirty}"

Designed for a header of a section dedicated to `dirty` commits (it is referenced from the _Dirty_ heading defined at ___Options.Output.Headings___). Dirty commits are only included for a particular release if that release contains no commits that make it through the _Include_ regular expressions. All releases should have valid entries, so a dirty commit is allowed through to highlight that there are no 'clean' commits. The intention here is that the user's attention is drawn to this item and should manually change this output to something sensible.

##### :books: Dirty Commit Statement <a name="statement.dirtycommit"></a>

+ *Value*: "+ ?{is-breaking;breakingStmt}+{subject}"

Designed to be referenced for each dirty commit. The dirty commit is a bulleted entry that should shows the commit subject marked by its breaking status. Since in the commit entry, we only want to see the breaking status if it is a breaking change, it is referenced as a conditional statement using the _is-breaking_ variable.

##### :books: IssueLink Statement <a name="statement.issuelink"></a>

+ *Value*: " \\<\*\*+{issue-link}\*\*\\>"

Referenced from each commit to show the link to this commit, via the `issue-link` variable.

(:warning: Beware of the escaping required.)

##### :books: Meta Statement <a name="statement.meta"></a>

+ *Value*: " (Id: \*\*+{commitid-link}\*\*)?{issue-link;issueLinkStmt}"

Shows the commit link for each commit entry and the link to the issue via the issue number. Since a commit may be missing the issue number, it is referenced as a conditional.

##### :books: Scope Statement <a name="statement.scope"></a>

+ *Value*: "Scope(&{_S}?{scope;activeScopeStmt;Uncategorised})"

Header entry point so it is mandatory and any statements and/or literals it references are also mandatory. Since section headers always exist, this must always define content, which is the reason why its not referenced as a conditional. Commit entries that don't have a `scope` are displayed in a section with 'scope' displayed as _uncategorised_. The _Scopes_ lookup defined in ___Options.Output.Lookup___ should be populated with all of the scopes defined for the repo with an emoji defined for each scope. (Caveat, if not using emojis, then the _Scopes_ lookup need not be maintained.)

##### :books: Squashed Statement <a name="statement.squashed"></a>

+ *Value*: "SQUASHED: "

The squashed content is designed to just be a marker to draw the user's attention to this entry so its entry can be modified. Since there are multiple commits with the same squash criteria (usually and by default the issue number), the item that makes it into the output (either the first or last depending on ___Options.Selection.Last___) may not contain the best commit message and thus should be modified. If squashed items should not be highlighted, simply remove the `squashedStmt` from the commit statement.

##### :books: Subject Statement <a name="statement.subject"></a>

+ *Value*: "\*\*+{body}\*\*"

The `subjectStmt` in this case simply references `body` as a variable reference. It is a named group reference as well as being a variable so it could be referenced as '^{body}'.

##### :books: Type Statement <a name="statement.type"></a>

+ *Value*: "Commit-Type(&{_T}+{type})"

Header entry point so it is mandatory and any statements and/or literals it references are also mandatory.
The `type` named group reference which is also available as a variable is displayed with the content defined in the Change Types lookup defined in ___Options.Output.Lookup___, which by default is an emoji (assuming emojis are in use).

##### :books: Ungrouped Statement <a name="statement.ungrouped"></a>

+ *Value*: "UNGROUPED"

Header entry point so it is mandatory and any statements and/or literals it references are also mandatory.
The `ungrouped` header is used for the scenario where the _GroupBy_ is set to the empty string. Commit entries are not categorised in this case and all appear under this header.

#### Variable Snippet <a name="snippet.variable"></a>

Variables can be populated by named group references or from other properties on the commit. The following table shows the full list of variables that can be retrieved:

| Variable          | Source            | Info
|-------------------|-------------------|-----
| author            | commit            |
| author-img        | author            | The html fragment showing the author's avatar
| date              | commit            | String representation (defined by ___Options.Output.Literals.DateFormat___) of the commit's date
| display-tag       | commit            | re-maps 'HEAD' to 'Unreleased'
| is-breaking       | commit            | $true or $false depending on the breaking status of the commit
| is-squashed       | commit            | boolean value set to true if there ar multiple commits with the same squash criteria, usually same issue number
| subject           | commit            | The commit's header message
| tag               | commit            | The original tag
| commitid          | commit            |
| commitid-link     | commit            | The html fragment linking to the commit
| break             | named group ref   | set to 'breaking' or 'non-breaking' depending on the breaking status of the commit
| issue             | named group ref   | The issue number of the commit
| issue-link        | named group ref   | The html fragment linking to the issue
| change            | named group ref   | The change type as defined in the lookup (___Options.Output.LookUp.ChangeTypes___)
| scope             | named group ref   | The scope as defined in the lookup (___Options.Output.LookUp.Scopes___)
| type              | named group ref   | The commit type as defined in the lookup (___Options.Output.LookUp.Types___)
| active-leg        | GroupBy           | Designed to be referenced from a header statement (See :heavy_exclamation_mark: below)
| active-segment    | groupBy           | Designed to be referenced from a header statement (See :heavy_exclamation_mark: below)

:heavy_exclamation_mark: Since each heading can reference any of the predefined segments ('scope'/'type'/'change-type'/'break') as defined by the _GroupBy_ value, it is not known in advance what they contain. Using _active-segment_ and _active-leg_ let's us access these items without actually explicitly knowing that the current header for example refers to 'type' (_active-segment_)  which is set to 'feat' (_active-leg_).

### Selection <a name="options.selection"></a>

Settings which control selection of commits from git.

+ __Order__: This is documentary only. Good change logs list changes and releases in descending order.
+ __SquashBy__: Squashes commits by the defined regular expression. The default value defines an 'issue' named capture group, so that any commits with the same issue number are represented by a single entry in the commit log.
+ __Tags__: Can contain *From* and *Until* (both of which are optional). These represent tags in the repo. If *From* is present, then only commits that come after the date linked to this tag are selected. If *Until* is present, then commits up to and including the associated tag date are included.
+ __Last__: When commits are squashed, only 1 of the commits with the same squash criteria is present in th change log. When `last` is set to true, then the last commit in the squash group is selected, otherwise the first is.
+ __IncludeMissingIssue__: When set to true, commits than do not contain an issue number are included, otherwise they are omitted. This of course depends on how the _Include_ regular expressions are defined. If the regular expression defines the issue to be mandatory, then this setting has no effect.
+ __Subject__: Contains the definitions for the _Include_ and _Exclude_ regular expressions.

#### 'Include' Regular Expressions

By default there are regular expressions defined to accepts commit subjects of the form:

+ 1) feat(foo)!: Add new bar (#42)
+ 2) feat(foo)!: #42 Add new bar
+ 3) (feat #42)!: Add new bar

If a repo's commits are already in a uniform state, it is advised to remove the second 2 patterns, which are really only there to remediate poor commit histories.

### SourceControl <a name="options.sourcecontrol"></a>

+ __AvatarSize__: if '&{_GA}' is used in a statement, the avatar associated with the commit author is referenced. The size controls which size avatar is retrieved.
+ __CommitIdSize__: can be any value between 7 and 40 and specifies the size of the leading portion of the commit id.

### Output <a name="options.output"></a>

+ __GroupBy__<a name="options.output.groupby"></a>: controls how commits are categorised. Can be any unique combination of 'scope', 'type', 'change' and 'break'. The GroupBy path must correspond to the heading values H3-H6 defined in settings ___Output.Headings.H?___. Those headings must all contain a placeholder '*{$}'. The user is free to add content to these headings, but they must all contain the placeholder. Internally, the placeholder is replaced with whatever _GroupBy_ leg it corresponds to, so for example, if the first leg of the _GroupBy_ is set to `scope`, then the placeholder inside the H3 heading is replaced with '\*{scopeStmt}'.

  + `scope` values are defined in ___Options.Output.Lookup.Scopes___ setting
  + `type` values are defined in ___Options.Output.Lookup.Types___ setting
  + `change` values are defined in ___Options.Output.Lookup.ChangeTypes___ setting (if change isn't
  represented inside the regex as a named group capture, it is taken to being the first
  word of the commit message after the ':' if that also matches the pre-defined change types
  defined in "ChangeTypes").
  + `break` is set according to the breaking status of the commit, defined by the commit's subject containing the breaking marker: "!" after the scope (see the default include regex for an exact specification).
  These translate to "breaking" or "non-breaking" under ___Options.Output.Lookup.Breaking___.

  Any commit which doesn't match these categorisations is marked as "uncategorised".
  This GroupBy value is injected into the ejected options config under ___Options.Output___.

#### Output.Lookup :mag_right:<a name="options.output.lookup"></a>

Provides a mechanism where generated content can be selected depending on the result of performing a lookup in a hashtable instance. A lookup is referenced from a statement using the pre-defined prefix character '&' (as defined in [Lookup](#snippet.lookup)). There are 5 hashtables defined in the options which are described in the following sub-sections.

The user is also able to define *isa* relationships inside the Lookups: `ChangeTypes`, `Scopes` and `Types`. Taking `ChangeTypes` as an example; a repo may have accidentally defined different but  semantically identical scopes. For example, 'Update' and 'Change' may have been defined which mean the same thing so they should be treated the same and all commits with either of these should be grouped together. Assuming we would like 'Change' to be treated the same as 'Update', inside the `ChangeTypes` lookup, the user is able to establish this relationship with an 'isa', so inside ___Options.Output.Lookup.ChangeTypes___:

```json
  "Update": ":o:",
  "Change": "isa:Update"
```

All 'Change' commits will be categorised as 'Update'.

These `isa` relationships can also be defined for `Types` and `Scopes`.

This also means that the user can redefine how lookup items are displayed. If for example the user wants to simply re-map 'Types' to more verbose and more user friendly values, then this can be done. Eg, if instead of seeing the _Type_ 'perf', it can be redefined to 'Performance Improvement'. This would be achieved by defining 'Performance Improvement' as a type, then then modifying 'perf' to be 'isa:Performance Improvement'.

##### Authors

:mag:: **'&{_A}'**

The *Authors* lookup allows an emoji to be assigned to each contributor in a repo. The author associated with the commit is looked up in the *Authors* lookup to retrieve its contents (which may or may not be an emoji). The `authorStmt` can be configured to contain a reference to the author lookup, eg:

> " by \`@+{author}\` &{_A}"

However, by default, the `authorStmt` is configured to use the author's avatar:

> " by \`@+{author}\` +{avatar-img}"

When using the avatar instead of the *Authors* lookup, the users do no need to be populated.

##### BreakingStatus

:mag:: **'&{_B}'**

This is primarily used by the `breakStmt` defined as `Break` in ___Options.Output.Statements___ to display the break category in a section header. The value of the `break` variable can either be _'breaking'_ or _'non breaking'_ and this is used as the index into the *BreakingStatus* lookup.

##### ChangeTypes

:mag:: **'&{_C}'**

The first word after the ':' in a commit message is taken to be a change type, so its important for commits to adhere to this so that the change type can be detected. The default change types defined in ___Options.Lookup.ChangeTypes___ are the standard ones as defined by [Keep A Change Log](https://keepachangelog.com) but they can be augmented/adjusted by the user as they see fit.

Eg to reference the change type, it can be retrieved as a variable:

> +{change}

##### Scopes

:mag:: **'&{_S}'**

The *Scopes* lookup must be configured by the user as it is repo specific and hence no sensible defaults can be applied. When using emojis, this lookup will be defined by allocating a specific emoji to each identified scope. However, if emojis are not enabled, there is no need to define the valid scope list. Commits will still be categorised by the scope value, but will look less pretty!

Eg to reference the scope, it can be retrieved as a variable:

> +{scope}

##### Types

:mag:: **'&{_T}'**

The valid type list is defined by *Keep A Change Log*, but can be augmented by the user if so required.

Eg to reference the type, it can be retrieved as a variable:

> +{type}

#### Literals

Defines static content that can be referenced by a statement or is used internally.

Eg to reference a literal value defined as 'body' in ___Options.Output.Literals.Body___:

> !{body}

#### Statements

Custom statements can be created by the user. The statements defined in ___Options.Output.Statements___ can be referenced by attaching 'Stmt' to that name. eg:

> Options.Output.Statements.Break

can be referenced in another statement as:

> '*{breakStmt}'

Statements can be referenced as condition snippets (as previously described in [Conditional Snippet](#snippet.conditional)). Statements can contain embedded static content, reference variables, regular expression named groups, literals and variable lookups. eg:

> 'Subject: \*\*+{subject}\*\*'

---

## :checkered_flag: Summary

It would be tempting to think that a user could just generate a change log directly from the commits using this change log command. However, it's not advised to do this. _Build-PoShLog_ is just the first step and the primary motivation for the creation of this command was to help a user generate a change log for a repo that does not have a great commit history. I am even willing to admit that ___Loopz___ falls into this category mainly because of not realising the importance of good commit etiquette at the start of the project (and others). The value in using this command is that it provides a structure based upon the meta data of the commit history with the ability to decorate with emojis.

---

Go forth and commitify beautifully.

## References

:dart: [Keep A Change Log](https://keepachangelog.com/)<br>
:dart: [Conventional Commits](https://www.conventionalcommits.org)<br>
:dart: [Commitizen](https://commitizen-tools.github.io)<br>
:dart: [Writing Meaningful Git Commit Messages](https://medium.com/@menuka/writing-meaningful-git-commit-messages-a62756b65c81)<br>
:dart: [Master your git log with Conventional Commits in 6 steps](https://dev.to/angry_nerds/master-your-git-log-with-conventional-commits-in-6-steps-32kp)<br>
