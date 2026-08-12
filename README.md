![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-jagger)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-jagger/total)

# 4d-plugin-jagger

`4d-plugin-jagger` is a Japanese morphological analyzer (形態素解析器) for 4D. It embeds [Jagger](https://www.tkl.iis.u-tokyo.ac.jp/~ynaga/jagger/index.ja.html), a pattern-matching tokenizer from the University of Tokyo, and drives it directly in-process (no external process is spawned) using a pattern trie built from a dictionary and a model. Out of the box it ships with the `kyoto+kwdlc` model and the `jumandic-7.0-20130310` dictionary, both embedded in the plugin bundle; you can swap in a custom-trained model at any time. Results come back as 4D `Collection`s (segmented words, or one `Object` per token), and `Object`s for the model-management commands.

## Summary

| Command | Returns | Purpose |
|---|---|---|
| [`Jagger split`](#jagger-split) | Collection | Split text into word-level tokens (segmentation only, no tagging) |
| [`Jagger tokenize`](#jagger-tokenize) | Collection | Split text into tokens, each with dictionary/POS information |
| [`Jagger train`](#jagger-train) | Object | Build a custom model from a training corpus and dictionary |
| [`Jagger set model`](#jagger-set-model) | Object | Load a model (bundled or custom-trained) as the active model |
| [`Jagger get model`](#jagger-get-model) | Object | Get the folder of the currently active model |

**Platforms:** macOS (Intel & Apple Silicon), Windows 64-bit.

---

## Requirements & platform notes

- **No setup required for basic use.** The plugin loads its bundled default model (`kyoto+kwdlc`) and dictionary (`jumandic-7.0-20130310`) automatically when 4D starts the plugin; `Jagger split`/`Jagger tokenize` work immediately with no call to `Jagger set model` needed.
- **If no model is loaded, `Jagger split`/`Jagger tokenize` fail silently.** Both commands return an empty `Collection` rather than raising a 4D error if the active model failed to load (e.g. a corrupted plugin install) or was never set. There is no way to distinguish "empty result because the text produced no tokens" from "empty result because no model is loaded" from the return value alone.
- **`Jagger tokenize` only returns the first sentence of its input.** Internally, Jagger delimits sentences with an end-of-sentence marker as it segments text. `Jagger tokenize`'s parsing of that output stops at the *first* sentence boundary it finds and discards everything after it — so multi-sentence input silently returns tokens for the first sentence only. `Jagger split` does not have this limitation; it returns tokens for the entire input regardless of how many sentences it contains. If you need to tokenize multi-sentence text today, split the text into sentences yourself first and call `Jagger tokenize` once per sentence.
- **All five commands are marked thread-safe** and internally serialize access to the active model, so calling `Jagger set model` concurrently with `Jagger split`/`Jagger tokenize`/`Jagger train` from different 4D processes is safe — but a `Jagger set model`/`Jagger train` call will block any other Jagger command running at the same time until it finishes (and vice versa), since they share one internal lock.
- **`Jagger set model` and `Jagger train` fail silently on a bad model/folder.** An invalid or unreadable model folder does not raise a 4D error; the previously active model is left in place (see each command's Description below for the exact fallback).
- **Training is not incremental.** `Jagger train` always builds a full model from scratch from the training corpus and dictionaries you pass it; there's no "update an existing model" mode.

---

## Jagger split

### Syntax

```4d
Jagger split ( text ) → Collection
```

| Parameter | Type | Description |
|---|---|---|
| `text` | Text | The text to segment. |
| Result | Collection | One element per word-level token, in order, as `Text`. |

### Description

Segments `text` into words using the active model's pattern trie, without attaching any dictionary/part-of-speech information (that's what [`Jagger tokenize`](#jagger-tokenize) is for). Unlike `Jagger tokenize`, this command's result covers the entire input, including multi-sentence text — there's no sentence-boundary truncation here.

If no model is currently active (see [Requirements & platform notes](#requirements--platform-notes)), this returns an empty `Collection` rather than raising an error.

### Example

From the plugin's own README:
```4d
$split:=Jagger split("お世話になっております。")
```

Segmenting each line of a multiline text and building a flat word list:
```4d
var $lines; $words : Collection
var $line : Text

$lines:=Split string("私は学生です。\n彼は先生です。"; "\n")
$words:=New collection

For each ($line; $lines)
  $words:=$words.concat(Jagger split($line))
End for each
```

---

## Jagger tokenize

### Syntax

```4d
Jagger tokenize ( text ) → Collection
```

| Parameter | Type | Description |
|---|---|---|
| `text` | Text | The text to tokenize. Only the first sentence is analyzed — see note below. |
| Result | Collection | One `Object` per token (see shape below), in order. |

Each element of the result `Collection` is an `Object` with:

| Property | Type | Description |
|---|---|---|
| `pos` | Text | **Despite the name, this is the token's surface text** (the actual word/substring matched), not a part-of-speech tag. The part-of-speech tag lives in `dic` (below). |
| `dic` | Collection | The token's dictionary/feature fields, comma-split from the model's raw feature string — up to 4 fields (part-of-speech category, a finer-grained subcategory, and the token's base form/reading, in the order the underlying `jumandic`-format dictionary stores them). The exact semantic label of each field depends on the dictionary the active model was trained/built with; treat this as an ordered feature vector rather than a fixed named schema unless you've confirmed the field order for your specific model. |

### Description

Segments `text` the same way `Jagger split` does, but additionally attaches each token's dictionary features. Internally, each analyzed token comes back as `surface<TAB>feature1,feature2,feature3,feature4`; this command splits that on the tab to populate `pos`/`dic`, and splits the feature half on commas to populate `dic`'s elements.

**Only the first sentence in `text` is returned.** As soon as internal parsing hits the marker Jagger writes between sentences, it stops and drops everything after it — this is a real limitation, not intentionally documented behavior of the underlying analyzer. Single-sentence input (like the examples below) is unaffected.

Tokens with an empty surface form are silently skipped and don't appear in the result (this can happen for pattern artifacts the tagger emits internally).

If no model is currently active, this returns an empty `Collection` rather than raising an error — the same fallback as `Jagger split`.

### Example

From the plugin's own README:
```4d
$tokenize:=Jagger tokenize("お世話になっております。")
```

From the plugin's own test method (`test.4dm`), tokenizing and copying the result to the clipboard as JSON:
```4d
$jagger:=Jagger tokenize("QUIT 4Dコマンドは、カレントの4Dアプリケーションを終了してデスクトップに戻ります。")

SET TEXT TO PASTEBOARD(JSON Stringify($jagger; *))
```

Reading the surface text and dictionary fields back out of each token:
```4d
var $tokens : Collection
var $token : Object

$tokens:=Jagger tokenize("お世話になっております。")

For each ($token; $tokens)
  ALERT($token.pos+" -> "+$token.dic.join(", "))
End for each
```

---

## Jagger train

### Syntax

```4d
Jagger train ( modelFolder ; trainFile ; userFile { ; dictFile } ) → Object
```

| Parameter | Type | Description |
|---|---|---|
| `modelFolder` | Object (4D.Folder) | Destination folder for the compiled model. Created (including intermediate folders) if it doesn't already exist. |
| `trainFile` | Object (4D.File) | Training corpus, one token per line as `surface<TAB>feature`, sentences separated by an `EOS` line (per the README: CSV/UTF-8, no empty lines). |
| `userFile` | Object (4D.File) | Supplementary user dictionary file, added on top of the base dictionary. |
| `dictFile` | Object (4D.File) | Optional. Base dictionary to use instead of the plugin's bundled default (`jumandic-7.0-20130310`). Omit this parameter (or pass an invalid/`Null` object) to use the bundled default. |
| Result | Object | See shape below. |

The result `Object` has:

| Property | Type | Description |
|---|---|---|
| `success` | Boolean | `true` if training completed and the model was written to `modelFolder`. `false` on any failure (missing/unreadable input file, or an error partway through building/writing the model). |
| `model` | Object (4D.Folder) | **Only present when `success` is `true`.** The same folder as `modelFolder`, returned as a ready-to-use `4D.Folder` object you can pass straight to [`Jagger set model`](#jagger-set-model). |

### Description

Builds a new pattern-based model from `trainFile` plus the combined dictionary (`dictFile` or the bundled default, with `userFile`'s entries added on top), and writes the compiled model files into `modelFolder`. This does not affect the currently active model — call [`Jagger set model`](#jagger-set-model) with the returned `model` folder afterward to start using it.

Training does not raise a 4D error on failure; check `success`. Common failure causes based on the parameter-reading code: `modelFolder`, `userFile`, or `trainFile` not resolving to a valid platform path (e.g. an object that isn't a real `4D.Folder`/`4D.File`), or the training file being unreadable.

Building a model from a non-trivial corpus can take a noticeable amount of time (the plugin's own progress logging refers to multiple sequential passes: extracting patterns, then building and writing the trie) — expect this to block the calling process for longer than a typical plugin call, especially for large corpora.

### Example

From the plugin's own test method (`test_train.4dm`), training only if a model doesn't already exist at the destination, then activating it:
```4d
var $model : 4D.Folder
$model:=Folder(fk desktop folder).folder("4dcommands")

If (Not($model.exists))
  
  $user:=File("/RESOURCES/user")  //csv,utf8,no empty lines
  $train:=File("/RESOURCES/train.JAG")  //csv,utf8,no empty lines
  $status:=Jagger train($model; $train; $user)
  
End if 

$model:=Jagger get model  //default model is embedded in plugin
$model:=Jagger set model($model)
```

Checking the result and switching to the newly trained model:
```4d
var $status : Object
var $train; $user : 4D.File
var $modelFolder : 4D.Folder

$modelFolder:=Folder(fk desktop folder).folder("custom_model")
$train:=File("/RESOURCES/train.JAG")
$user:=File("/RESOURCES/user")

$status:=Jagger train($modelFolder; $train; $user)

If ($status.success)
  Jagger set model($status.model)
Else
  ALERT("Training failed")
End if 
```

Overriding the base dictionary as well (the commented-out form shown in the README):
```4d
$status:=Jagger train($model; $train; $user; $dict)
```

---

## Jagger set model

### Syntax

```4d
Jagger set model ( modelFolder ) → Object
```

| Parameter | Type | Description |
|---|---|---|
| `modelFolder` | Object (4D.Folder) | Folder containing a compiled model (either the plugin's bundled model folder, or a folder produced by [`Jagger train`](#jagger-train)). |
| Result | Object (4D.Folder) | The folder of the model that is active *after* this call — see fallback behavior below. |

### Description

Loads the model at `modelFolder` and makes it the active model used by subsequent [`Jagger split`](#jagger-split)/[`Jagger tokenize`](#jagger-tokenize) calls.

**Fails silently and keeps the previous model active** if `modelFolder` doesn't resolve to a valid platform path, or if the model files at that path are missing/corrupt. In either case, no 4D error is raised, and the returned `Object` is the folder of whichever model ends up active — the new one on success, or the still-previous one on failure. Compare the result's path against the folder you passed in if you need to detect a failed switch.

### Example

From the plugin's own README, restoring the default model after temporarily switching to a custom one:
```4d
var $model : 4D.Folder
$model:=Jagger get model()
$model:=Jagger set model(Folder("/RESOURCES/kyoto+kwdlc"))
```

From the plugin's own test method (`test.4dm`):
```4d
$model:=Folder(fk desktop folder).folder("4dcommands")
$model:=Jagger set model($model)
$jagger:=Jagger tokenize("QUIT 4Dコマンドは、カレントの4Dアプリケーションを終了してデスクトップに戻ります。")
```

Round-tripping to a saved model and back to the default:
```4d
var $defaultModel; $customModel : 4D.Folder

$defaultModel:=Jagger get model  //save the current (default) model
$customModel:=Jagger set model(Folder(fk desktop folder).folder("custom_model"))

//... use the custom model here ...

Jagger set model($defaultModel)  //restore
```

---

## Jagger get model

### Syntax

```4d
Jagger get model → Object
```

| Parameter | Type | Description |
|---|---|---|
| Result | Object (4D.Folder) | The folder of the currently active model. |

### Description

Returns the folder of whichever model is currently active — the bundled default at plugin startup, or the last folder successfully passed to [`Jagger set model`](#jagger-set-model)/returned by [`Jagger train`](#jagger-train).

### Example

From the plugin's own README:
```4d
var $model : 4D.Folder
$model:=Jagger get model()
```

From the plugin's own test method (`test.4dm`), saving the default model before temporarily switching away from it:
```4d
$defaultmodel:=Jagger get model  //default model is embedded in plugin
```

---

## Error handling & troubleshooting

- **`Jagger split`/`Jagger tokenize` return an empty collection instead of erroring** when no model is active. If you're getting unexpected empty results, confirm with `Jagger get model` that a model is actually loaded, rather than assuming the input text itself produced nothing.
- **`Jagger tokenize` silently drops everything after the first sentence.** If you're tokenizing text with more than one sentence-ending punctuation mark and only getting tokens for the beginning of it, this is why — split the text into individual sentences yourself and call `Jagger tokenize` once per sentence.
- **A failed `Jagger set model`/`Jagger train` call raises no 4D error.** Always check `Jagger train`'s `success` property, and/or compare `Jagger set model`'s returned folder against what you passed in, rather than assuming the call took effect.
- **The `pos` property from `Jagger tokenize` is not a part-of-speech tag** — it's the token's surface text. The actual dictionary/part-of-speech information is in `dic`.
- **`Jagger train`'s result has no `model` property at all on failure** — check `success` before reading `model`, rather than checking whether `model` is null/empty.
- **Concurrent Jagger calls serialize, they don't fail.** If `Jagger set model`/`Jagger train` seems to briefly stall a concurrent `Jagger split`/`Jagger tokenize` call (or vice versa), that's expected — they share one internal lock so only one Jagger command runs at a time across all 4D processes.

---

## Quick reference

```4d
// segment + tokenize with the default bundled model
$words:=Jagger split("お世話になっております。")
$tokens:=Jagger tokenize("お世話になっております。")

// train a custom model and switch to it
$modelFolder:=Folder(fk desktop folder).folder("custom_model")
$train:=File("/RESOURCES/train.JAG")
$user:=File("/RESOURCES/user")
$status:=Jagger train($modelFolder; $train; $user)
If ($status.success)
  Jagger set model($status.model)
End if 

// save/restore the active model
$saved:=Jagger get model
Jagger set model($modelFolder)
// ...
Jagger set model($saved)
```
