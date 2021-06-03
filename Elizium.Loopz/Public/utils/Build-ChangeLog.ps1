
function Build-ChangeLog {
  <#
  .NAME
    Build-ChangeLog

  .SYNOPSIS
    Create a change log for the current repo

  .DESCRIPTION
    Before running, the user needs to eject a config (json), then modify it for the repo's
  needs. There are a few pre-defined configs from which to choose, that customises the
  appearance of the generated change log. Most of the options are cosmetic with a few
  that define the structure. Also, the user can keep the default regular expressions (which
  conform to keep-a-changelog). One of the properties of a good change log are that
  commits should be grouped together based upon change type/scope/commit-type/breaking
   changes. This change log implementation performs groupings based on all of these
  categories. The quality of the generated changelog depends heavily on the quality of
  the commit messages in the repo.
    However, one of the reasons for this implementation is in recognition of the fact that
  a repo may not have commits with messages that are in accordance with keep-a-changelog.
  If a repo's commits can be easily represented by alternative regular expression(s),
  then the user can update the options file with these additional patterns. More than 1
  pattern can be specified, but the more restrictive patterns should be specified first.
    Also, a repo can have many un-squashed commits, which is generally not advised, but
  again, in recognition of this state of a repo, there is a squash facility built into
  the change log. That is not to say that the commits in the repo are squashed, rather
  they are squashed just in the change log by a provided regular expression. In the options
  config, there is a "SquashBy" setting under "Selection" and the default specifies an
  "issue" number so that commits with the same issue number are grouped into a single entry
  in the change log. By default, these squashed entries are marked out so they are easily
  identified by the user and can be changed accordingly.
    The user can if they want, just use the generated output as is. However, this is not
  the intention behind this command. Generating output, is just the first step in creating
  a useful change log meaning extra curation is required of the user to ensure the items
  marked as Squashed for example, are cleaned up (the end user is probably not interested
  in whether an item is squashed or not).
    An alternative way to change the appearance of the change log is the use of emojis 
  which can really help in identifying items generated in the log and the nature of
  that change. The user is welcome to change the emojis used by updating the options
  file.
    The user also needs to decide how the grouping of commits is to be performed. This is
  controlled by the "GroupBy" setting. The default is "scope/type/change/break". This
  GroupBy can have any combination of these 4 values and the path doesn't even have to
  have all of those values. Eg, the user could if they wanted specify just 'scope' and in this
  scenario, all commits are just grouped by the scope and nothing else. Each leg of the
  GroupBy path, eg 'scope' is assigned a heading type. So for the default of
  "scope/type/change/break", scope appears as a H3 heading, type as a H4, change as a
  H5 and break as a H6. No more than four segments can be defined and will result in
  an error. It is recommended that the user tries all the defaults with/without
  emojis to see which one best suits their needs and to try alternative values given
  for the "GroupBy" value to see how entries are organised.
    If the repo is a large one, the user probably doesn't want every single commit to appear
  as its own entry in the commit log. This will make for a correspondingly large commit log.
  It is recommended that the user specifies some exclusion criteria in the excludes regular
  expressions (there are none by default).
    To see a detailed explanation of the options config, the user should consult
  [Build ChangeLog](Elizium.Loopz/docs/build-changelog.md).

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Name
    The name of the config to use. The current list of predefined configs are 'Alpha',
  'Elizium' and 'Zen' (more may be added in future). However, the user can specify a
  custom name, in which case a custom default options file will be generated under that
  name. In this case, the user MUST update its contents as it is not complete. It should
  be noted that the name is just a logical identifier. A file name is generated from
  this logical name. As configs are repo specific, they are created inside the repo and
  should be committed into source control.

  .PARAMETER From
    Is a Tag value. Commits that come after the date associated with this tag are selected.
  If specified, overrides the From value in the options config under "Tags.From" setting.

  .PARAMETER Until
    Is a Tag value. Commits that come before the date associated with this tag are selected.
  If specified, overrides the Until value in the options config under "Tags.Until" setting.

  .PARAMETER Unreleased
    switch to indicate the build log should only contain entries that represent commits
  that have not yet been released, ie changes that are coming in the next release.

  .PARAMETER Eject
    switch to indicate a config should be ejected for use. A change log is not generated
  when a config is ejected as it is assumed the user needs to make adjustments to the
  ejected options config file.

  .PARAMETER PassThru
    switch to indicate that the generated markdown content is to be sent through the pipeline
  instead of being saved to a file.

  .PARAMETER Emoji
    switch to control whether an emoji based config is ejected. When generating a change
  log, indicates that the emoji version of the config should be used.

  .EXAMPLE 1

  Build-ChangeLog -name 'Alpha' -Eject -Emoji

  Eject 'Alpha' emojis options config into the repo under <root>/loopz/
  as "Alpha-emoji-changelog.options.json"

  .EXAMPLE 2

  Build-ChangeLog -name 'Zen' -Eject

  Eject 'Zen' options config without emojis into the repo under <root>/loopz/
  as "Zen-changelog.options.json"

  .EXAMPLE 3

  Build-ChangeLog -name 'Zen' -Eject -GroupBy 'scope/type'

  Eject 'Zen' options config without emojis into the repo under <root>/loopz/
  as "Zen-changelog.options.json" using a custom GroupBy setting.

  .EXAMPLE 4

  Build-ChangeLog -name 'Zen'

  Build a change log using the pre-defined Zen config without emojis.

  .EXAMPLE 5

  Build-ChangeLog -name 'foo'

  Build a change log using a custom 'foo' config. If the 'foo' config does not exist
  a default config is used. The user needs to update the config and re-run.

  .Example 6

  Build-ChangeLog -name 'Zen' -From '1.0.0 -Until '3.0.0'

  Build a change log that contains for commits in releases within a specified range.

  .Example 7

  Build-ChangeLog -name 'Zen' -Unreleased

  Build a change log that contains unreleased commits only.
  #>
  [CmdletBinding(DefaultParameterSetName = 'CreateLog')]
  [Alias('chog')]
  param(
    [Parameter(Position = 1)]
    [Alias('n')]
    [string]$Name = 'Alpha',

    [Parameter(ParameterSetName = 'CreateLog', Position = 2)]
    [Alias('f')]
    [string]$From,

    [Parameter(ParameterSetName = 'CreateLog', Position = 3)]
    [Alias('u')]
    [string]$Until,

    [Parameter(ParameterSetName = 'CreateLogUnreleased')]
    [Alias('ur')]
    [switch]$Unreleased,

    [Parameter(ParameterSetName = 'CreateLog')]
    [Alias('p')]
    [switch]$PassThru,

    [Parameter(ParameterSetName = 'EjectConfig', Mandatory)]
    [Alias('j')]
    [switch]$Eject,
    
    [Parameter()]
    [Alias('e')]
    [switch]$Emoji,

    [Parameter()]
    [switch]$Test
  )
  [PSCustomObject]$optionsInfo = [PSCustomObject]@{
    PSTypeName    = 'Loopz.ChangeLog.OptionsInfo';
    #
    Base          = '-changelog.options';
    DirectoryName = [ChangeLogSchema]::DIRECTORY;
  }
  if ($Test.IsPresent) {
    [string]$rootPath = $($env:PesterTestDrive ?? $env:temp);
    $optionsInfo | Add-Member -NotePropertyName 'Root' -NotePropertyValue $rootPath;
  }

  [ChangeLogOptionsManager]$manager = New-ChangeLogOptionsManager -OptionsInfo $optionsInfo;
  [Scribbler]$scribbler = New-Scribbler -Test:$Test.IsPresent;

  [hashtable]$signals = $(Get-Signals);    
  [string]$chogSignal = Get-FormattedSignal -Name 'CHOG' -EmojiOnly -Signals $signals -EmojiOnlyFormat '{0}';
  [string]$ejectSignal = Get-FormattedSignal -Name 'EJECT' -EmojiOnly -Signals $signals -EmojiOnlyFormat '{0}';

  [string]$lnSn = $scribbler.Snippets('Ln');
  [string]$resetSn = $scribbler.Snippets('Reset');
  [string]$actionSn = $($resetSn + $scribbler.Snippets('blue'));
  [string]$nameSn = $scribbler.Snippets('red');
  [string]$pathSn = $scribbler.Snippets('cyan');
  [string]$requestSn = $($resetSn + $scribbler.Snippets('green'));
  [string]$quoteSn = $($resetSn + $scribbler.Snippets('yellow'));

  [string]$nameFragment = $(
    "$($quoteSn)'$($nameSn)$($name)$($quoteSn)'"
  );

  [string]$pathFragment = $(
    "$($quoteSn)'$($pathSn)$($manager.FullPath($name, $Emoji.IsPresent))$($quoteSn)'"
  );

  if (@('CreateLog', 'CreateLogUnreleased') -contains $PSCmdlet.ParameterSetName) {
    [PSCustomObject]$options = $manager.FindOptions($Name, $Emoji.IsPresent);

    if ($manager.Found) {
      # specified parameters always override config
      #
      if ($Unreleased.IsPresent) {
        $options.Selection.Tags | Add-Member -NotePropertyName 'Unreleased' -NotePropertyValue $true -Force;

        if (($options.Selection.Tags)?.From) {
          $options.psobject.properties.remove('From');
        }

        if (($options.Selection.Tags)?.Until) {
          $options.psobject.properties.remove('Until');
        }
      }
      else {
        if ($PSBoundParameters.ContainsKey('From')) {
          $options.Selection.Tags | Add-Member -NotePropertyName 'From' -NotePropertyValue $from -Force;

          if (($options.Selection.Tags)?.Unreleased) {
            $options.psobject.properties.remove('Unreleased');
          }
        }

        if ($PSBoundParameters.ContainsKey('Until')) {
          $options.Selection.Tags | Add-Member -NotePropertyName 'Until' -NotePropertyValue $until -Force;

          if (($options.Selection.Tags)?.Unreleased) {
            $options.psobject.properties.remove('Unreleased');
          }
        }
      }
      [ChangeLog]$changeLog = New-ChangeLog -Options $options;

      [string]$content = $changeLog.Build();
      [string]$base = $options.Output.Base;
      [string]$outputFile = $(
        $base + '-' + $Name + $($Emoji.IsPresent ? '-emoji' : [string]::Empty) + '.md'
      );

      if ($PassThru.IsPresent) {
        $content;
      }
      else {
        [string]$fullPath = $manager.DirectoryPath($outputFile);
        $changeLog.Save($content, $fullPath);
      }
    }
    else {
      [string]$action = $(
        "$($chogSignal) $($actionSn)Created new options config for " +
        "$($nameFragment)$($actionSn) at $($pathFragment)" +
        "$($Emoji.IsPresent ? "$($actionSn), with emojis" : [string]::Empty).$($lnSn)"
      );
      $scribbler.Scribble($action);

      [string]$request = $(
        "$($requestSn)--> Please review the options and re-run.$($lnSn)"
      );      
      $scribbler.Scribble($request);
    }
  }
  elseif ($PSCmdlet.ParameterSetName -eq 'EjectConfig') {
    [PSCustomObject]$options = $manager.Eject($Name, $Emoji.IsPresent);

    [string]$action = $(
      "$($chogSignal) $($actionSn)Ejected $($ejectSignal)" +
      "$($nameFragment)$($actionSn) options config to $($pathFragment)$($actionSn).$($lnSn)"
    );
    $scribbler.Scribble($action);

    [string]$request = $(
      "$($requestSn)--> Please update options (Scopes/Tags)" +
      " for $($nameFragment)$($requestSn).$($lnSn)"
    );
    $scribbler.Scribble($request);
  }

  $scribbler.Flush();
}
