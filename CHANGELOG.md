# :scroll: Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
<!-- MarkDownLint-disable MD013 -->
<!-- MarkDownLint-disable MD024 -->
<!-- MarkDownLint-disable MD026 -->
<!-- MarkDownLint-disable MD033 -->

## Release [Unreleased] / 2021-07-02

:sparkles: HIGHLIGHTS

+ TBD ...

### Scope(:star:poshlog)

#### Commit Type(:nut_and_bolt:chore)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Remove, since it is now in a separate module** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[b674f40](https://github.com/EliziumNet/Loopz/commit/b674f406b91ec676ee873242aa1333d9529c26c8)**) \<**[#155](https://github.com/EliziumNet/Loopz/issues/155)**\>

---

### Scope(:star:poshlog)

#### Commit Type(:gift:feat)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Add new Build-ChangeLog command** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[7f15e08](https://github.com/EliziumNet/Loopz/commit/7f15e08cdc3aea0678c6bb6b642fc7ca9a3f08ca)**) \<**[#149](https://github.com/EliziumNet/Loopz/issues/149)**\>

---

### Scope(:star:poshlog)

#### Commit Type(:hotsprings:style)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **change by renaming ChangeLog to PoShLog** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[9b2635c](https://github.com/EliziumNet/Loopz/commit/9b2635c1735fb4129698be08cbe544b08b2adbdf)**) \<**[#154](https://github.com/EliziumNet/Loopz/issues/154)**\>

---

### Scope(:postbox:pstools)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **change Show-InvokeReport to show command name** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[73bbc5f](https://github.com/EliziumNet/Loopz/commit/73bbc5ffc74bb2d2c6b022be2a5c15e1661e38c3)**) \<**[#159](https://github.com/EliziumNet/Loopz/issues/159)**\>

---

### Scope(:fireworks:signals)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Change Register-CommandSignals by showing warning if command already regsitered** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[d41cbcf](https://github.com/EliziumNet/Loopz/commit/d41cbcfe03f2cffe5f167d68480dacdcd7fb5e93)**) \<**[#158](https://github.com/EliziumNet/Loopz/issues/158)**\>

---

## Release [3.0.2] / 2021-04-19

:sparkles: HIGHLIGHTS

+ Change default emoji handling for Linux and Mac.

### Scope(:fireworks:signals)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Change Test-HostSupportsEmojis to return false for mac & linux** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[23e25cb](https://github.com/EliziumNet/Loopz/commit/23e25cbff58be51c173bb807f49fed78ad289cdf)**) \<**[#151](https://github.com/EliziumNet/Loopz/issues/151)**\>

---

## Release [3.0.1] / 2021-04-19

:sparkles: HIGHLIGHTS

+ Improved parameter set tools usability as a result from feedback from 3rd party (thanks `@mklement0` :thumbsup:)

### Scope(:lock:uncategorised)

#### Commit Type(:clipboard:docs)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Add Examples and Links** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[3ef641a](https://github.com/EliziumNet/Loopz/commit/3ef641ab485d5ce5ddb386f04fe84d2934b40091)**) \<**[#144](https://github.com/EliziumNet/Loopz/issues/144)**\>

---

### Scope(:postbox:pstools)

#### Commit Type(:nut_and_bolt:chore)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **get-CommandDetail is now an internal function** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[2830935](https://github.com/EliziumNet/Loopz/commit/283093511fb2f67b4026e6b319b87acf5b2eac49)**) \<**[#147](https://github.com/EliziumNet/Loopz/issues/147)**\>

---

### Scope(:postbox:pstools)

#### Commit Type(:gift:feat)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Allow command to be invoked with the Name parameter instead of using pipeline** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[dc800c6](https://github.com/EliziumNet/Loopz/commit/dc800c68e4aaa6be692c8254490945ad73f69e6d)**) \<**[#145](https://github.com/EliziumNet/Loopz/issues/145)**\>

---

## Release [3.0.0] / 2021-04-15

:sparkles: HIGHLIGHTS

+ Introducing :sparkling_heart: parameter set tools: ___Show-InvokeReport___, ___Show-ParameterSetInfo___ and ___Show-ParameterSetReport___
+ Integrate with *Krayola's* new ___Scribbler___ class
+ Refactor *Rename-Many* parameter sets
+ Added command bootstrap facility
+ Added *Drop* facility to *Rename-Many*
+ Added new coloured table functionality
+ Change signature of *Rename-Many*'s *Transform* script-block to accommodate the *Exchange*

### Scope(:lock:uncategorised)

#### Commit Type(:clipboard:docs)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Create new inline function documentation for platyPS** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[ce67b97](https://github.com/EliziumNet/Loopz/commit/ce67b97b6ceaff8d63014e8f598466e12ebba461)**) \<**[#127](https://github.com/EliziumNet/Loopz/issues/127)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:gift:feat)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Add Common param to parameter set functions to show Common params in reports** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[16d6941](https://github.com/EliziumNet/Loopz/commit/16d69417db952c2c9b8901424e083fa7f0e413e3)**) \<**[#123](https://github.com/EliziumNet/Loopz/issues/123)**\>
+ **Ensure hashtable property access performed via PSBase** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[e7a3448](https://github.com/EliziumNet/Loopz/commit/e7a34482bfe4d807c54b92dc2c380201c91de4ed)**) \<**[#118](https://github.com/EliziumNet/Loopz/issues/118)**\>
+ **Use Krayola's Scribbler instead of a StringBuilder directly** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[f8e9b3c](https://github.com/EliziumNet/Loopz/commit/f8e9b3caf807aecfea2a7f7904e80d162aa7f2f9)**) \<**[#116](https://github.com/EliziumNet/Loopz/issues/116)**\>
+ **Use Emojis depending on Host** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[96db406](https://github.com/EliziumNet/Loopz/commit/96db4066e374da5c165af595675d9aa2e13a8f99)**) \<**[#115](https://github.com/EliziumNet/Loopz/issues/115)**\>
+ **Create initial prototype version of functions to display coloured parameter sets as tables** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[965a2d1](https://github.com/EliziumNet/Loopz/commit/965a2d18efcc605acda51624b1ac1449b0ac9fe4)**) \<**[#114](https://github.com/EliziumNet/Loopz/issues/114)**\>
+ **Enable named group references inside Drop parameter** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[ddfce73](https://github.com/EliziumNet/Loopz/commit/ddfce7389a2fa8e547bad997eb850ef2912317b4)**) \<**[#110](https://github.com/EliziumNet/Loopz/issues/110)**\>
+ **Change the signature of the Transform scriptblock to include the exchange** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[fd9209c](https://github.com/EliziumNet/Loopz/commit/fd9209c309ace64467a80eedc46d45362627f708)**) \<**[#136](https://github.com/EliziumNet/Loopz/issues/136)**\>
+ **Fix problem of error occuring due to accessing Count property on hashtable (not IComparable)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[30ceca3](https://github.com/EliziumNet/Loopz/commit/30ceca3a1814ebed5395860f358b292ba4d7fcc4)**) \<**[#144](https://github.com/EliziumNet/Loopz/issues/144)**\>
+ **Rename-Many; Implement Hybrid Anchor** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[c441432](https://github.com/EliziumNet/Loopz/commit/c441432f4198837df6592d31102daeba2c75695f)**) \<**[#100](https://github.com/EliziumNet/Loopz/issues/100)**\>
+ **Rename-Many; Add ability to prepend or append a string** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[d85d543](https://github.com/EliziumNet/Loopz/commit/d85d5439ac256b94dd72f24f01650847fa3ddb4e)**) \<**[#111](https://github.com/EliziumNet/Loopz/issues/111)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Update anchor named group references** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[7204c7a](https://github.com/EliziumNet/Loopz/commit/7204c7a78714071ad62e15be8f4629f50be53483)**) \<**[#137](https://github.com/EliziumNet/Loopz/issues/137)**\>
+ **remy; Replace Anchored regex with Test-IsAlreadyAnchoredAt for -Start -End, to fix item skipping** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[e9ed8de](https://github.com/EliziumNet/Loopz/commit/e9ed8debed45f42df3743f6016d68866180cde9b)**) \<**[#140](https://github.com/EliziumNet/Loopz/issues/140)**\>
+ **Show-InvokeReport; add Strict param** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[2662d68](https://github.com/EliziumNet/Loopz/commit/2662d68af69342efd5b7ef47a6b50c3c8e4fb182)**) \<**[#132](https://github.com/EliziumNet/Loopz/issues/132)**\>
+ **avoid Get-PsObjectField for boolean fields** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[a7a3e74](https://github.com/EliziumNet/Loopz/commit/a7a3e74fd6f38f878eedbdb80d53a9de70de604e)**) \<**[#113](https://github.com/EliziumNet/Loopz/issues/113)**\>
+ **Rename-Many; apply new MissingCapture rule to remove un-resolved named capture ref** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[73e3ec6](https://github.com/EliziumNet/Loopz/commit/73e3ec6688f90297ea5db8c14dfdb392013583eb)**) \<**[#129](https://github.com/EliziumNet/Loopz/issues/129)**\>
+ **Rename-Many; use get_ getter fns to access RegexEntity.Regex member** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[014eaa8](https://github.com/EliziumNet/Loopz/commit/014eaa866ec573c2f836528ed9e870d4a1ba1604)**) \<**[#128](https://github.com/EliziumNet/Loopz/issues/128)**\>
+ **Add Trigger count to Summary** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[b0c9174](https://github.com/EliziumNet/Loopz/commit/b0c917486bc71056622d22bc763abcf7687db4d5)**) \<**[#64](https://github.com/EliziumNet/Loopz/issues/64)**\>
+ **Ensure the mandatory switch parameter query is correct in Syntax.SyntaxStmt** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[16a99b6](https://github.com/EliziumNet/Loopz/commit/16a99b68d5e11ecd037ffb5d6680b43acf6e95af)**) \<**[#122](https://github.com/EliziumNet/Loopz/issues/122)**\>
+ **Rename-Many; Change Cut param to be of type array to accommodate Occurrence** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[38c6c67](https://github.com/EliziumNet/Loopz/commit/38c6c67a79b59c9a5f7523509af645fb94cb8faf)**) \<**[#135](https://github.com/EliziumNet/Loopz/issues/135)**\>
+ **Rename-Many; Add 'Because' as a failure reason when item not renamed** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[b26ea02](https://github.com/EliziumNet/Loopz/commit/b26ea02b2e1e35c3e0a813eca2211e94b1b63d76)**) \<**[#139](https://github.com/EliziumNet/Loopz/issues/139)**\>
+ **Remove With from Update-Match** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[f194a6c](https://github.com/EliziumNet/Loopz/commit/f194a6c3ca5d6074ba68cab00bddae2504aa3bb7)**) \<**[#141](https://github.com/EliziumNet/Loopz/issues/141)**\>
+ **Fix find-InAllParameterSetsByAccident** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[6646802](https://github.com/EliziumNet/Loopz/commit/664680256f77dcd9269459046c8ccaed97a261cb)**) \<**[#131](https://github.com/EliziumNet/Loopz/issues/131)**\>
+ **Add Grapheme Length to Signals table. (Issue not fixed)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[d1b3d0e](https://github.com/EliziumNet/Loopz/commit/d1b3d0e630e688ca0567b228c41c8a7d9c84ecd4)**) \<**[#138](https://github.com/EliziumNet/Loopz/issues/138)**\>
+ **Move-Match(remy); Add Drop to HybridStart and HybridEnd parameter sets** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[c333a4f](https://github.com/EliziumNet/Loopz/commit/c333a4f7c0ff13099e5132be2480a020d0ba3dfe)**) \<**[#133](https://github.com/EliziumNet/Loopz/issues/133)**\>
+ **Rename-Many; report error in output** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[e2d1b34](https://github.com/EliziumNet/Loopz/commit/e2d1b34d21d934864c7247e55429f6d0c824e3e0)**) \<**[#130](https://github.com/EliziumNet/Loopz/issues/130)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:gem:ref)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Redefine Rename-Many parameter sets** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[5009d86](https://github.com/EliziumNet/Loopz/commit/5009d86806472da57a7cb7834880aaace5787315)**) \<**[#120](https://github.com/EliziumNet/Loopz/issues/120)**\>
+ **Use Line/NakedLine on Scribbler** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[6ee4576](https://github.com/EliziumNet/Loopz/commit/6ee45762e26de1ea39e1d8208cca444e91817019)**) \<**[#125](https://github.com/EliziumNet/Loopz/issues/125)**\>
+ **Rename-Many; Add bootstrap; (not yet integrated)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[deef52e](https://github.com/EliziumNet/Loopz/commit/deef52efda6a967911db3b61681f22b5f44eb170)**) \<**[#112](https://github.com/EliziumNet/Loopz/issues/112)**\>
+ **optimise array/hashtable/list usage** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[a277470](https://github.com/EliziumNet/Loopz/commit/a277470fd227eeae571053238b8a84292cc9c7cd)**) \<**[#117](https://github.com/EliziumNet/Loopz/issues/117)**\>

---

## Release [2.0.0] / 2021-01-18

:sparkles: HIGHLIGHTS

+ Introducing :sparkling_heart: the new bulk file renamer: ___Rename-Many___
+ Introducing :sparkling_heart: the new ___greps___ command (*Select-Text*)
+ Added new platform functions ___Invoke-ByPlatform___ and ___Resolve-ByPlatform___
+ The *PassThru* parameter has been renamed to *Exchange*, since *PassThru* is a like a reserved parameter name which has a specific meaning in PowerShell and should not have been accidentally repurposed.

### Scope(:lock:uncategorised)

#### Commit Type(:nut_and_bolt:chore)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Resync build script changes from other repos** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[8f2350f](https://github.com/EliziumNet/Loopz/commit/8f2350f160de276ea45dc668da1a1065d7fa3c25)**) \<**[#105](https://github.com/EliziumNet/Loopz/issues/105)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:clipboard:docs)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Add initial ps code documenation** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[b90d576](https://github.com/EliziumNet/Loopz/commit/b90d57690e7a911c8a11833f260d3f7508846def)**) \<**[#89](https://github.com/EliziumNet/Loopz/issues/89)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:gift:feat)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Add greps/Select-Text command** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[2bb323a](https://github.com/EliziumNet/Loopz/commit/2bb323a5cfd2bd2b4204cb991f9c6c71c928b1f3)**) \<**[#80](https://github.com/EliziumNet/Loopz/issues/80)**\>
+ **Add transform parameter** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[fbbd17c](https://github.com/EliziumNet/Loopz/commit/fbbd17c776519a4c3c2355771232d027578427c9)**) \<**[#104](https://github.com/EliziumNet/Loopz/issues/104)**\>
+ **Rename-many; perform mandatory post processing actions** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[6588620](https://github.com/EliziumNet/Loopz/commit/6588620e9cc8e02a20554f7306c082d0734c000f)**) \<**[#66](https://github.com/EliziumNet/Loopz/issues/66)**\>
+ **define default in Resolve-ByPlatform in Hash entry instead of a Default parameter** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0e32838](https://github.com/EliziumNet/Loopz/commit/0e328381440eb4e01c9461ddff96566ff06c8bbd)**) \<**[#59](https://github.com/EliziumNet/Loopz/issues/59)**\>
+ **Prevent user from defining invalid pattern occurrences for Rename-Many** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[e17dffc](https://github.com/EliziumNet/Loopz/commit/e17dffc0adf9ea048a416083142d693b55755ae2)**) \<**[#74](https://github.com/EliziumNet/Loopz/issues/74)**\>
+ **Rename-Many: Add novice/locked mode** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[44d630d](https://github.com/EliziumNet/Loopz/commit/44d630d7563c75957fd794ac0f6f62b09a8f0ab0)**) \<**[#82](https://github.com/EliziumNet/Loopz/issues/82)**\>
+ **Add errors to Summary** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[accdbbd](https://github.com/EliziumNet/Loopz/commit/accdbbd95a98ad561b4eb925d43bd96f0e419530)**) \<**[#65](https://github.com/EliziumNet/Loopz/issues/65)**\>
+ **Use Tilde for inline expression escape** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[44d2b19](https://github.com/EliziumNet/Loopz/commit/44d2b19f758521ee6278bafba87b5006660454ee)**) \<**[#84](https://github.com/EliziumNet/Loopz/issues/84)**\>
+ **Minor visual improvements** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0d55754](https://github.com/EliziumNet/Loopz/commit/0d55754a597dacd03afae71e9833c0abd38b7688)**) \<**[#60](https://github.com/EliziumNet/Loopz/issues/60)**\>
+ **Use Write-ThemedPairsInColour in Write-HostFeItemDecorator to dsplay additional lines** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[8340cd4](https://github.com/EliziumNet/Loopz/commit/8340cd4352b0b0ed7e226e7de60320b0ee01907c)**) \<**[#45](https://github.com/EliziumNet/Loopz/issues/45)**\>
+ **Skip already anchored (Start/End) items** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[74c9f97](https://github.com/EliziumNet/Loopz/commit/74c9f970839fee77b3ef8b2dbcb76d2cdbf9fb3b)**) \<**[#51](https://github.com/EliziumNet/Loopz/issues/51)**\>
+ **Create RegEx with custom options from inline codes** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[ddc26ad](https://github.com/EliziumNet/Loopz/commit/ddc26ad5d8a0e60c289c1ad4d00ffa73d3c02c69)**) \<**[#48](https://github.com/EliziumNet/Loopz/issues/48)**\>
+ **Protect against accidental/erronous escaping on Paste & With params** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[9af5162](https://github.com/EliziumNet/Loopz/commit/9af5162b80832872c84dc577af245715728cb291)**) \<**[#85](https://github.com/EliziumNet/Loopz/issues/85)**\>
+ **Write-HostFeItemDecorator renders multi-line content** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0d13eb9](https://github.com/EliziumNet/Loopz/commit/0d13eb908c23782de360cb6d2b91ee7ea54874d2)**) \<**[#42](https://github.com/EliziumNet/Loopz/issues/42)**\>
+ **Add Top parameter to Invoke-ForachFsItem & Rename-Many** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[47bc8ef](https://github.com/EliziumNet/Loopz/commit/47bc8ef9c29629ae6e3dce2525c5d9ba0cb39180)**) \<**[#86](https://github.com/EliziumNet/Loopz/issues/86)**\>
+ **Add Include parameter to Rename-Many** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[869e430](https://github.com/EliziumNet/Loopz/commit/869e430f1f81e7e832b0ea397eff7b88bdae8b76)**) \<**[#53](https://github.com/EliziumNet/Loopz/issues/53)**\>
+ **Implement Undo functionality** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[7c55736](https://github.com/EliziumNet/Loopz/commit/7c55736567f44a597c51a7ab16c6556b4364a616)**) \<**[#43](https://github.com/EliziumNet/Loopz/issues/43)**\>
+ **Fix signal emojis/indentation for Rename-Many and fix MISSING signal** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[101545a](https://github.com/EliziumNet/Loopz/commit/101545ace51be9c6db4b0fe269ac9bb32616f80f)**) \<**[#54](https://github.com/EliziumNet/Loopz/issues/54)**\>
+ **Add initial implementation of Rename-ForeachFsItem** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[b27c5a9](https://github.com/EliziumNet/Loopz/commit/b27c5a9fab8bbdd54ea5afe7cfb61ce79141d58a)**) \<**[#38](https://github.com/EliziumNet/Loopz/issues/38)**\>
+ **Add Show-Header (uses Krayola writer)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[a36792d](https://github.com/EliziumNet/Loopz/commit/a36792d499e97b1235792b1836e4ae10c256e5cf)**) \<**[#76](https://github.com/EliziumNet/Loopz/issues/76)**\>
+ **Add platform functions to support platfrom specific code** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[5e14c92](https://github.com/EliziumNet/Loopz/commit/5e14c929fb7b31c6e0b962d6cb9dac873b6cd383)**) \<**[#44](https://github.com/EliziumNet/Loopz/issues/44)**\>
+ **Rename-Many; Return a PSCustomObject from action command with Payload property** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[f70e6d6](https://github.com/EliziumNet/Loopz/commit/f70e6d652dae7eb9d55163d2c0c0fb0cf242dd1c)**) \<**[#71](https://github.com/EliziumNet/Loopz/issues/71)**\>
+ **Remove legacy Literal parameter (Rename-ForeachFsItem)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[9916769](https://github.com/EliziumNet/Loopz/commit/9916769ad6321c52641aa4141bd279b8fd20a1a3)**) \<**[#41](https://github.com/EliziumNet/Loopz/issues/41)**\>
+ **Add drop param to Rename-Many** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[4d131e3](https://github.com/EliziumNet/Loopz/commit/4d131e34d2521eaf83c61034b8efc7e91a9d5e78)**) \<**[#75](https://github.com/EliziumNet/Loopz/issues/75)**\>
+ **Add new function Update-CustomSignals** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[5f17a75](https://github.com/EliziumNet/Loopz/commit/5f17a754e95c50274c8ce51cb7ed548e00d1469d)**) \<**[#94](https://github.com/EliziumNet/Loopz/issues/94)**\>
+ **Add Context to Rename-Many to allow for customisation by higher-order commands** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[bb458c1](https://github.com/EliziumNet/Loopz/commit/bb458c1a54d3e7a1df85599a7853cfd70068653c)**) \<**[#50](https://github.com/EliziumNet/Loopz/issues/50)**\>
+ **Add Force parameter to Select-SignalContainer** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[29dd2f2](https://github.com/EliziumNet/Loopz/commit/29dd2f200b38b85f41ff76b6fba1716f862f93bb)**) \<**[#57](https://github.com/EliziumNet/Loopz/issues/57)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Fix minor writer issues** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[c9d249d](https://github.com/EliziumNet/Loopz/commit/c9d249dba8c9e322fd30d2905eea7cff234dbd0b)**) \<**[#79](https://github.com/EliziumNet/Loopz/issues/79)**\>
+ **Ensure AnchorOccurrence is passed into Move-Match & define tests for Last Anchor/Copy** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[bb0464d](https://github.com/EliziumNet/Loopz/commit/bb0464db0df5bcb6158aa01c41b5e50297c09a3d)**) \<**[#68](https://github.com/EliziumNet/Loopz/issues/68)**\>
+ **Rename-Many; Remove accidental casting of RegEx object to string** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[70301cc](https://github.com/EliziumNet/Loopz/commit/70301cc6ab05a3c056e237b5ca78c7599f4137bc)**) \<**[#69](https://github.com/EliziumNet/Loopz/issues/69)**\>
+ **Define the undo disabled key in the Context** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[625cb7b](https://github.com/EliziumNet/Loopz/commit/625cb7bc3d1f98d235a0eef78f0eb18fccc2185c)**) \<**[#96](https://github.com/EliziumNet/Loopz/issues/96)**\>
+ **Rename-Many; use LiteralPath instead of Path to fix issue of paths including square brackets** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[2f4f91a](https://github.com/EliziumNet/Loopz/commit/2f4f91ac8b377fbb2f052ddc7b043fdb1594965d)**) \<**[#49](https://github.com/EliziumNet/Loopz/issues/49)**\>
+ **Rename-Many: swap To for From to correct File/Directory display** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[15446f0](https://github.com/EliziumNet/Loopz/commit/15446f00200c3c43c4284a3909eeea9c9f0e298c)**) \<**[#47](https://github.com/EliziumNet/Loopz/issues/47)**\>
+ **Rename-Many; should should exception message and callstack if error occurs** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[44d0b91](https://github.com/EliziumNet/Loopz/commit/44d0b91d83e1eb6d74931e0a2d565435fbc7d4e9)**) \<**[#101](https://github.com/EliziumNet/Loopz/issues/101)**\>
+ **Rename Select-Text to Select-Patterns** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[54db603](https://github.com/EliziumNet/Loopz/commit/54db603182807ef213b111519fd05b547cc5ea1e)**) \<**[#98](https://github.com/EliziumNet/Loopz/issues/98)**\>
+ **Rename-Many; Insert the cut indicator for Update-Match when With/LiteralWith/Paste are not present** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0d9e171](https://github.com/EliziumNet/Loopz/commit/0d9e17165da5ad3dd57422f47d185e502ea6017a)**) \<**[#46](https://github.com/EliziumNet/Loopz/issues/46)**\>
+ **Replace Invoke with InvokeReturnAsIs on scriptblocks** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0ddcac2](https://github.com/EliziumNet/Loopz/commit/0ddcac2dc88021ffc7769aa48ce2b2389f6ddbfd)**) \<**[#70](https://github.com/EliziumNet/Loopz/issues/70)**\>
+ **Fix Show-Signals (not showing correct emoji length)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[cf3c96e](https://github.com/EliziumNet/Loopz/commit/cf3c96ec62669a7d988add90a5bf195b625bf0a9)**) \<**[#95](https://github.com/EliziumNet/Loopz/issues/95)**\>
+ **Fix Copy param in Update-Match** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[883901b](https://github.com/EliziumNet/Loopz/commit/883901b07be9359fd2b9f51af203fcf9815a5160)**) \<**[#72](https://github.com/EliziumNet/Loopz/issues/72)**\>
+ **Initial (incomplete) implementation of header block rendering** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[c18b819](https://github.com/EliziumNet/Loopz/commit/c18b8196442fbba66c84af378a4fe75ada023827)**) \<**[#40](https://github.com/EliziumNet/Loopz/issues/40)**\>
+ **Fix data leaking out to console as a result of un-consumed array.append** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[4a3a670](https://github.com/EliziumNet/Loopz/commit/4a3a670e0646d7f395c8f9c06dcbab51f4c804c5)**) \<**[#92](https://github.com/EliziumNet/Loopz/issues/92)**\>
+ **Render wide items on separate line if '...GROUP-WIDE-ITEMS' not set** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[9c171b4](https://github.com/EliziumNet/Loopz/commit/9c171b467d2746e739d3fe682bdd5300480dc30e)**) \<**[#58](https://github.com/EliziumNet/Loopz/issues/58)**\>
+ **Start and End in summary should not show Pattern** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[77ad0ca](https://github.com/EliziumNet/Loopz/commit/77ad0ca727d615f5ee4d05d6539748a862085a2b)**) \<**[#87](https://github.com/EliziumNet/Loopz/issues/87)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:gem:ref)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Restructure source layout** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[5ae2ca0](https://github.com/EliziumNet/Loopz/commit/5ae2ca0e448a0253184ea561e8deae2d030eb9bc)**) \<**[#81](https://github.com/EliziumNet/Loopz/issues/81)**\>
+ **fix analyser warnings** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[e8da65d](https://github.com/EliziumNet/Loopz/commit/e8da65d539852f72b3e7b7fa65994e584e3cadb4)**) \<**[#93](https://github.com/EliziumNet/Loopz/issues/93)**\>
+ **Change PassThru Remy namespace from 'RN-FOREACH' to 'REMY'** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[d83064c](https://github.com/EliziumNet/Loopz/commit/d83064cd8385c906f1e528b5ed79172935139564)**) \<**[#52](https://github.com/EliziumNet/Loopz/issues/52)**\>
+ **Refactor Rename-Many Context defaults** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[bdca169](https://github.com/EliziumNet/Loopz/commit/bdca1694937ba7f2f689996c7ca82c2014fffc09)**) \<**[#103](https://github.com/EliziumNet/Loopz/issues/103)**\>
+ **Rename writer to Krayon** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0b38c8c](https://github.com/EliziumNet/Loopz/commit/0b38c8c1d3a529541bc4b1856fcaaf5d5c4f1e5a)**) \<**[#88](https://github.com/EliziumNet/Loopz/issues/88)**\>
+ **Change param LiteralWith to LiteralCopy in Rename-Many only** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[3706d2a](https://github.com/EliziumNet/Loopz/commit/3706d2ab7bf8483ff70957969eaaa9a0c676c38a)**) \<**[#55](https://github.com/EliziumNet/Loopz/issues/55)**\>
+ **Internal functions run InModuleScope, test functions defined in global or script scope** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[f8b6831](https://github.com/EliziumNet/Loopz/commit/f8b6831dbc6fbcba3fcafcd33771e89d56f4a286)**) \<**[#67](https://github.com/EliziumNet/Loopz/issues/67)**\>
+ **Rename-Many: improve indent calculation** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[c0c5de1](https://github.com/EliziumNet/Loopz/commit/c0c5de18a35aea62dd6d9b5418021eb1272e2895)**) \<**[#62](https://github.com/EliziumNet/Loopz/issues/62)**\>
+ **Rename PassThru to Exchange** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0f6f273](https://github.com/EliziumNet/Loopz/commit/0f6f273760bb3a67e96da774243577c0d98bf27e)**) \<**[#63](https://github.com/EliziumNet/Loopz/issues/63)**\>
+ **Use Truncate flag in Show-Header** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[a52cf96](https://github.com/EliziumNet/Loopz/commit/a52cf96f63a14235356fc411b35bb73ab0a65b7c)**) \<**[#102](https://github.com/EliziumNet/Loopz/issues/102)**\>
+ **Finish off migrating Rename-many to use Krayola writer** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[695de24](https://github.com/EliziumNet/Loopz/commit/695de24d890c6acb27cc71b7a159adc5d3c61468)**) \<**[#78](https://github.com/EliziumNet/Loopz/issues/78)**\>

---

## Release [1.2.0] / 2020-09-17

:sparkles: HIGHLIGHTS

+ Add generic Controller class for use by iterator functions

### Scope(:lock:uncategorised)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **If WhatIf enabled, set LOOPZ.MIRROR.DESTINATION to synthetic directoryInfo** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[1043c13](https://github.com/EliziumNet/Loopz/commit/1043c1392c8a0db330914d5b1b2a82df432559d8)**) \<**[#34](https://github.com/EliziumNet/Loopz/issues/34)**\>
+ **Add controller class. (Partial checkin)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[4e3cb41](https://github.com/EliziumNet/Loopz/commit/4e3cb41ddb2b2ac83282851c4f39b60011bcc8c3)**) \<**[#36](https://github.com/EliziumNet/Loopz/issues/36)**\>

---

## Release [1.1.1] / 2020-09-02

:sparkles: HIGHLIGHTS

+ Make 'Product' affirm-able in iterator functions; this allows highlighting of processed items in an iteration batch
+ Add 'COUNT' into the exchange for use by ui functions
+ Add Header ui function for use by iteration functions
+ Add more flexible ways to display longer items in Summary function

### Scope(:lock:uncategorised)

#### Commit Type(:gift:feat)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Add LOOPZ.*.COUNT to PassThru** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[e19a88f](https://github.com/EliziumNet/Loopz/commit/e19a88fefd86a61c7c9e7638f1572421b1b0747c)**) \<**[#28](https://github.com/EliziumNet/Loopz/issues/28)**\>
+ **Add Header to compound functions** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[94d0a44](https://github.com/EliziumNet/Loopz/commit/94d0a44964e0edc0e43c90f97fc74e89317ea64b)**) \<**[#29](https://github.com/EliziumNet/Loopz/issues/29)**\>
+ **Add Summary wide pairs** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[4a08944](https://github.com/EliziumNet/Loopz/commit/4a08944763d831c4268df213a9cdd5a31845d63a)**) \<**[#31](https://github.com/EliziumNet/Loopz/issues/31)**\>
+ **Make Product Affrimable** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[27127c2](https://github.com/EliziumNet/Loopz/commit/27127c27aa04d66f5a88e6489e1e0307c0606d57)**) \<**[#25](https://github.com/EliziumNet/Loopz/issues/25)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **remove exception handling** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[53d6bcb](https://github.com/EliziumNet/Loopz/commit/53d6bcbfa9efcda49dd1ebfa29a42ba1e4b0b7f6)**) \<**[#26](https://github.com/EliziumNet/Loopz/issues/26)**\>
+ **Catch the MethodInvocationException** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[fac0998](https://github.com/EliziumNet/Loopz/commit/fac0998be058cc00398066b333516c9aea4c61c4)**) \<**[#35](https://github.com/EliziumNet/Loopz/issues/35)**\>

---

## Release [1.1.0] / 2020-08-21

:sparkles: HIGHLIGHTS

+ Added ui utility helper functions and definitions.

### Scope(:lock:uncategorised)

#### Commit Type(:gift:feat)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **dont add files to FunctionsToExport if they are not of the form verb-noun** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[a055776](https://github.com/EliziumNet/Loopz/commit/a055776bebc1c1fa7a329f7df6c6d946c17431f4)**) \<**[#24](https://github.com/EliziumNet/Loopz/issues/24)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Make WHAT-IF global inside PassThru** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[5d118f4](https://github.com/EliziumNet/Loopz/commit/5d118f467e26e2b3bc4eaeea683d117cac4170a1)**) \<**[#23](https://github.com/EliziumNet/Loopz/issues/23)**\>

---

## Release [1.0.1] / 2020-08-18

:sparkles: HIGHLIGHTS

+ *Insignificant release to correct an issue with the initial release.*

---

## Release [1.0.0] / 2020-08-18

:sparkles: HIGHLIGHTS

+ Initial release, containing iteration functions ___Invoke-ForeachFsItem___, ___Invoke-MirrorDirectoryTree___ and ___Invoke-TraverseDirectory___.

### Scope(:lock:uncategorised)

#### Commit Type(:gift:feat)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Implement Hoist in mirrorDirectoryTree & traverseDirectory** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[d858e18](https://github.com/EliziumNet/Loopz/commit/d858e180d1f071e659a7eaeb4180eb16b73c7f06)**) \<**[#11](https://github.com/EliziumNet/Loopz/issues/11)**\>
+ **Rm ITEM-VALUE/PROPERTIES; use Pairs instead; Partial checkin, single item arrays dont work** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[3884bbe](https://github.com/EliziumNet/Loopz/commit/3884bbec11f622f0c5ea8474049a891c02e0eb09)**) \<**[#20](https://github.com/EliziumNet/Loopz/issues/20)**\>
+ **Add remove-SingleSubString (incomplete checkin)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[19a3d25](https://github.com/EliziumNet/Loopz/commit/19a3d25f3ebe0bc8f567936df83b1d30b30cfdd6)**) \<**[#4](https://github.com/EliziumNet/Loopz/issues/4)**\>
+ **Renamed to Write-HostFeItemDecorator** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[341ba9c](https://github.com/EliziumNet/Loopz/commit/341ba9c537e38a8e8b35c9bc78183462aa57d09f)**) \<**[#9](https://github.com/EliziumNet/Loopz/issues/9)**\>
+ **(incomplete/checkpoint) Add PROPERTIES to items written** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[2f5581a](https://github.com/EliziumNet/Loopz/commit/2f5581ae5f6df5e66f3068cd097c19f1d0d63891)**) \<**[#8](https://github.com/EliziumNet/Loopz/issues/8)**\>
+ **Add inline function commenting** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[4203348](https://github.com/EliziumNet/Loopz/commit/42033489fb78feb3ecd0b3350af8018e25cc2f1f)**) \<**[#15](https://github.com/EliziumNet/Loopz/issues/15)**\>
+ **add function Write-HostItemDecorator** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[8c28184](https://github.com/EliziumNet/Loopz/commit/8c28184b4dcc22f44ec5961494156c78b80e2e16)**) \<**[#5](https://github.com/EliziumNet/Loopz/issues/5)**\>
+ **Add initial impl based on invoke-ForeachFile** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[9e4cd46](https://github.com/EliziumNet/Loopz/commit/9e4cd46b771276cd3f0108d6c85621da557f8df3)**) \<**[#10](https://github.com/EliziumNet/Loopz/issues/10)**\>
+ **Set StrictMode to 1.0** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[4384748](https://github.com/EliziumNet/Loopz/commit/4384748e80cfb3fb8abdd630b571727831a41786)**) \<**[#21](https://github.com/EliziumNet/Loopz/issues/21)**\>
+ **Add boilerplate** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[31a1570](https://github.com/EliziumNet/Loopz/commit/31a15704ff9dd3cb9c09af60c5982a46db234017)**) \<**[#1](https://github.com/EliziumNet/Loopz/issues/1)**\>
+ **Tidy up warnings as best as possible** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[6f872e3](https://github.com/EliziumNet/Loopz/commit/6f872e39f0f8baa6cd6d29e32fde43aaa6d070bc)**) \<**[#14](https://github.com/EliziumNet/Loopz/issues/14)**\>
+ **Add named function invoke to Invoke-TraverseDirectory** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[2cd2d36](https://github.com/EliziumNet/Loopz/commit/2cd2d366e8fd7f3e8018a98a875bd618e49943fa)**) \<**[#12](https://github.com/EliziumNet/Loopz/issues/12)**\>

---

### Scope(:lock:uncategorised)

#### Commit Type(:heavy_check_mark:fix)

##### Change Type(:lock:uncategorised)

###### :recycle: NON BREAKING CHANGES

+ **Decouple CreateDirs from CopyFiles** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[0382714](https://github.com/EliziumNet/Loopz/commit/0382714882aec405d8e9b6acc80e72fdb924b9b8)**) \<**[#19](https://github.com/EliziumNet/Loopz/issues/19)**\>
+ **Fix module build; FunctionsToExport & aliases** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[6b88072](https://github.com/EliziumNet/Loopz/commit/6b88072c296bb4dd576cc7db633c41268cf6edc7)**) \<**[#22](https://github.com/EliziumNet/Loopz/issues/22)**\>
+ **check invoke result in TraverseDirectory (incomplete)** by `@plastikfan` <img title='plastikfan' src='https://github.com/plastikfan.png?size=24'> (Id: **[6c01c68](https://github.com/EliziumNet/Loopz/commit/6c01c68c7476695210c830182ee34ba622f0e17f)**) \<**[#18](https://github.com/EliziumNet/Loopz/issues/18)**\>

---

[Unreleased]: https://github.com/EliziumNet/Loopz/compare/3.0.2...HEAD
[3.0.2]: https://github.com/EliziumNet/Loopz/compare/3.0.1...3.0.2
[3.0.1]: https://github.com/EliziumNet/Loopz/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/EliziumNet/Loopz/compare/2.0.0...3.0.0
[2.0.0]: https://github.com/EliziumNet/Loopz/compare/1.2.0...2.0.0
[1.2.0]: https://github.com/EliziumNet/Loopz/compare/1.1.1...1.2.0
[1.1.1]: https://github.com/EliziumNet/Loopz/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/EliziumNet/Loopz/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/EliziumNet/Loopz/compare/1.0.0...1.0.1

<!-- Elizium.Loopz PoShLog options json schema version '1.0.0' -->
Powered By [:scroll: Elizium.PoShLog](https://github.com/EliziumNet/PoShLog)
